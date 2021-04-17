// Princess brain

#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";

void onInit(CBlob@ this)
{
	this.set_u32("nextAttack", 0);
	this.set_u32("nextBomb", 0);

	this.set_f32("minDistance", 256);
	this.set_f32("chaseDistance", 400);
	this.set_f32("maxDistance", 400);

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
	this.getSprite().addSpriteLayer("isOnScreen","NoTexture.png",1,1);
	if (isServer())
	{
		this.set_u16("stolen coins", 800);
		this.server_setTeamNum(250);

		string gun_config;
		string ammo_config;

		gun_config = "taser";
		ammo_config = "mat_battery";

		this.set_u8("reactionTime", 2);
		this.set_u8("attackDelay", 0);
		this.set_f32("chaseDistance", 100);
		this.set_f32("minDistance", 32);
		this.set_f32("maxDistance", 300);
		this.set_f32("inaccuracy", 0.00f);

		if(XORRandom(100) < 5)
		{
			CBlob@ phone = server_CreateBlob("phone", this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(phone);
		}
		if (XORRandom(100) < 50) 
		{
			CBlob@ bp_auto = server_CreateBlob("bp_automation_advanced", -1, this.getPosition());
			this.server_PutInInventory(bp_auto);
		}

		if (XORRandom(100) < 30) 
		{
			CBlob@ bp_sdr = server_CreateBlob("bp_energetics", -1, this.getPosition());
			this.server_PutInInventory(bp_sdr);
		}

		if (XORRandom(100) < 10) 
		{
			CBlob@ bp_chem = server_CreateBlob("bp_chemistry", -1, this.getPosition());
			this.server_PutInInventory(bp_chem);
		}

		if (XORRandom(100) < 20)
		{
			CBlob@ ammo = server_CreateBlob(ammo_config, this.getTeamNum(), this.getPosition());
			ammo.server_SetQuantity(50);

			this.server_PutInInventory(ammo);

			CBlob@ gun = server_CreateBlob(gun_config, this.getTeamNum(), this.getPosition());
			if(gun !is null)
			{
				this.server_Pickup(gun);
			}
		}
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 18, Vec2f(16, 16));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

void onTick(CBlob@ this)
{
	if(isClient()){
		if(!this.getSprite().getSpriteLayer("isOnScreen").isOnScreen()){
			return;
		}
	}

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
			server_DropCoins(this.getPosition(), Maths::Max(0, Maths::Min(this.get_u16("stolen coins"), 5000)));
			CBlob@ carried = this.getCarriedBlob();
			
			if (carried !is null)
			{
				carried.server_DetachFrom(this);
			}
		}

		this.getCurrentScript().runFlags |= Script::remove_after_this;
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

	return damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum();
}
