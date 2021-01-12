// Princess brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";
#include "MaterialCommon.as";
#include "Requirements.as";
#include "MakeDustParticle.as";

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
	this.set_f32("gib health", -10.0f);

	this.set_u32("nextAttack", 0);
	this.set_u32("nextScream", 0);
	
	this.set_f32("minDistance", 8);
	this.set_f32("chaseDistance", 300);
	this.set_f32("maxDistance", 600);
	
	this.set_f32("inaccuracy", 0.01f);
	this.set_u8("reactionTime", 20);
	this.set_u8("attackDelay", 0);
	
	this.SetDamageOwnerPlayer(null);
	
	this.Tag("can open door");
	this.Tag("npc");
	this.Tag("player");
	this.Tag("flesh");
	this.Tag("dangerous");
	this.Tag("map_damage_dirt");
	
	this.set_f32("map_damage_ratio", 0.3f);
	this.set_f32("map_damage_radius", 32.0f);
	this.set_bool("map_damage_raycast", true);
	
	this.set_f32("voice pitch", 1.75f);
	this.getSprite().addSpriteLayer("isOnScreen", "NoTexture.png", 1, 1);
	this.server_setTeamNum(231);
	
	if (!this.exists("voice_pitch")) this.set_f32("voice pitch", 1.25f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")){ return;}

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			this.getSprite().PlaySound("Pus_Idle_" + XORRandom(1) + ".ogg", 2.5f, 1.00f);
			this.set_u32("next sound", getGameTime() + 350);
		}
		if(!this.getSprite().getSpriteLayer("isOnScreen").isOnScreen()){
			return;
		}
	}

	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 1.90f;
		moveVars.jumpFactor *= 2.20f;
		moveVars.swimspeed *= 2.00f;
		moveVars.canVault = true;
	}

	if (this.isKeyPressed(key_action1) && getGameTime() > this.get_u32("next attack"))
	{
		Vec2f dir = this.getAimPos() - this.getPosition();
		dir.Normalize();
		
		ClawHit(this, this.getPosition() + Vec2f(this.isFacingLeft() ? -16 : 16, XORRandom(16) - 8), dir, 4, Hitters::bite);
		this.set_u32("next attack", getGameTime() + 6);
	}
	
}

void onDie(CBlob@ this)
{
	this.getSprite().Gib();

	Explode(this, 16.0f, 8.0f);
	
	if (isServer())
	{			
		for (int i = 0; i < 6; i++)
		{
			CBlob@ blob = server_CreateBlob("acidgas", this.getTeamNum(), this.getPosition());
			
			if (blob !is null)
			{
				blob.setVelocity(Vec2f(4 - XORRandom(8), - XORRandom(4)));
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case HittersTC::radiation:
			return 0;
			break;
	}

	if (!this.hasTag("dead"))
	{
		if (isClient())
		{
			if (getGameTime() > this.get_u32("next sound") - 130)
			{
				this.getSprite().PlaySound("Pus_Pissed_" + XORRandom(2) + ".ogg", 2, 1.0f);
				this.set_u32("next sound", getGameTime() + 150);
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
	}
		
	return damage;
}

void ClawHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	bool client = isClient();
	bool server = isServer();
	
	Vec2f dir = worldPoint - this.getPosition();
	f32 len = dir.getLength();
	dir.Normalize();
	f32 angle = dir.Angle();
	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(worldPoint + (dir * Maths::Min(len, 16)), 16, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ hitBlob = blobsInRadius[i];
			if (hitBlob !is null && hitBlob !is this)
			{
				if (server) this.server_Hit(hitBlob, worldPoint, velocity, 0.65f, customData, true);
				if (client && hitBlob.hasTag("flesh")) 
				{
					this.getSprite().PlaySound("Pus_Attack_" + XORRandom(3), 1.1f, 1.00f);
					ParticleBloodSplat(hitBlob.getPosition(), true);
				}
				
				f32 mass = hitBlob.getMass();
				hitBlob.AddForce(-dir * Maths::Min(700.0f, mass * 3.50f));
			}
		}
	}
}