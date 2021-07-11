// Ninja logic

#include "ThrowCommon.as"
#include "NinjaCommon.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "ShieldCommon.as";
#include "Knocked.as"
#include "Help.as";
#include "Requirements.as"
#include "CustomBlocks.as";


//attacks limited to the one time per-actor before reset.

void ninja_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool ninja_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 ninja_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void ninja_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void ninja_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	NinjaInfo ninja;

	ninja.state = NinjaStates::normal;
	ninja.swordTimer = 0;
	ninja.slideTime = 0;
	ninja.doubleslash = false;
	ninja.tileDestructionLimiter = 0;

	this.set("ninjaInfo", @ninja);

	this.set_f32("gib health", -3.0f);
	addShieldVars(this, SHIELD_BLOCK_ANGLE, 2.0f, 5.0f);
	ninja_actorlimit_setup(this);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.Tag("player");
	this.Tag("flesh");
	this.Tag("human");

	this.set_s16("jumps", 2);
	this.set_s16("jump_time", 0);

	// this.push("names to activate", "keg");

	//centered on inventory
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";

	this.getSprite().PlaySound("yooooooooooo.ogg", 0.4f, 1.0f);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 6, Vec2f(16, 16));

		this.setInventoryName("The Relentless X");

		// if (isServer()) player.server_setCharacterName("The Relentless X");
	}
}


void onTick(CBlob@ this)
{
	u8 knocked = getKnocked(this);

	if (this.isInInventory())
		return;

	//ninja logic stuff
	//get the vars to turn various other scripts on/off
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	moveVars.jumpFactor *= 1.5f;
	moveVars.walkFactor *= 1.2f;

	NinjaInfo@ ninja;
	if (!this.get("ninjaInfo", @ninja))
	{
		return;
	}

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f aimpos = this.getAimPos();
	const bool inair = (!this.isOnGround() && !this.isOnLadder());

	Vec2f vec;

	const int direction = this.getAimDirection(vec);
	const f32 side = (this.isFacingLeft() ? 1.0f : -1.0f);

	bool swordState = isSwordState(ninja.state);
	bool pressed_a1 = this.isKeyPressed(key_action1) && !(this.get_f32("babbyed") > 0);
	bool pressed_a2 = this.isKeyPressed(key_action2) && !(this.get_f32("babbyed") > 0);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	const bool myplayer = this.isMyPlayer();

	//with the code about menus and myplayer you can slash-cancel;
	//we'll see if ninjas dmging stuff while in menus is a real issue and go from there
	if (knocked > 0 || (myplayer && getHUD().hasMenus()))// || myplayer && getHUD().hasMenus())
	{
		ninja.state = NinjaStates::normal;
		ninja.swordTimer = 0;
		ninja.slideTime = 0;
		ninja.doubleslash = false;

		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;

	}
	else if ((pressed_a1 || swordState))
	{
		if (ninja.state == NinjaStates::normal ||
		        this.isKeyJustPressed(key_action1) &&
		        (!inMiddleOfAttack(ninja.state)))
		{
			ninja.state = NinjaStates::sword_drawn;
			ninja.swordTimer = 0;
		}

		if (ninja.state == NinjaStates::sword_drawn && isServer())
		{
			ninja_clear_actor_limits(this);
		}

		//responding to releases/noaction
		s32 delta = ninja.swordTimer;
		if (ninja.swordTimer < 32)
			ninja.swordTimer++;

		if (ninja.state == NinjaStates::sword_drawn && !pressed_a1 && !(this.isKeyJustReleased(key_action1) || ninja.swordTimer > 4) && delta > NinjaVars::resheath_time)
		{
			ninja.state = NinjaStates::normal;
		}
		else if ((this.isKeyJustReleased(key_action1) || ninja.swordTimer > 4) && ninja.state == NinjaStates::sword_drawn)
		{
			ninja.swordTimer = 0;

			if (delta < 32)
			{
				if (direction == -1)
				{
					ninja.state = NinjaStates::sword_cut_up;
				}
				else if (direction == 0)
				{
					if (aimpos.y < pos.y)
					{
						ninja.state = NinjaStates::sword_cut_mid;
					}
					else
					{
						ninja.state = NinjaStates::sword_cut_mid_down;
					}
				}
				else
				{
					ninja.state = NinjaStates::sword_cut_down;
				}
			}
			else
			{
				//knock?
			}
		}
		else if (ninja.state >= NinjaStates::sword_cut_mid && ninja.state <= NinjaStates::sword_cut_down) // cut state
		{
			if (delta == DELTA_BEGIN_ATTACK)
			{
				Sound::Play("/SwordSlash", this.getPosition());
			}

			if (delta > DELTA_BEGIN_ATTACK && delta < DELTA_END_ATTACK)
			{
				f32 attackarc = 90.0f;
				f32 attackAngle = getCutAngle(this, ninja.state);

				if (ninja.state == NinjaStates::sword_cut_down)
				{
					attackarc *= 0.9f;
				}

				DoAttack(this, 1.00f, attackAngle, attackarc, HittersTC::staff, delta, ninja);
			}
			else if (delta >= 9)
			{
				ninja.swordTimer = 0;
				ninja.state = NinjaStates::sword_drawn;
			}
		}

	}
	else if (pressed_a2)
	{
		if (this.get_bool("can_leap") && getGameTime() > this.get_u32("leap timer"))
		{
			this.AddForce(Vec2f(vel.x * -5.0, 0.0f));   //horizontal slowing force (prevents SANICS)

			if (this.isKeyPressed(key_action2))
			{
				Vec2f velocity = this.getAimPos() - this.getPosition();
				velocity.Normalize();
				// velocity.y *= 0.5f;

				this.setVelocity(velocity * 8);
				// this.getSprite().PlaySound("Ninja_Attack" + XORRandom(4), 0.75f, 1.00f);
				this.getSprite().PlaySound("ArgLong");
				this.set_u32("leap timer", getGameTime() + 40);

				this.set_bool("can_leap", false);
			}
		}
	}
	else if (this.isKeyJustReleased(key_action2) || this.isKeyJustReleased(key_action1) || this.get_u32("ninja_timer") <= getGameTime())
	{
		ninja.state = NinjaStates::normal;
	}

	if (getGameTime() < this.get_u32("leap timer") && !this.isOnGround())
	{
		Vec2f vel = this.getVelocity();
		if (Maths::Abs(vel.x) > 0.1)
		{
			f32 angle = this.get_f32("angle");
			angle += vel.x * this.getRadius();
			if (angle > 360.0f)
				angle -= 360.0f;
			else if (angle < -360.0f)
				angle += 360.0f;
			this.set_f32("angle", angle);
			this.setAngleDegrees(angle);
		}
	}
	else
	{
		this.setAngleDegrees(0);
	}

	if (myplayer)
	{
		// help

		if (this.isKeyJustPressed(key_action1) && getGameTime() > 150)
		{
			SetHelp(this, "help self action", "ninja", "$Slash$ Slash!    $KEY_HOLD$$LMB$", "", 13);
		}

		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}
	}

	if (this.isOnGround()) this.set_bool("can_leap", true);

	// if(this.get_s16("jumps") > 0)
	// if(!this.hasTag("cant_jump"))
	// if(knocked <= 0 && (!inair || this.isOnWall()))
	// if(this.isKeyPressed(key_action2)){
		// Vec2f jumpVel = this.getAimPos()-this.getPosition();
		// jumpVel.Normalize();
		// this.setVelocity(jumpVel*10);
		// this.Tag("cant_jump");
		// this.set_s16("jumps",this.get_s16("jumps")-1);
	// }
	
	// if(this.get_s16("jumps") < 2){
		// this.set_s16("jump_time",this.get_s16("jump_time") + 1);
		// if(this.get_s16("jump_time") > 90){
			// this.set_s16("jump_time",0);
			// this.set_s16("jumps",2);
		// }
	// }

	if(knocked > 0 || inair && !this.isOnWall())this.Untag("cant_jump");

	if (!swordState && isServer())
	{
		ninja_clear_actor_limits(this);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
}

void onDie(CBlob@ this)
{
	if (isServer()) server_CreateBlob("ninjascroll", this.getTeamNum(), this.getPosition());
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	const bool miss = int(worldPoint.x * 100 % (worldPoint.y * 100 + (worldPoint.x % 4)) + worldPoint.y) % 3 != 0; // Crappy fake random, but has to be synchronized between client and server
	// print("" +  int(worldPoint.x % (worldPoint.y + (worldPoint.x % 4)) * worldPoint.y));

	switch (customData)
	{
		case HittersTC::bullet_high_cal:
		case HittersTC::bullet_low_cal:
			if (miss)
			{
				dmg = 0;
				this.getSprite().PlaySound("BulletDodge" + XORRandom(3), 0.75f, 1.00f);
			}
			break;

		case Hitters::fall:
			dmg *= 0.25f;
			break;
	}

	return dmg;
}

/////////////////////////////////////////////////

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, u8 type, int deltaInt, NinjaInfo@ info)
{
	if (!isServer())
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(DEFAULT_ATTACK_DISTANCE + Maths::Max(0.0f, 1.75f * this.getShape().vellen * (vel * thinghy)), MAX_ATTACK_DISTANCE);

	f32 radius = this.getRadius() + 1.0f;
	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;
	const bool jab = false;

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore) // blob
			{
				if (b.hasTag("ignore sword")) continue;

				//big things block attacks
				const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

				if (!canHit(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (ninja_has_hit_actor(this, b))
				{
					if (large)
						dontHitMore = true;

					continue;
				}

				ninja_add_actor_limit(this, b);
				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity, damage, type, true);  // server_Hit() is server-side only

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
			else  // hitmap
				if (!dontHitMoreMap && (deltaInt == DELTA_BEGIN_ATTACK + 1))
				{
					bool ground = map.isTileGround(hi.tile);
					bool dirt_stone = map.isTileStone(hi.tile);
					bool gold = map.isTileGold(hi.tile);
					bool wood = map.isTileWood(hi.tile);
					bool glass = ((hi.tile >= CMap::tile_glass && hi.tile <= CMap::tile_glass_d0) ? true : false);
					bool tnt = (hi.tile == CMap::tile_tnt ? true : false);
					bool kudzu = isTileKudzu(hi.tile);
					if (ground || wood || dirt_stone || gold)
					{
						Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
						Vec2f offset = (tpos - blobPos);
						f32 tileangle = offset.Angle();
						f32 dif = Maths::Abs(exact_aimangle - tileangle);
						if (dif > 180)
							dif -= 360;
						if (dif < -180)
							dif += 360;

						dif = Maths::Abs(dif);
						//print("dif: "+dif);

						if (dif < 20.0f)
						{
							//detect corner

							int check_x = -(offset.x > 0 ? -1 : 1);
							int check_y = -(offset.y > 0 ? -1 : 1);
							if (map.isTileSolid(hi.hitpos - Vec2f(map.tilesize * check_x, 0)) &&
							        map.isTileSolid(hi.hitpos - Vec2f(0, map.tilesize * check_y)))
								continue;

							bool canhit = true; //default true if not jab
							if (jab) //fake damage
							{
								info.tileDestructionLimiter++;
								canhit = ((info.tileDestructionLimiter % ((wood || dirt_stone) ? 3 : 2)) == 0);
							}
							else //reset fake dmg for next time
							{
								info.tileDestructionLimiter = 0;
							}

							//dont dig through no build zones
							canhit = canhit && map.getSectorAtPosition(tpos, "no build") is null;

							dontHitMoreMap = true;
							if (canhit)
							{
								map.server_DestroyTile(hi.hitpos, 0.1f, this);
							}
						}
					}
					else if (glass || tnt || kudzu)
					{
						dontHitMoreMap = true;
						map.server_DestroyTile(hi.hitpos, 0.1f, this);
					}
				}
		}
	}

	// destroy grass

	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f) &&    // aiming down or slash
	        (deltaInt == DELTA_BEGIN_ATTACK + 1)) // hit only once
	{
		f32 tilesize = map.tilesize;
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = this.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos, damage, this);

					if (damage <= 1.0f)
					{
						return;
					}
				}
			}
	}
}

bool isSliding(NinjaInfo@ ninja)
{
	return (ninja.slideTime > 0 && ninja.slideTime < 45);
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	//return if we didn't collide or if it's teamie
	if (blob is null || !solid || this.getTeamNum() == blob.getTeamNum())
	{
		return;
	}

	Vec2f dir = this.getOldVelocity();
	f32 vellen = dir.Length();
	dir.Normalize();

	if (vellen < 1.5f || getGameTime() > this.get_u32("leap timer")) return;

	f32 dmg = Maths::Clamp(vellen, 0, 6) / 3.0f;

	blob.setVelocity(dir * vellen * 0.8f);

	if (isClient()) this.getSprite().PlaySound("Ninja_Attack" + XORRandom(4), 0.75f, this.getSexNum() == 0 ? 1.0f : 2.0f);
	if (isServer()) 
	{
		if (blob.hasTag("flesh") || blob.hasTag("wooden"))
		{
			this.server_Hit(blob, this.getPosition(), dir, dmg, Hitters::stomp);
		}
	}
}


//a little push forward

void pushForward(CBlob@ this, f32 normalForce, f32 pushingForce, f32 verticalForce)
{
	f32 facing_sign = this.isFacingLeft() ? -1.0f : 1.0f ;
	bool pushing_in_facing_direction =
	    (facing_sign < 0.0f && this.isKeyPressed(key_left)) ||
	    (facing_sign > 0.0f && this.isKeyPressed(key_right));
	f32 force = normalForce;

	if (pushing_in_facing_direction)
	{
		force = pushingForce;
	}

	this.AddForce(Vec2f(force * facing_sign , verticalForce));
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	NinjaInfo@ ninja;
	if (!this.get("ninjaInfo", @ninja))
	{
		return;
	}

	if (customData == HittersTC::staff &&
	        ( //is a jab - note we dont have the dmg in here at the moment :/
	            ninja.state == NinjaStates::sword_cut_mid ||
	            ninja.state == NinjaStates::sword_cut_mid_down ||
	            ninja.state == NinjaStates::sword_cut_up ||
	            ninja.state == NinjaStates::sword_cut_down
	        )
	        && blockAttack(hitBlob, velocity, 0.0f))
	{
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
		SetKnocked(this, 30);
	}

	if (customData == Hitters::shield)
	{
		SetKnocked(hitBlob, 10);
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
	}
}

// Blame Fuzzle.
bool canHit(CBlob@ this, CBlob@ b)
{

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}
