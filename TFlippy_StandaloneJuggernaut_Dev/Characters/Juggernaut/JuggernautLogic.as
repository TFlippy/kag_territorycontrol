// Juggernaut logic

#include "ThrowCommon.as"
#include "JuggernautCommon.as";
#include "KnightCommon.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";;
#include "ShieldCommon.as";
#include "Knocked.as";
#include "Requirements.as";
#include "ParticleSparks.as";
#include "MakeDustParticle.as";

//attacks limited to the one time per-actor before reset.
void juggernaut_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool juggernaut_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 juggernaut_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void juggernaut_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void juggernaut_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	this.Tag("player");
	this.Tag("flesh");
	this.Tag("human");
	this.Tag("dangerous");
	this.Tag("heavy weight");

	JuggernautInfo juggernaut;

	juggernaut.state = JuggernautStates::normal;
	juggernaut.prevState = JuggernautStates::normal;
	juggernaut.actionTimer = 0;
	juggernaut.attackDelay = 0;

	this.set("JuggernautInfo", @juggernaut);

	this.set_f32("gib health", 0.0f);

	juggernaut_actorlimit_setup(this);

	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";

	if (isClient())
	{
		Random@ rand = Random(this.getNetworkID());
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSound("Juggernaut_Music_" + rand.NextRanged(3));
		sprite.SetEmitSoundVolume(1.5f);
		sprite.SetEmitSoundPaused(false);
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 10, Vec2f(16, 16));
}

void onTick(CBlob@ this)
{
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars)) return;

	JuggernautInfo@ juggernaut;
	if (!this.get("JuggernautInfo", @juggernaut)) return;

	juggernaut.prevState = juggernaut.state;

	Vec2f vec;
	const int direction = this.getAimDirection(vec);
	const f32 side = (this.isFacingLeft() ? 1.0f : -1.0f);

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f aimPos = this.getAimPos();

	bool pressed_lmb = this.isKeyPressed(key_action1) && !this.hasTag("noLMB");
	bool pressed_rmb = this.isKeyPressed(key_action2) && !this.hasTag("noLMB");
	bool pressed_v = this.isKeyPressed(key_eat);

	float attackJumpFactor = 0.375f;
	float attackWalkFactor = 0.4f;

	if (this.isMyPlayer()) getHUD().SetCursorFrame(0);

	if (juggernaut.state == JuggernautStates::stun)
	{
		moveVars.jumpFactor = 0.0f;
		moveVars.walkFactor = 0.0f;
		juggernaut.actionTimer = 0;
		juggernaut.stun--;
		if (juggernaut.stun <= 0) juggernaut.state = JuggernautStates::normal;
	}
	else if (juggernaut.state == JuggernautStates::normal)
	{
		//Normal
		if (juggernaut.attackDelay > 0) juggernaut.attackDelay--;
		else if (pressed_lmb)
		{
			juggernaut.state = JuggernautStates::charging;
			juggernaut.actionTimer = 0;
		}
		if (this.isKeyJustPressed(key_action2) && !this.hasTag("noLMB"))
		{
			f32 angle = -((aimPos - pos).getAngleDegrees());
			if (angle < 0.0f) angle += 360.0f;
			Vec2f dir = Vec2f(1.0f, 0.0f).RotateBy(angle);
			juggernaut.attackDirection = dir;
			juggernaut.attackAimPos = aimPos;
			juggernaut.attackRot = angle;
			angle = (aimPos - pos).Angle();
			juggernaut.attackTrueRot = angle;

			juggernaut.wasFacingLeft = this.isFacingLeft();
			juggernaut.state = JuggernautStates::grabbing;
			juggernaut.actionTimer = 0;

			if (isClient()) Sound::Play("/ArgLong", pos);
		}
	}
	else if (juggernaut.state == JuggernautStates::charging)
	{
		//Charging hammer attack
		moveVars.jumpFactor *= attackJumpFactor;
		moveVars.walkFactor *= attackWalkFactor;
		juggernaut.actionTimer += 1;

		f32 angle = -((aimPos - pos).getAngleDegrees());
		if (angle < 0.0f) angle += 360.0f;
		Vec2f dir = Vec2f(1.0f, 0.0f).RotateBy(angle);
		juggernaut.attackDirection = dir;
		juggernaut.attackAimPos = aimPos;
		juggernaut.attackRot = angle;
		angle = (aimPos - pos).Angle();
		juggernaut.attackTrueRot = angle;

		juggernaut.wasFacingLeft = this.isFacingLeft();

		if (juggernaut.actionTimer >= JuggernautVars::chargeTime)
		{
			juggernaut.state = JuggernautStates::chargedAttack;
			juggernaut.actionTimer = 0;

			if (isClient())
			{
				Sound::Play("/ArgLong", pos);
				PlaySoundRanged(this, "SwingHeavy", 4, 1.0f, 1.0f);
			}
			Vec2f force = juggernaut.attackDirection * this.getMass() * 3.0f;
			this.AddForce(force);
		}
	}
	else if (juggernaut.state == JuggernautStates::chargedAttack)
	{
		//Attacking with the hammer
		moveVars.jumpFactor *= attackJumpFactor;
		moveVars.walkFactor *= attackWalkFactor;
		this.SetFacingLeft(juggernaut.wasFacingLeft);

		if (juggernaut.actionTimer >= JuggernautVars::attackTime)
		{
			juggernaut.state = JuggernautStates::normal;
			juggernaut.actionTimer = 0;
			juggernaut.attackDelay = JuggernautVars::attackDelay;
		}
		else if (juggernaut.actionTimer < 12) DoAttack(this, 8.0f, juggernaut, 120.0f, HittersTC::hammer, juggernaut.actionTimer);

		juggernaut.actionTimer += 1;
	}
	else if (juggernaut.state == JuggernautStates::grabbing)
	{
		//Trying to grab another player
		moveVars.jumpFactor *= attackJumpFactor;
		moveVars.walkFactor *= attackWalkFactor;
		//this.SetFacingLeft(juggernaut.wasFacingLeft);

		if (juggernaut.actionTimer >= JuggernautVars::grabTime)
		{
			juggernaut.state = JuggernautStates::grabbed;
			juggernaut.actionTimer = 0;
			juggernaut.attackDelay = JuggernautVars::attackDelay * 2;
		}
		else if (juggernaut.actionTimer <= (JuggernautVars::grabTime / 4) * 3)
		{
			//Grab
			const float range = 28.0f; //36.0f originally
			f32 angle = juggernaut.attackRot;
			Vec2f dir = juggernaut.attackDirection;

			Vec2f startPos = pos + Vec2f(0.0f, 5.0f);
			Vec2f endPos = startPos + (dir * range);

			HitInfo@[] hitInfos;
			Vec2f hitPos;
			bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
			f32 length = (hitPos - startPos).Length();

			bool blobHit = getMap().getHitInfosFromRay(startPos, angle, length, this, @hitInfos);
			if (blobHit)
			{
				for (u32 i = 0; i < hitInfos.length; i++)
				{
					if (hitInfos[i].blob !is null)
					{
						CBlob@ blob = hitInfos[i].blob;
						if (blob.hasTag("player") && blob.getTeamNum() != this.getTeamNum() && 
						   !blob.hasTag("dead") && !blob.hasTag("invincible"))
						{
							//disabled on TC since it is already compensated for in shieldhit.as
							/*if (blob.getName() == "knight")
							{
								if (blockAttack(blob, dir, 0.0f))
								{
									Sound::Play("Entities/Characters/Knight/ShieldHit.ogg", pos);
									sparks(pos, -dir.Angle(), Maths::Max(10.0f * 0.05f, 1.0f));
									juggernaut.dontHitMore = true;
									break;
								}
								else
								{
									KnightInfo@ knight;
									if (this.get("KnightInfo",@knight))
									{
										if (inMiddleOfAttack(knight.state)) break;
									}
								}
							}*/
							string blobName = blob.getName();
							if ((blob.getHealth() <= 1.0f || isKnocked(blob)) &&
							    blobName != "slave" && blobName != "juggernaut")
							{
								AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("CORPSE");
								if (point !is null)
								{
									this.server_AttachTo(blob, point);

									if (isClient()) 
									{
										blob.getSprite().PlaySound("Agh.ogg");
										blob.getSprite().SetRelativeZ(blob.getSprite().getRelativeZ() - 5);
									}
								}
								juggernaut.attackDelay = 15;
								juggernaut.state = JuggernautStates::grabbed;

							}
							else if (getGameTime() >= this.get_u32("nextHit"))
							{
								if (isServer()) this.server_Hit(blob, hitPos, dir, 0.25f, Hitters::flying, false);
								this.set_u32("nextHit", getGameTime() + 15); //shite anti loop
							}
							break;
						}
					}
				}
			}
		}
		juggernaut.actionTimer += 1;
	}
	else if (juggernaut.state == JuggernautStates::grabbed)
	{
		//Holding someone by the neck
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("CORPSE");
		if (point !is null)
		{
			CBlob@ attachedBlob = point.getOccupied();
			if (attachedBlob !is null)
			{
				if (getKnocked(attachedBlob) <= 1) SetKnocked(attachedBlob, 30); //continuously stun
				attachedBlob.SetFacingLeft(!this.isFacingLeft());

				if (pressed_v || isKnocked(this)) //detach the carried player
				{
					if (isClient()) attachedBlob.getSprite().SetRelativeZ(attachedBlob.getSprite().getRelativeZ() - 5);
					attachedBlob.server_DetachFrom(this);
					juggernaut.state = JuggernautStates::normal;
				}
			}
		}
		if (juggernaut.attackDelay > 0) juggernaut.attackDelay--;
		else if (pressed_lmb)
		{
			//Throw whoever is grabbed
			f32 Angle = (aimPos - pos).Angle();
			juggernaut.attackTrueRot = Angle;

			juggernaut.state = JuggernautStates::throwing;
			juggernaut.actionTimer = 0;
			if (isClient()) Sound::Play("/ArgLong", pos);

			f32 angle = -((aimPos - pos).getAngleDegrees());
			if (angle < 0.0f) angle += 360.0f;

			Vec2f dir = Vec2f(1.0f, 0.0f).RotateBy(angle);

			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("CORPSE");
			if (point !is null)
			{
				CBlob@ attachedBlob = point.getOccupied();
				if (attachedBlob !is null)
				{
					attachedBlob.server_DetachFrom(this);
					attachedBlob.setVelocity(dir * 12.0f);
					attachedBlob.AddScript("Corpse.as");
					if (this.getPlayer() !is null) attachedBlob.SetDamageOwnerPlayer(this.getPlayer());
					if (isClient()) attachedBlob.getSprite().PlaySound("Wilhelm.ogg");
				}
			}
		}
		else if (pressed_rmb && this.isOnGround() && this.isKeyJustPressed(key_action2))
		{
			//Start a fatality
			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("CORPSE");
			if (point !is null)
			{
				CBlob@ attachedBlob = point.getOccupied();
				if (attachedBlob !is null)
				{
					juggernaut.state = JuggernautStates::fatality;
					juggernaut.actionTimer = 0;
					juggernaut.wasFacingLeft = this.isFacingLeft();
				}
			}
		}
	}
	else if (juggernaut.state == JuggernautStates::throwing)
	{
		//Throwing
		if (juggernaut.actionTimer >= JuggernautVars::throwTime)
		{
			juggernaut.state = JuggernautStates::normal;
			juggernaut.actionTimer = 0;
			juggernaut.attackDelay = JuggernautVars::attackDelay;
		}
		juggernaut.actionTimer += 1;
	}
	else if (juggernaut.state == JuggernautStates::fatality)
	{
		//RMB Fatality
		moveVars.jumpFactor = 0.0f;
		moveVars.walkFactor = 0.0f;
		this.getShape().SetVelocity(Vec2f_zero);
		if (!this.hasTag("invincible")) this.Tag("invincible");
		this.SetFacingLeft(juggernaut.wasFacingLeft);

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("CORPSE");
		if (point !is null)
		{
			CBlob@ attachedBlob = point.getOccupied();
			if (attachedBlob !is null)
			{
				attachedBlob.SetFacingLeft(this.isFacingLeft());
				if (juggernaut.actionTimer == 26)
				{
					attachedBlob.Tag("dead");
					point.offset.y = 3.0f;
					point.offset.x = 16.0f;
				}
				if (juggernaut.actionTimer == 46)
				{
					attachedBlob.Untag("dead");

					//kill blob
					if (isServer())
					{
						attachedBlob.server_SetHealth(0.25f);
						this.server_Hit(attachedBlob, attachedBlob.getPosition(), Vec2f(0, 0), 3.0f, Hitters::stomp, false);
					}

					if (isClient()) attachedBlob.getSprite().SetRelativeZ(attachedBlob.getSprite().getRelativeZ() + 5);
					attachedBlob.server_DetachFrom(this);

					//reset CORPSE attachment point
					point.offset.y = -6.0f;
					point.offset.x = 12.0f;
				}
			}
		}
		if (isClient())
		{
			if (juggernaut.actionTimer == 3) Sound::Play("ArgShort.ogg", pos, 1.0f);
			else if (juggernaut.actionTimer == 20) Sound::Play("ArgLong.ogg", pos, 1.0f);
			else if (juggernaut.actionTimer == 29)
			{
				ShakeScreen(6.0f, 5, this.getPosition());
				Sound::Play("FallOnGround.ogg", pos, 0.4f);
			}
			else if (juggernaut.actionTimer == 45) ShakeScreen(25.0f, 6, pos);
			else if (juggernaut.actionTimer == 46)
			{
				Vec2f posOffset = pos + Vec2f(this.isFacingLeft() ? -25 : 25,3);
				ParticleBloodSplat(posOffset, true);
				for (int i = 0; i < 12; i++)
				{
					Vec2f vel = getRandomVelocity(float(XORRandom(360)), 1.0f + float(XORRandom(2)), 60.0f);
					makeGibParticle("mini_gibs.png", posOffset, vel, 0, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 20, "/BodyGibFall", 0);
				}
			}
			else if (juggernaut.actionTimer == 48) Sound::Play("Gore.ogg", pos, 1.0f);
		}
		if (juggernaut.actionTimer >= JuggernautVars::fatalityTime)
		{
			juggernaut.state = JuggernautStates::normal;
			juggernaut.actionTimer = 0;
			this.Untag("invincible");
		}
		juggernaut.actionTimer += 1;
	}

	if (juggernaut.state != JuggernautStates::charging && juggernaut.state != JuggernautStates::chargedAttack)
	{
		if (isServer()) juggernaut_clear_actor_limits(this);
	}

	//Force sync for grabbing due to absolutely terrible engine issues
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("CORPSE");
	if (point !is null)
	{
		CBlob@ attachedBlob = point.getOccupied();
		if (attachedBlob !is null)
		{
			if (juggernaut.state != JuggernautStates::grabbed && juggernaut.state != JuggernautStates::fatality) 
			{
				juggernaut.state = JuggernautStates::grabbed;
			}
		}
		else if (juggernaut.state == JuggernautStates::grabbed) juggernaut.state = JuggernautStates::normal;
	}
}

void PlaySoundRanged(CBlob@ this, string sound, int range, float volume, float pitch)
{
	this.getSprite().PlaySound(sound + (range > 1 ? formatInt(XORRandom(range - 1) + 1, "") + ".ogg" : ".ogg"), volume, pitch);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.hasTag("invincible")) return 0.0f;
	if (customData == Hitters::water_stun || customData == Hitters::fire)
	{
		SetKnocked(this, 5); //also releases any players that are carried
	}
	return damage;
}

void onDie(CBlob@ this)
{
	if (isClient()) this.getSprite().PlaySound("Juggernaut_Death.ogg", 1.00f, this.getSexNum() == 0 ? 1.0f : 2.0f);
	if (isServer()) server_CreateBlob("juggernauthammer", this.getTeamNum(), this.getPosition());
}

void DoAttack(CBlob@ this, f32 damage, JuggernautInfo@ info, f32 arcDegrees, u8 type, int deltaInt)
{
	f32 aimangle =- (info.attackDirection.Angle());
	if (aimangle < 0.0f) aimangle += 360.0f;

	f32 exact_aimangle = info.attackTrueRot;
	Vec2f aimPos = info.attackAimPos;
	//get the actual aim angle

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(DEFAULT_ATTACK_DISTANCE + Maths::Max(0.0f, 1.75f * this.getShape().vellen *(vel * thinghy)), MAX_ATTACK_DISTANCE);

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;
	bool hasHitBlob = false;
	bool hasHitMap = false;

	if (isServer() && (blobPos - aimPos).Length() <= attack_distance * 1.5f) DamageWall(this, map, aimPos);

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcDegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;

			if (b !is null && !dontHitMore && deltaInt <= JuggernautVars::attackTime - 9) // blob
			{
				//big things block attacks
				const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

				if (!canHit(this, b) || juggernaut_has_hit_actor(this, b))
				{
					// no TK
					if (large) dontHitMore = true;
					continue;
				}

				juggernaut_add_actor_limit(this, b);
				if (!dontHitMore)
				{
					if (isServer())
					{
						Vec2f velocity = b.getPosition() - pos;
						this.server_Hit(b, hi.hitpos, velocity, damage, type, true);
					}

					// end hitting if we hit something solid, don't if its flesh
					if (large) dontHitMore = true;
				}
				hasHitBlob = true;
			}
			else if (!dontHitMoreMap && (deltaInt == DELTA_BEGIN_ATTACK + 1)) // hitmap
			{
				Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
				Vec2f offset = (tpos - blobPos);
				f32 tileangle = offset.Angle();
				f32 dif = Maths::Abs(exact_aimangle - tileangle);
				if (dif > 180) dif -= 360;
				if (dif < -180) dif += 360;

				dif = Maths::Abs(dif);

				if (dif < 30.0f)
				{
					hasHitMap = true;

					if (isClient()) MakeDustParticle(tpos, "dust2.png");

					if (map.getSectorAtPosition(tpos,"no build") !is null) continue;

					TileType tile = map.getTile(hi.hitpos).type;
					if (!map.isTileBedrock(tile)) map.server_DestroyTile(hi.hitpos, 1000.0f, this);

					for (int i = 0; i < 5; i++)
					{
						Vec2f pos = hi.hitpos + getRandomVelocity(0, 24, 360);

						if (isClient() && XORRandom(100) < 50) MakeDustParticle(pos, "dust2.png");

						if (isServer()) getMap().server_DestroyTile(pos, 0.005f);
					}
				}
			}
		}
		if (hasHitBlob || hasHitMap) 
		{
			ShakeScreen(48.0f, 15.0f, this.getPosition());
			this.getSprite().PlaySound("FallBig" + (1 + XORRandom(5)), 1.00f, 1.00f);

			if (!hasHitBlob) PlaySoundRanged(this,"HammerHit",3,1.0f,1.0f);
		}
	}

	// destroy grass
	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f) && // aiming down or slash
	(deltaInt == DELTA_BEGIN_ATTACK + 1)) // hit only once
	{
		f32 tilesize = map.tilesize;
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = this.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
		{
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos, damage, this);

					if (damage <= 1.0f) return;
				}
			}
		}
	}
}

void DamageWall(CBlob@ this, CMap@ map, Vec2f pos)
{
	if (pos.x < 0.0f || pos.x >= map.tilemapwidth * 8.0f || pos.y < 0.0f || pos.y >= map.tilemapheight * 8.0f) return;

	Tile tile = map.getTile(pos);
	if (map.isTileBackground(tile) && !map.isTileGroundBack(tile.type))
	{
		tile.type = CMap::TileEnum::tile_empty;
		map.server_SetTile(pos, tile);
	}
}

bool canHit(CBlob@ this, CBlob@ b)
{
	// Decipher what blobs we can hurt
	if (b.hasTag("invincible")) return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{
		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null && carrier.hasTag("player"))
		{
			if (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")) return false;
		}
	}

	if (b.hasTag("dead")) return true;

	return b.getTeamNum() != this.getTeamNum();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	f32 vellen = this.getOldVelocity().Length();

	if (solid && vellen > 6.0f)
	{
		int count = vellen;
		for (int i = 0; i < count; i++)
		{
			Vec2f pos = point1 + getRandomVelocity(-normal.Angle(), 2.0f * i, Maths::Min(15 * i, 80));

			if (isClient() && XORRandom(100) < 50) MakeDustParticle(pos, "dust2.png");
			//if (isServer()) getMap().server_DestroyTile(pos, 0.005f * vellen);
		}
		if (isClient())
		{
			this.getSprite().PlaySound("FallBig" + (XORRandom(5) + 1), vellen / 8.0f + 0.2f, 1.1f - vellen / 45.0f);
			ShakeScreen(vellen * 10.0f, vellen * 4.0f, this.getPosition());
		}
	}
}
