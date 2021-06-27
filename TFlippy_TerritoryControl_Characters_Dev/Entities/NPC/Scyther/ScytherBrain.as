// Princess brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
//#include "LoaderUtilities.as";
#include "CustomBlocks.as";
#include "RunnerCommon.as";
#include "HittersTC.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png",
	"LargeFire.png",
	"FireFlash.png",
};

void onInit( CBrain@ this )
{
	if (isServer())
	{
		InitBrain( this );
		this.server_SetActive( true ); // always running
	}
}

void onInit(CBlob@ this)
{
	this.set_u32("next sound", 0.0f);

	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 20, 0));

	this.set_string("custom_explosion_sound", "MithrilBomb_Explode.ogg");
	this.set_bool("map_damage_raycast", true);
	this.set_Vec2f("explosion_offset", Vec2f(0, 0));

	this.set_f32("bomb angle", 90);
	this.Tag("map_damage_dirt");

	this.set_u32("nextAttack", 0);

	this.set_f32("minDistance", 16);
	this.set_f32("chaseDistance", 100);
	this.set_f32("maxDistance", 600);

	this.set_f32("inaccuracy", 0.00f);
	this.set_u8("reactionTime", 0);
	this.set_u8("attackDelay", 0);

	this.set_bool("raider", true);

	this.SetDamageOwnerPlayer(null);

	this.Tag("npc");
	this.Tag("player");

	this.getCurrentScript().tickFrequency = 30;

	if (isClient())
	{
		client_AddToChat("A Scyther has arrived!", SColor(255, 255, 0, 0));
		Sound::Play("scyther-intro.ogg");
	}

	if (isServer())
	{
		this.server_setTeamNum(251);

		for (int i = 0; i < 2; i++)
		{
			CBlob@ ammo = server_CreateBlob("mat_lancerod", this.getTeamNum(), this.getPosition());
			ammo.server_SetQuantity(50);
			this.server_PutInInventory(ammo);
		}

		CBlob@ lance = server_CreateBlob("chargelance", this.getTeamNum(), this.getPosition());
		if(lance !is null)
		{
			this.server_Pickup(lance);
		}
	}
}

void onTick(CBlob@ this)
{
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 1.50f;
		moveVars.jumpFactor *= 1.50f;
		moveVars.wallclimbing = true;
		moveVars.wallsliding = true;
	}

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound"))
		{
			this.getSprite().PlaySound("/scyther-laugh" + XORRandom(2) + ".ogg");
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
}

void onTick(CBrain@ this)
{
	if (!isServer()) return;

	CBlob@ blob = this.getBlob();

	if (blob.getPlayer() !is null) return;

	const f32 chaseDistance = blob.get_f32("chaseDistance");
	const f32 maxDistance = blob.get_f32("maxDistance");

	CBlob@ target = this.getTarget();

	// print("" + target.getConfig());

	if (target is null)
	{
		this.SetTarget(FindTarget(this, maxDistance));
		this.getCurrentScript().tickFrequency = 15;
	}
	
	if (target !is null && target !is blob)
	{
		// print("" + target.getConfig());

		this.getCurrentScript().tickFrequency = 1;

		// print("" + this.lowLevelMaxSteps);

		const f32 distance = (target.getPosition() - blob.getPosition()).Length();
		const f32 minDistance = blob.get_f32("minDistance");

		const bool visibleTarget = isVisible(blob, target);
		const bool stuck = this.getState() == 4;
		const bool target_attackable = target !is null && !(target.getTeamNum() == blob.getTeamNum() || target.hasTag("material"));
		const bool lose = distance > maxDistance;
		const bool chase = target_attackable && distance > minDistance;
		const bool retreat = !target_attackable || ((distance < minDistance) && visibleTarget);

		// print("" + stuck);

		if (lose)
		{
			this.SetTarget(null);
			this.getCurrentScript().tickFrequency = 15;
			return;
		}

		blob.setAimPos(target.getPosition());

		if (blob.get_u32("nextAttack") < getGameTime() && (stuck || (visibleTarget ? true : distance <= chaseDistance * 0.50f)))
		{
			blob.setKeyPressed(key_action1, true);
			blob.set_bool("should_do_attack_hack", true);
		}
		else
		{
			blob.setKeyPressed(key_action1, false);
		}

		if (target_attackable && chase)
		{
			if (blob.getTickSinceCreated() % 90 == 0) this.SetPathTo(target.getPosition(), false);
			// if (getGameTime() % 45 == 0) this.SetHighLevelPath(blob.getPosition(), target.getPosition());
			// Move(this, blob, this.getNextPathPosition());
			// print("chase")

			Vec2f dir = this.getNextPathPosition() - blob.getPosition();
			dir.Normalize();

			if (distance > 256)
			{
				Move(this, blob, blob.getPosition() + dir * 24);
			}
			else 
			{
				Move(this, blob, target.getPosition());
			}
		}
		else if (retreat)
		{
			DefaultRetreatBlob( blob, target );
		}

		// if (distance > chaseDistance)
		// {
			// this.SetTarget(FindTarget(this, maxDistance * 100.00f));
		// }

		if (target.hasTag("dead"))
		{
			CPlayer@ targetPlayer = target.getPlayer();

			this.SetTarget(null);
			this.getCurrentScript().tickFrequency = 30;
			return;
		}
	}
	else
	{
		if (XORRandom(2) == 0) RandomTurn(blob);
	}

	FloatInWater(blob); 
} 

CBlob@ FindTarget(CBrain@ this, f32 maxDistance)
{
	CBlob@ blob = this.getBlob();
	const Vec2f pos = blob.getPosition();

	CBlob@[] blobs;
	// getMap().getBlobsInRadius(blob.getPosition(), maxDistance, @blobs);

	getBlobsByTag("flesh", @blobs);
	const u8 myTeam = blob.getTeamNum();

	f32 distance = maxDistance;
	u16 net_id = 0;

	for (int i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];
		Vec2f bp = b.getPosition() - pos;
		f32 d = bp.Length();

		if (d < distance && b.getTeamNum() != myTeam && !b.hasTag("dead") && !b.hasTag("invincible"))
		{
			distance = d;
			net_id = b.getNetworkID();
		}
	}

	return getBlobByNetworkID(net_id);
}

// void onTick(CBrain@ this)
// {
	// if (!isServer()) return;

	// CBlob@ blob = this.getBlob();

	// if (blob.getPlayer() !is null) return;

	// // SearchTarget(this, false, true);

	// const f32 chaseDistance = blob.get_f32("chaseDistance");
	// CBlob@ target = this.getTarget();
	// bool hasTarget = target !is null && !target.hasTag("dead");

	// if (!hasTarget)
	// {
		// const bool raider = blob.get_bool("raider");
		// const Vec2f pos = blob.getPosition();

		// CBlob@[] blobs;
		// getMap().getBlobsInRadius(blob.getPosition(), chaseDistance, @blobs);
		// u8 myTeam = blob.getTeamNum();

		// for (int i = 0; i < blobs.length; i++)
		// {
			// CBlob@ b = blobs[i];
			// Vec2f bp = b.getPosition() - pos;
			// f32 d = bp.Length();

			// if (b.getTeamNum() != myTeam && !b.hasTag("dead") && b.hasTag("human") && d <= chaseDistance)
			// {
				// this.SetTarget(b);
				// blob.set_u32("nextAttack", getGameTime() + blob.get_u8("attackDelay"));
				// return;
			// }
		// }

		// if (raider)
		// {
			// CBlob@ raid_target = getBlobByNetworkID(blob.get_u16("raid target"));

			// if (raid_target !is null)
			// {
				// if (getGameTime() % 30 == 0) this.SetPathTo(raid_target.getPosition(), true);
				// Move(this, blob, this.getNextPathPosition());
				// blob.setAimPos(raid_target.getPosition());

				// this.getCurrentScript().tickFrequency = 1;
			// }
			// else
			// {
				// CBlob@[] humans;
				// getBlobsByTag("flesh", @humans);

				// if (humans.length > 0) 
				// {
					// blob.set_u16("raid target", humans[XORRandom(humans.length)].getNetworkID());
				// }
			// }
		// }
	// }
	// else
	// {
		// this.getCurrentScript().tickFrequency = 1;

		// const f32 distance = (target.getPosition() - blob.getPosition()).Length();
		// const f32 minDistance = blob.get_f32("minDistance");
		// const f32 maxDistance = blob.get_f32("maxDistance");

		// const bool lose = distance > maxDistance;
		// const bool chase = distance > chaseDistance;
		// const bool retreat = distance < minDistance;

		// if (lose)
		// {
			// this.SetTarget(null);
			// this.getCurrentScript().tickFrequency = 30;
			// return;
		// }

		// f32 jitter = blob.get_f32("inaccuracy");
		// Vec2f randomness = Vec2f((100 - XORRandom(200)) * jitter, (100 - XORRandom(200)) * jitter);
		// blob.setAimPos(target.getPosition() + randomness);

		// if (blob.get_u32("nextAttack") < getGameTime())
		// {
			// AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");

			// if(point !is null) 
			// {
				// CBlob@ gun = point.getOccupied();
				// if(gun !is null) 
				// {
					// if (blob.get_u32("nextAttack") < getGameTime())
					// {
						// blob.setKeyPressed(key_action1,true);
						// blob.set_u32("nextAttack", getGameTime() + blob.get_u8("attackDelay"));
					// }
				// }
			// }
		// }

		// if (chase)
		// {
			// if (getGameTime() % 30 == 0) this.SetPathTo(target.getPosition(), true);
			// // if (getGameTime() % 45 == 0) this.SetHighLevelPath(blob.getPosition(), target.getPosition());
			// Move(this, blob, this.getNextPathPosition());
			// // print("chase")
		// }
		// // else if (retreat)
		// // {
			// // DefaultRetreatBlob( blob, target );
			// // // print("retreat");
		// // }
	// }

	// FloatInWater(blob); 
// } 

void Move(CBrain@ this, CBlob@ blob, Vec2f pos)
{
	Vec2f dir =  blob.getPosition() - pos;
	dir.Normalize();

	// print("DIR: x: " + dir.x + "; y: " + dir.y);

	blob.setKeyPressed(key_left, dir.x > 0);
	blob.setKeyPressed(key_right, dir.x < 0);
	blob.setKeyPressed(key_up, dir.y > 0);
	blob.setKeyPressed(key_down, dir.y < 0);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::stab:
		case Hitters::sword:
		case Hitters::fall:
			damage *= 0.50f;
			break;

		case Hitters::arrow:
			damage *= 0.45f; 
			break;

		case Hitters::burn:
		case Hitters::fire:
		case HittersTC::radiation:
			damage = 0.00f;
			break;

		case HittersTC::electric:
			damage = 5.00f;
			break;
	}

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 50)
		{
			this.getSprite().PlaySound("/scyther-screech" + XORRandom(7) + ".ogg");
			this.set_u32("next sound", getGameTime() + 100);
		}
	}

	if (isServer())
	{
		CBrain@ brain = this.getBrain();

		if (brain !is null && hitterBlob !is null)
		{
			if (hitterBlob.getTeamNum() != this.getTeamNum()) brain.SetTarget(hitterBlob);
		}
	}

	return damage;
}

void onDie(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}

	if (!this.hasTag("exploded"))
	{
		DoExplosion(this);
	}

	if (isServer())
	{
		for (int i = 0; i < 7; i++)
		{
			CBlob@ gib = server_CreateBlob("scythergib", this.getTeamNum(), this.getPosition());
			gib.setVelocity(Vec2f((800 - XORRandom(1600)) / 100.0f, -XORRandom(800) / 100.0f) * 2.0f);

			switch(i)
			{
				case 0: 
					gib.getSprite().SetAnimation("head");
					break;

				case 1: 
					gib.getSprite().SetAnimation("blade");
					break;

				case 2: 
					gib.getSprite().SetAnimation("torso");
					break;

				default:
					gib.getSprite().SetAnimation("misc");
					break;
			}
		}

		for (int i = 0; i < 8; i++)
		{
			CBlob@ plasteel = server_CreateBlob("mat_plasteel", this.getTeamNum(), this.getPosition());
			plasteel.server_SetQuantity(2 + XORRandom(10));
			plasteel.setVelocity(Vec2f((800 - XORRandom(1600)) / 100.0f, -XORRandom(800) / 100.0f) * 2.0f);
		}
	}
}

void DoExplosion(CBlob@ this)
{
	this.Tag("exploded");

	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	f32 vellen = this.getVelocity().Length();

	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (64.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);

	Explode(this, 64.0f + random, 150.0f);

	for (int i = 0; i < 16 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 80);
		LinearExplosion(this, dir, (16.0f + XORRandom(32) + (modifier * 8)) * vellen, 12 + XORRandom(8), 20 + XORRandom(vellen * 2), 50.0f, Hitters::explosion);
	}

	Vec2f pos = this.getPosition();
	CMap@ map = getMap();

	if (isServer())
	{
		for (int i = 0; i < 24; i++)
		{
			CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(25 + XORRandom(80));
			blob.setVelocity(Vec2f(4 - XORRandom(8), -2 - XORRandom(5)) * (0.5f));
		}

		for (int i = 0; i < 256; i++)
		{
			Vec2f tpos = getRandomVelocity(angle, 1, 120) * XORRandom(128);
			if (map.isTileSolid(pos + tpos)) map.server_SetTile(pos + tpos, CMap::tile_matter);
		}

		CBlob@[] trees;
		this.getMap().getBlobsInRadius(this.getPosition(), 192.0f, @trees);

		for (int i = 0; i < trees.length; i++)
		{
			CBlob@ b = trees[i];

			if (b.getName() == "tree_bushy" || b.getName() == "tree_pine")
			{
				CBlob@ tree = server_CreateBlob("crystaltree", b.getTeamNum(), b.getPosition() + Vec2f(0, -32));

				b.Tag("no drop");
				b.server_Die();
			}
		}
	}

	if (isClient())
	{
		for (int i = 0; i < 60; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(500) * 0.01f, 25), particles[XORRandom(particles.length)]);
		}
		SetScreenFlash(50, 255, 255, 255);
		this.getSprite().Gib();
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 1.8f + XORRandom(100) * 0.01f, 2 + XORRandom(6), XORRandom(100) * -0.00005f, true);
}
