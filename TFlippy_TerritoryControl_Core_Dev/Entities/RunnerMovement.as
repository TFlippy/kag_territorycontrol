// Runner Movement Walking

#include "RunnerCommon.as"
#include "MakeDustParticle.as";
#include "FallDamageCommon.as";
#include "Knocked.as";

const string fallscreamtag = "_fallingscream";

void onInit(CMovement@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	// this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	RunnerMoveVars@ moveVars;
	if (!blob.get("moveVars", @moveVars))
	{
		return;
	}

	if (blob.isAttached())
	{
		CleanUp(this, blob, moveVars);
		return;
	}
	
	if ((blob.isMyPlayer()) || (blob.isBot() && isServer())) 
	{
		HandleStuckAtTop(blob);
	}
	
	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);

	const bool isknocked = isKnocked(blob);

	const bool is_client = isClient();

	//cache
	const bool on_ladder = blob.isOnLadder();
	const bool on_ground = blob.isOnGround();
	const bool in_water  = blob.isInWater();
	const bool onground  = on_ground || on_ladder;
	const bool on_wall   = blob.isOnWall();
	const bool on_map    = blob.isOnMap();
	const bool on_ceiling = blob.isOnCeiling();
	const bool facing_left = blob.isFacingLeft();
	const bool is_attached = blob.isAttached();

	CSprite@ sprite = blob.getSprite();
	CMap@ map = blob.getMap();
	Vec2f vel = blob.getVelocity();
	Vec2f pos = blob.getPosition();
	CShape@ shape = blob.getShape();

	const f32 vellen = shape.vellen;


	if (is_client && getGameTime() % 3 == 0)
	{
		if (vel.y > 0.2f)
		{
			if (vel.y > BaseFallSpeed() * 1.8f && !blob.isInInventory())
			{
				if (!blob.hasTag(fallscreamtag))
				{
					blob.Tag(fallscreamtag);
					Sound::Play("man_scream.ogg", pos);
				}
			}
		}
		else
		{
			blob.Untag(fallscreamtag);
		}

		/* unfortunately, this doesn't work with archer bow draw stuff;
			might need to bind separate sounds cause this solution is much better.

			if(vel.y > BaseFallSpeed() * 1.1f)
			{
				if(!blob.hasTag(fallscreamtag))
				{
					blob.Tag(fallscreamtag);

					CSprite@ sprite = blob.getSprite();

					sprite.SetEmitSoundVolume(1.0f);
					sprite.SetEmitSound( "man_scream.ogg" );
					sprite.SetEmitSoundPaused( false );
					sprite.RewindEmitSound();
				}
			}
		}
		else
		{
			blob.Untag(fallscreamtag);
			CSprite@ sprite = blob.getSprite();

			sprite.SetEmitSoundPaused( true );
		}*/
	}

	if (onground || in_water)  //also reset when vaulting
	{
		moveVars.walljumped_side = Walljump::NONE;
		moveVars.wallrun_start = pos.y;
		moveVars.wallrun_current = pos.y;
		moveVars.fallCount = -1;
	}

	// ladder - overrides other movement completely
	if (on_ladder && !is_attached && !on_ground && !isknocked)
	{
		shape.SetGravityScale(0.0f);
		Vec2f ladderforce;

		if (up)
		{
			ladderforce.y -= 1.0f;
		}

		if (down)
		{
			ladderforce.y += 1.2f;
		}

		if (left)
		{
			ladderforce.x -= 1.0f;
		}

		if (right)
		{
			ladderforce.x += 1.0f;
		}

		blob.AddForce(ladderforce * moveVars.overallScale * 100.0f);
		//damp vel
		Vec2f temp = vel;
		temp *= 0.05f;
		blob.setVelocity(temp);

		moveVars.jumpCount = -1;
		moveVars.fallCount = -1;

		CleanUp(this, blob, moveVars);
		return;
	}

	shape.SetGravityScale(1.0f);
	shape.getVars().onladder = false;

	//swimming - overrides other movement partially
	if (in_water && !isknocked)
	{
		const f32 swimspeed = moveVars.swimspeed;
		const f32 swimforce = moveVars.swimforce;
		const f32 edgespeed = moveVars.swimspeed * moveVars.swimEdgeScale;

		Vec2f waterForce;

		moveVars.jumpCount = 50;

		//up and down
		if (up)
		{
			if (vel.y > -swimspeed)
			{
				if (!map.isInWater(pos + Vec2f(0, -8)))
				{
					waterForce.y -= 0.6f;
				}
				else
				{
					waterForce.y -= 0.8f;
				}
			}

			// more push near ledge
			if (vel.y > -(swimspeed * 3.3))
			{
				if (on_wall)
				{
					moveVars.jumpCount = 0;

					if (on_map)
					{
						waterForce.y -= 2.0f;
					}
					else
					{
						waterForce.y -= 1.5f;
					}
				}
			}
		}

		if (down && vel.y < swimspeed)
		{
			waterForce.y += 1;
		}

		//left and right
		if (left && vel.x > -swimspeed)
		{
			waterForce.x -= 1;
		}

		if (right && vel.x < swimspeed)
		{
			waterForce.x += 1;
		}

		waterForce *= swimforce * moveVars.overallScale;
		blob.AddForce(waterForce);

		if (!on_ground && !on_ladder)
		{
			CleanUp(this, blob, moveVars);
			return;				//done for swimming -----------------------
		}
		else
		{
			moveVars.walkFactor *= 0.2f;
			moveVars.jumpFactor *= 0.5f;
		}
	}

	//otherwise, do normal movement :)

	//walljumping, wall running and wall sliding

	if (vel.y > 4.0f)
	{
		if (moveVars.walljumped_side == Walljump::JUMPED_LEFT){
			moveVars.walljumped_side = Walljump::LEFT;
		}

		if (moveVars.walljumped_side == Walljump::JUMPED_RIGHT){
			moveVars.walljumped_side = Walljump::RIGHT;
		}
	}

	if (!on_ceiling && !isknocked &&
	        !on_ladder && (up || left || right))  //key pressed
	{
		//check solid tiles
		const f32 ts = map.tilesize;
		const f32 y_ts = ts * 0.2f;
		const f32 x_ts = ts * 1.4f;

		bool surface_left = map.isTileSolid(pos + Vec2f(-x_ts, y_ts - map.tilesize)) ||
		                    map.isTileSolid(pos + Vec2f(-x_ts, y_ts));
		if (!surface_left)
		{
			surface_left = checkForSolidMapBlob(map, pos + Vec2f(-x_ts, y_ts - map.tilesize), blob) ||
			               checkForSolidMapBlob(map, pos + Vec2f(-x_ts, y_ts), blob);
		}

		bool surface_right = map.isTileSolid(pos + Vec2f(x_ts, y_ts - map.tilesize)) ||
		                     map.isTileSolid(pos + Vec2f(x_ts, y_ts));
		if (!surface_right)
		{
			surface_right = checkForSolidMapBlob(map, pos + Vec2f(x_ts, y_ts - map.tilesize), blob) ||
			                checkForSolidMapBlob(map, pos + Vec2f(x_ts, y_ts), blob);
		}

		//not checking blobs for this - perf
		const bool surface_above = map.isTileSolid(pos + Vec2f(y_ts, -x_ts)) || map.isTileSolid(pos + Vec2f(-y_ts, -x_ts));
		const bool surface_below = map.isTileSolid(pos + Vec2f(y_ts, x_ts)) || map.isTileSolid(pos + Vec2f(-y_ts, x_ts));

		const bool surface = surface_left || surface_right;

		const f32 slidespeed = 2.45f;

		//wall jumping/running
		if (up && surface && 									//only on surface
		        moveVars.walljumped_side != Walljump::BOTH &&		//do nothing if jammed
		        !(left && right) &&									//do nothing if pressing both sides
		        !onground)
		{
			const bool wasNONE = (moveVars.walljumped_side == Walljump::NONE);

			const bool jumpedLEFT = (moveVars.walljumped_side == Walljump::JUMPED_LEFT);
			const bool jumpedRIGHT = (moveVars.walljumped_side == Walljump::JUMPED_RIGHT);

			bool dust = false;

			if (moveVars.jumpCount > 5) //wait some time to be properly in the air
			{
				//set contact point
				bool set_contact = false;
				if (left && surface_left && (moveVars.walljumped_side == Walljump::RIGHT || jumpedRIGHT || wasNONE))
				{
					moveVars.walljumped_side = Walljump::LEFT;
					moveVars.wallrun_start = pos.y;
					moveVars.wallrun_current = pos.y + 1.0f;
					set_contact = true;
				}
				if (right && surface_right && (moveVars.walljumped_side == Walljump::LEFT || jumpedLEFT || wasNONE))
				{
					moveVars.walljumped_side = Walljump::RIGHT;
					moveVars.wallrun_start = pos.y;
					moveVars.wallrun_current = pos.y + 1.0f;
					set_contact = true;
				}

				//wallrun
				if (!surface_above && vel.y < slidespeed &&
				        ((left && surface_left && !jumpedLEFT) || (right && surface_right && !jumpedRIGHT) || set_contact))
				{
					//within range
					if (set_contact ||
					        (pos.y - 1.0f < moveVars.wallrun_current &&
					         pos.y + 1.0f > moveVars.wallrun_start - map.tilesize * moveVars.wallrun_length))
					{
						moveVars.wallrun_current = Maths::Min(pos.y - 1.0f, moveVars.wallrun_current - 1.0f);

						moveVars.walljumped = true;
						if (set_contact || getGameTime() % 5 == 0)
						{
							dust = true;

							f32 wallrun_speed = moveVars.jumpMaxVel * 1.2f;

							if (vel.y > -wallrun_speed || set_contact)
							{
								vel.Set(0, -wallrun_speed);
								blob.setVelocity(vel);
							}

							if (!set_contact)
							{
								sprite.PlayRandomSound("/StoneJump");
							}
						}
					}
					else
					{
						moveVars.walljumped = false;
					}
				}
				//walljump
				else if (vel.y < slidespeed &&
				         ((left && surface_right) || (right && surface_left)) &&
				         !surface_below && !jumpedLEFT && !jumpedRIGHT)
				{
					f32 walljumpforce = 4.0f;
					vel.Set(surface_right ? -walljumpforce : walljumpforce, -2.0f);
					blob.setVelocity(vel);

					dust = true;

					moveVars.jumpCount = 0;

					if (right)
					{
						moveVars.walljumped_side = Walljump::JUMPED_LEFT;
					}
					else
					{
						moveVars.walljumped_side = Walljump::JUMPED_RIGHT;
					}
				}
			}

			if (dust)
			{
				if(isClient())
				{
					Vec2f dust_pos = (Vec2f(right ? 4.0f : -4.0f, 0.0f) + pos);
					MakeDustParticle(dust_pos, "Smoke.png");
				}
				
			}
		}
		else
		{
			moveVars.walljumped = false;
		}

		//wall sliding
		{
			Vec2f groundNormal = blob.getGroundNormal();
			if (
			    (left || right) && // require direction key hold
			    Maths::Abs(groundNormal.y) <= 0.01f) //sliding on wall
			{
				Vec2f force;

				Vec2f vel = blob.getVelocity();
				if (vel.y >= slidespeed && (facing_left ? groundNormal.x > 0 : groundNormal.x < 0))
				{
					f32 temp = vel.y * 0.9f;
					Vec2f new_vel(vel.x * 0.9f, temp < slidespeed ? slidespeed : temp);
					blob.setVelocity(new_vel);

					if (is_client) // effect
					{
						if (!moveVars.wallsliding)
						{
							sprite.PlayRandomSound("/Scrape");
						}

						//falling for almost a second so add effects
						if (moveVars.jumpCount > 20)
						{
							int gametime = getGameTime();
							if (gametime % (uint(Maths::Max(0, 7 - int(Maths::Abs(vel.y)))) + 3) == 0)
							{
								MakeDustParticle(pos, "/dust2.png");
								sprite.PlayRandomSound("/Scrape");
							}
						}
					}

					moveVars.wallsliding = true;
				}
			}
		}
	}

	// vaulting

	if (blob.isKeyPressed(key_up) && moveVars.canVault)
	{

		// boost over corner
		Vec2f groundNormal = blob.getGroundNormal();
		const bool canFreeVault = !on_map && moveVars.jumpCount < 5;
		groundNormal.Normalize();
		const bool sidekeypressed = ((left && (groundNormal.x > 0.1f || canFreeVault)) ||
		                       (right && (groundNormal.x < -0.1f || canFreeVault)));

		if (sidekeypressed)
		{
			bool vault = false;

			if (left)
			{
				f32 movingside = -1.0f;

				if (canVault(blob, map, movingside))
				{
					vault = true;
				}
			}

			if (right)
			{
				f32 movingside = 1.0f;

				if (canVault(blob, map, movingside))
				{
					vault = true;
				}
			}

			if (vault)
			{
				moveVars.jumpCount = -3;

				moveVars.walljumped_side = Walljump::NONE;
				moveVars.wallrun_start = pos.y;
				moveVars.wallrun_current = pos.y;
			}
		}
	}

	//jumping

	if (moveVars.jumpFactor > 0.01f && !isknocked)
	{

		if (onground)
		{
			moveVars.jumpCount = 0;
		}
		else
		{
			moveVars.jumpCount++;
		}

		if (up && vel.y > -moveVars.jumpMaxVel)
		{
			moveVars.jumpStart = 0.7f;
			moveVars.jumpMid = 0.2f;
			moveVars.jumpEnd = 0.1f;
			bool crappyjump = false;

			//todo what constitutes a crappy jump? maybe carrying heavy?
			if (crappyjump)
			{
				moveVars.jumpStart *= 0.79f;
				moveVars.jumpMid *= 0.69f;
				moveVars.jumpEnd *= 0.59f;
			}

			Vec2f force = Vec2f(0, 0);
			f32 side = 0.0f;

			if (facing_left && left)
			{
				side = -1.0f;
			}
			else if (!facing_left && right)
			{
				side = 1.0f;
			}

			// jump
			if (moveVars.jumpCount <= 0)
			{
				force.y -= 1.5f;
			}
			else if (moveVars.jumpCount < 3)
			{
				force.y -= moveVars.jumpStart;
				//force.x += side * moveVars.jumpMid;
			}
			else if (moveVars.jumpCount < 6)
			{
				force.y -= moveVars.jumpMid;
				//force.x += side * moveVars.jumpEnd;
			}
			else if (moveVars.jumpCount < 8)
			{
				force.y -= moveVars.jumpEnd;
			}

			//if (blob.isOnWall()) {
			//  force.y *= 1.1f;
			//}

			force *= moveVars.jumpFactor * moveVars.overallScale * 60.0f;


			blob.AddForce(force);

			// sound

			if (moveVars.jumpCount == 1 && is_client)
			{
				TileType tile = map.getTile(blob.getPosition() + Vec2f(0.0f, blob.getRadius() + 4.0f)).type;

				if (map.isTileGroundStuff(tile))
				{
					sprite.PlayRandomSound("/EarthJump");
				}
				else
				{
					sprite.PlayRandomSound("/StoneJump");
				}
			}
		}
	}

	//walking & stopping

	bool stop = true;
	if (!onground)
	{
		if (isknocked){
			stop = false;
		}
		else if (blob.hasTag("dont stop til ground")){
			stop = false;
		}
	}
	else
	{
		blob.Untag("dont stop til ground");
	}

	const bool left_or_right = (left || right);
	{
		// carrying heavy
		CBlob@ carryBlob = blob.getCarriedBlob();
		if (carryBlob !is null)
		{
			if (carryBlob.hasTag("medium weight"))
			{
				moveVars.walkFactor *= 0.8f;
				moveVars.jumpFactor *= 0.8f;
			}
			else if (carryBlob.hasTag("heavy weight"))
			{
				moveVars.walkFactor *= 0.6f;
				moveVars.jumpFactor *= 0.5f;
			}
		}

		Vec2f walkDirection;
		const f32 turnaroundspeed = 1.3f;
		const f32 normalspeed = 1.0f;
		const f32 backwardsspeed = 0.8f;

		if (right)
		{
			if (vel.x < -0.1f)
			{
				walkDirection.x += turnaroundspeed;
			}
			else if (facing_left)
			{
				walkDirection.x += backwardsspeed;
			}
			else
			{
				walkDirection.x += normalspeed;
			}
		}

		if (left)
		{
			if (vel.x > 0.1f)
			{
				walkDirection.x -= turnaroundspeed;
			}
			else if (!facing_left)
			{
				walkDirection.x -= backwardsspeed;
			}
			else
			{
				walkDirection.x -= normalspeed;
			}
		}

		f32 force = 1.0f;

		f32 lim = 0.0f;

		{
			if (left_or_right)
			{
				lim = moveVars.walkSpeed;
				if (!onground)
				{
					lim = moveVars.walkSpeedInAir;
				}

				lim *= moveVars.walkFactor * Maths::Abs(walkDirection.x);
			}

			Vec2f stop_force;

			const bool greater = vel.x > 0;
			f32 absx = greater ? vel.x : -vel.x;

			if (moveVars.walljumped)
			{
				moveVars.stoppingFactor *= 0.5f;
				moveVars.walkFactor *= 0.6f;

				//hack - fix gliding
				if (vel.y > 0 && blob.hasTag("shielded"))
					moveVars.walkFactor *= 0.6f;
			}

			bool stopped = false;
			if (absx > lim)
			{
				if (stop) //stopping
				{
					stopped = true;
					stop_force.x -= (absx - lim) * (greater ? 1 : -1);

					stop_force.x *= moveVars.overallScale * 30.0f * moveVars.stoppingFactor *
					                (onground ? moveVars.stoppingForce : moveVars.stoppingForceAir);

					if (absx > 3.0f)
					{
						f32 extra = (absx - 3.0f);
						f32 scale = (1.0f / ((1 + extra) * 2));
						stop_force.x *= scale;
					}

					blob.AddForce(stop_force);
				}
			}

			if (!isknocked && ((absx < lim) || left && greater || right && !greater))
			{
				force *= moveVars.walkFactor * moveVars.overallScale * 30.0f;
				if (Maths::Abs(force) > 0.01f)
				{
					blob.AddForce(walkDirection * force);
				}
			}
		}

	}

	//falling count
	if (!onground && vel.y > 0.1f)
	{
		moveVars.fallCount++;
	}
	else
	{
		moveVars.fallCount = 0;
	}

	CleanUp(this, blob, moveVars);
}

//some specific helpers

const f32 offsetheight = -1.2f;
bool canVault(CBlob@ blob, CMap@ map, f32 movingside)
{
	Vec2f pos = blob.getPosition();

	f32 tilesize = map.tilesize;
	if (!map.isTileSolid(Vec2f(pos.x + movingside * tilesize, pos.y + tilesize * (offsetheight))) &&
	        !map.isTileSolid(Vec2f(pos.x + movingside * tilesize, pos.y + tilesize * (offsetheight + 1))) &&
	        map.isTileSolid(Vec2f(pos.x + movingside * tilesize, pos.y + tilesize * (offsetheight + 2))))
	{

		bool hasRayFace = map.rayCastSolid(pos + Vec2f(0, -6), pos + Vec2f(movingside * 12, -6));
		if (hasRayFace)
			return false;

		bool hasRayFeet = map.rayCastSolid(pos + Vec2f(0, 6), pos + Vec2f(movingside * 12, 6));

		if (hasRayFeet)
			return true;

		//TODO: fix flags sync and hitting so we dont have to do this
		{
			return !checkForSolidMapBlob(map, pos + Vec2f(movingside * 12, -6)) &&
			       checkForSolidMapBlob(map, pos + Vec2f(movingside * 12, 6));
		}
	}
	return false;
}

//cleanup all vars here - reset clean slate for next frame

void CleanUp(CMovement@ this, CBlob@ blob, RunnerMoveVars@ moveVars)
{
	//reset all the vars here
	moveVars.jumpFactor = 1.0f;
	moveVars.walkFactor = 1.0f;
	moveVars.stoppingFactor = 1.0f;
	moveVars.wallsliding = false;
	moveVars.canVault = true;
}

//TODO: fix flags sync and hitting so we dont need this
// blob is an optional parameter to check collisions for, e.g. you don't want enemies to climb a trapblock
bool checkForSolidMapBlob(CMap@ map, Vec2f pos, CBlob@ blob = null)
{
	CBlob@ _tempBlob; CShape@ _tempShape;
	@_tempBlob = map.getBlobAtPosition(pos);
	if (_tempBlob !is null && _tempBlob.isCollidable())
	{
		@_tempShape = _tempBlob.getShape();
		if (_tempShape.isStatic())
		{
			if (_tempBlob.getName() == "wooden_platform")
			{
				f32 angle = _tempBlob.getAngleDegrees();
				if (angle > 180)
					angle -= 360;
				angle = Maths::Abs(angle);
				if (angle < 30 || angle > 150)
				{
					return false;
				}
			}

			if (blob !is null && !blob.doesCollideWithBlob(_tempBlob))
			{
				return false;
			}

			return true;
		}
	}

	return false;
}

//move us if we're stuck at the top of the map
void HandleStuckAtTop(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	//at top of map
	if (pos.y < 16.0f)
	{
		CMap@ map = getMap();
		float y = 2.5f * map.tilesize;
		//solid underneath
		if (map.isTileSolid(Vec2f(pos.x, y)))
		{
			//"stuck"; check left and right
			int rad = 10;
			bool found = false;
			float tx = pos.x;
			for (int i = 0; i < rad && !found; i++)
			{
				for (int dir = -1; dir <= 1 && !found; dir += 2)
				{
					tx = pos.x + (dir * i) * map.tilesize;
					if(!map.isTileSolid(Vec2f(tx, y)))
					{
						found = true;
					}
				}
			}
			if (found)
			{
				Vec2f towards(tx - pos.x, -1);
				towards.Normalize();
				this.setPosition(pos + towards * 0.5f);
				this.AddForce(towards * 10.0f);
			}
		}
	}
}
