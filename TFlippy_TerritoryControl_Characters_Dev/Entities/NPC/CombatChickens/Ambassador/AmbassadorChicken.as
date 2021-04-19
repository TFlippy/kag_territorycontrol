// Princess brain

#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";
#include "MakeMat.as";
#include "DeityCommon.as";

void onInit(CBlob@ this)
{
	this.set_u32("nextAttack", 0);
	this.set_u32("nextBomb", 0);

	this.set_f32("minDistance", 32);
	this.set_f32("chaseDistance", 64);
	this.set_f32("maxDistance", 64);

	this.set_f32("inaccuracy", 0.01f);
	this.set_u8("reactionTime", 30);
	this.set_u8("attackDelay", 90);
	this.set_bool("bomber", false);
	this.set_bool("raider", false);

	this.SetDamageOwnerPlayer(null);

	this.Tag("can open door");
	this.Tag("combat chicken");
	this.Tag("npc");
	this.Tag("flesh");
	this.Tag("player");

	this.getCurrentScript().tickFrequency = 1;

	this.set_f32("voice pitch", 1.50f);

	if (isServer())
	{
		this.set_u16("stolen coins", 9000);
		// this.server_setTeamNum(250);

		string gun_config;
		string ammo_config;

		gun_config = "fuger";
		ammo_config = "mat_pistolammo";

		// this.set_u8("reactionTime", 2);
		// this.set_u8("attackDelay", 1);
		// this.set_f32("chaseDistance", 100);
		// this.set_f32("minDistance", 32);
		// this.set_f32("maxDistance", 300);
		// this.set_f32("inaccuracy", 0.00f);

		// MakeMat(this, this.getPosition(), "mat_pistolammo", 50);

		// CBlob@ gun = server_CreateBlob(gun_config, this.getTeamNum(), this.getPosition());
		// if(gun !is null)
		// {
			// this.server_Pickup(gun);
		// }

		MakeMat(this, this.getPosition(), "phone", 1);

		if (XORRandom(100) < 80) 
		{
			MakeMat(this, this.getPosition(), "bp_automation_advanced", 1);
		}

		if (XORRandom(100) < 70) 
		{
			MakeMat(this, this.getPosition(), "bp_energetics", 1);
		}

		if (XORRandom(100) < 40) 
		{
			MakeMat(this, this.getPosition(), "mat_goldingot", 20);
		}

		if (XORRandom(100) < 30) 
		{
			MakeMat(this, this.getPosition(), "badgerplushie", 1);
		}

		if (XORRandom(100) < 50) 
		{
			MakeMat(this, this.getPosition(), "icecream", 1);
		}

		if (XORRandom(100) < 50) 
		{
			MakeMat(this, this.getPosition(), "bobomax", 1);
		}
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 19, Vec2f(16, 16));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

void onTick(CBlob@ this)
{
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 1.30f;
		moveVars.jumpFactor *= 2.00f;
	}

	if (this.getHealth() < 0.0 && this.hasTag("dead"))
	{
		this.getSprite().PlaySound("Wilhelm.ogg", 1.8f, 1.8f);
		
		if (isServer())
		{
			server_DropCoins(this.getPosition(), Maths::Max(0, Maths::Min(this.get_u16("stolen coins"), 20000)));
			CBlob@ carried = this.getCarriedBlob();

			if (carried !is null)
			{
				carried.server_DetachFrom(this);
			}
		}
	}
}

void onDie(CBlob@ this)
{
	CBlob@ altar = getBlobByName("altar_foghorn");
	if (altar !is null)
	{

		altar.add_f32("deity_power", -10000);
		altar.set_u32("next_shelling", getGameTime() + (30 * 10));

		if (isClient())
		{
			client_AddToChat("A UPF Ambassador has been killed!", 0xffff0000);
		}
		if (isServer()) this.Sync("deity_power", false);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 50)
		{
			this.getSprite().PlaySound("scoutchicken_vo_hit" + (1 + XORRandom(3)) + ".ogg", 1, 0.8f);
			this.set_u32("next sound", getGameTime() + 60);
		}
	}

	if (hitterBlob !is null && hitterBlob !is this)
	{
		CBlob@ altar = getBlobByName("altar_foghorn");
		if (altar !is null)
		{
			f32 reputation_penalty = Maths::Max(100, damage * 500.00f);

			reputation_penalty = Maths::Round(reputation_penalty);

			if (isClient())
			{
				CBlob@ localBlob = getLocalPlayerBlob();
				if (localBlob !is null && localBlob.get_u8("deity_id") == Deity::foghorn)
				{
					client_AddToChat("You haven't ensured your UPF Ambassador's safety! (" + -reputation_penalty + " reputation)", 0xffff0000);
					Sound::Play("Collect.ogg", this.getPosition(), 2.00f, 0.80f);
				}
			}

			altar.add_f32("deity_power", -reputation_penalty);
			if (isServer()) altar.Sync("deity_power", false);
		}
	}

	return damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum();
}