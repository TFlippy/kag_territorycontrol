// Princess brain

#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	this.set_u32("nextAttack", 0);
	this.set_u32("nextBomb", 0);
	
	this.set_f32("minDistance", 32);
	this.set_f32("chaseDistance", 200);
	this.set_f32("maxDistance", 400);
	
	this.set_f32("inaccuracy", 0.01f);
	this.set_u8("reactionTime", 20);
	this.set_u8("attackDelay", 0);
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
	
	if (getNet().isServer())
	{
		this.set_u16("stolen coins", 850);
	
		this.server_setTeamNum(250);
			
		string gun_config;
		string ammo_config;
		
		gun_config = "beagle";
		ammo_config = "mat_pistolammo";
		
		this.set_u8("reactionTime", 2);
		this.set_u8("attackDelay", 2);
		this.set_f32("chaseDistance", 100);
		this.set_f32("minDistance", 32);
		this.set_f32("maxDistance", 300);
		this.set_f32("inaccuracy", 0.00f);
		
		for (int i = 0; i < 6; i++)
		{
			CBlob@ ammo = server_CreateBlob(ammo_config, this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(ammo);
		}
		
		CBlob@ gun = server_CreateBlob(gun_config, this.getTeamNum(), this.getPosition());
		this.server_Pickup(gun);
		
		CBitStream stream;
		gun.SendCommand(gun.getCommandID("cmd_gunReload"), stream);
	}
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
		moveVars.walkFactor *= 1.15f;
		moveVars.jumpFactor *= 1.50f;
	}

	if (this.getHealth() < 0.0 && !this.hasTag("dead"))
	{
		this.Tag("dead");
		this.getSprite().PlaySound("Wilhelm.ogg", 1.8f, 1.8f);
		
		if (getNet().isServer())
		{
			this.server_SetPlayer(null);
			server_DropCoins(this.getPosition(), Maths::Max(0, Maths::Min(this.get_u16("stolen coins"), 5000)));
			CBlob@ carried = this.getCarriedBlob();
			
			if (carried !is null)
			{
				carried.server_DetachFrom(this);
			}
			
			if (XORRandom(100) < 25) server_CreateBlob("phone", -1, this.getPosition());
			
			if (XORRandom(100) < 15) 
			{
				server_CreateBlob("bp_automation_advanced", -1, this.getPosition());
			}
		}
		
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}

	if (getNet().isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			// this.getSprite().PlaySound("scoutchicken_vo_perish.ogg", 0.8f, 1.5f);
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (getNet().isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 50)
		{
			this.getSprite().PlaySound("scoutchicken_vo_hit" + (1 + XORRandom(3)) + ".ogg", 1, 0.8f);
			this.set_u32("next sound", getGameTime() + 60);
		}
	}
	
	if (getNet().isServer())
	{
		CBrain@ brain = this.getBrain();
		
		if (brain !is null && hitterBlob !is null)
		{
			if (hitterBlob.getTeamNum() != this.getTeamNum() && hitterBlob.isCollidable()) 
			{
				if (brain.getTarget() is null) brain.SetTarget(hitterBlob);
				else if (!hitterBlob.hasTag("material")) brain.SetTarget(hitterBlob);
			}
		}
	}
	
	return damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum();
}