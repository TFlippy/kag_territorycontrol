// Princess brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
//#include "LoaderUtilities.as";
#include "CustomBlocks.as";
#include "RunnerCommon.as";

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

	this.set_u32("nextAttack", 0);

	this.set_f32("minDistance", 32);
	this.set_f32("chaseDistance", 400);
	this.set_f32("maxDistance", 800);

	this.set_f32("inaccuracy", 0.00f);
	this.set_u8("reactionTime", 15);
	this.set_u8("attackDelay", 90);

	this.set_bool("raider", true);

	this.SetDamageOwnerPlayer(null);

	this.Tag("npc");
	this.Tag("player");

	this.getCurrentScript().tickFrequency = 1;

	if (isClient())
	{
		client_AddToChat("A Centipede has arrived!", SColor(255, 255, 0, 0));
		Sound::Play("scyther-intro.ogg");
	}

	if (isServer())
	{
		for (int i = 0; i < 2; i++)
		{
			CBlob@ ammo = server_CreateBlob("mat_mithrilenriched", this.getTeamNum(), this.getPosition());
			ammo.server_SetQuantity(50);
			this.server_PutInInventory(ammo);
		}

		CBlob@ lance = server_CreateBlob("infernocannon", this.getTeamNum(), this.getPosition());
		if (lance !is null)
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
		moveVars.walkFactor *= 15.00f;
		moveVars.jumpFactor *= 50.00f;
	}
	
	// print("t");

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound"))
		{
			this.getSprite().PlaySound("/Centipede_Call_" + XORRandom(5) + ".ogg");
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
}

void onTick(CBrain@ this)
{
	if (!isServer()) return;

	CBlob@ blob = this.getBlob();
	blob.setKeyPressed(key_action1, false);

	if (blob.getPlayer() !is null) return;

	// SearchTarget(this, false, true);

	const f32 chaseDistance = blob.get_f32("chaseDistance");
	CBlob@ target = this.getTarget();

	bool hasTarget = target !is null && !target.hasTag("dead");

	if (!hasTarget)
	{
		const bool raider = blob.get_bool("raider");
		const Vec2f pos = blob.getPosition();

		CBlob@[] blobs;
		getMap().getBlobsInRadius(blob.getPosition(), chaseDistance, @blobs);
		u8 myTeam = blob.getTeamNum();

		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			Vec2f bp = b.getPosition() - pos;
			f32 d = bp.Length();

			if (b.getTeamNum() != myTeam && !b.hasTag("dead") && b.hasTag("human") && d <= chaseDistance)
			{
				this.SetTarget(b);
				blob.set_u32("nextAttack", getGameTime() + blob.get_u8("attackDelay"));
				return;
			}
		}

		if (raider)
		{
			CBlob@ raid_target = getBlobByNetworkID(blob.get_u16("raid target"));

			if (raid_target !is null)
			{
				if (getGameTime() % 30 == 0) this.SetPathTo(raid_target.getPosition(), true);
				Move(this, blob, this.getNextPathPosition());
				blob.setAimPos(raid_target.getPosition());

				this.getCurrentScript().tickFrequency = 1;
			}
			else
			{
				CBlob@[] humans;
				getBlobsByTag("flesh", @humans);

				if (humans.length > 0) 
				{
					blob.set_u16("raid target", humans[XORRandom(humans.length)].getNetworkID());
				}
			}
		}
	}
	else
	{
		this.getCurrentScript().tickFrequency = 1;

		const f32 distance = (target.getPosition() - blob.getPosition()).Length();
		const f32 minDistance = blob.get_f32("minDistance");
		const f32 maxDistance = blob.get_f32("maxDistance");

		const bool lose = distance > maxDistance;
		const bool chase = distance > chaseDistance;
		const bool retreat = distance < minDistance;

		if (lose)
		{
			this.SetTarget(null);
			this.getCurrentScript().tickFrequency = 0;
			return;
		}

		f32 jitter = blob.get_f32("inaccuracy");
		Vec2f tpos = target.getPosition() - blob.getPosition();
		blob.SetFacingLeft(tpos.x < 0);

		// print("" + target.getName());

		// print("" + distance);

		if (distance < 400)
		{
			f32 x = tpos.x / 8.00f;
			f32 y = tpos.y / 8.00f;
			f32 v = 16.00f;
			f32 g = sv_gravity * 0.50f;
			f32 sqrt = Maths::Sqrt((v*v*v*v) - (g*(g*(x*x) + 2.00f*y*(v*v))));
			f32 ang = Maths::ATan(((v*v) + sqrt)/(g*x)); // * 57.2958f;

			Vec2f aimDir = Vec2f(-f32(Maths::Cos(ang)), f32(Maths::Sin(ang)));
			// if (x > 0) aimDir.RotateBy(180);
			// if (blob.isFacingLeft()) aimDir.RotateBy(180);
			aimDir.RotateBy(180);

			blob.setAimPos(blob.getPosition() + aimDir);
			f32 angDeg = Maths::Abs(ang * 57.2958f);

			// print("" + angDeg);
			// print("" + ang);
			
			if (angDeg > 30 && angDeg < 88 && blob.get_u32("nextAttack") < getGameTime())
			{
				AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
				
				if (point !is null) 
				{
					CBlob@ gun = point.getOccupied();
					if (gun !is null) 
					{
						if (blob.get_u32("nextAttack") < getGameTime())
						{
							blob.setKeyPressed(key_action1, true);
							blob.set_bool("should_do_attack_hack", true);
							blob.set_u32("nextAttack", getGameTime() + blob.get_u8("attackDelay"));
						}
					}
				}
			}
		}

		if (chase)
		{
			if (getGameTime() % 30 == 0) this.SetPathTo(target.getPosition(), true);
			Move(this, blob, this.getNextPathPosition());
		}
	}

	FloatInWater(blob); 
} 

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
	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 50)
		{
			this.getSprite().PlaySound("/Centipede_Pain_" + XORRandom(3) + ".ogg");
			this.set_u32("next sound", getGameTime() + 100);
		}
	}

	if (isServer())
	{
		CBrain@ brain = this.getBrain();
		if (brain !is null && hitterBlob !is null && (hitterBlob.hasTag("flesh") || hitterBlob.hasTag("npc")) && hitterBlob !is this)
		{
			if (hitterBlob.getTeamNum() != this.getTeamNum()) brain.SetTarget(hitterBlob);
		}
	}

	return damage;
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		boom.setPosition(this.getPosition());
		boom.set_u8("boom_start", 5);
		boom.set_u8("boom_end", 15);
		boom.set_f32("mithril_amount", 100);
		boom.set_f32("flash_distance", 1024);
		boom.Init();

		for (int i = 0; i < 16; i++)
		{
			CBlob@ plasteel = server_CreateBlob("mat_plasteel", this.getTeamNum(), this.getPosition());
			plasteel.server_SetQuantity(10 + XORRandom(40));
			plasteel.setVelocity(Vec2f((800 - XORRandom(1600)) / 100.0f, -XORRandom(800) / 100.0f) * 2.0f);
		}
	}
}
