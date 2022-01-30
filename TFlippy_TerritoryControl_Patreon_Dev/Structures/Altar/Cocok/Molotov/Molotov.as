#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 3;
	this.server_SetTimeToDie(5);
	
	this.set_string("custom_explosion_sound", "Molotov_Explode.ogg");
	
	this.Tag("projectile");
	this.Tag("map_damage_dirt");
}

void onTick(CSprite@ this)
{
	ParticleAnimated("SmallFire", this.getBlob().getPosition() + Vec2f(1 - XORRandom(3), -4), Vec2f(0, -1 - XORRandom(2)), 0, 1.0f, 2, 0.25f, false);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (solid && blob is null)
		{
			f32 vellen = this.getOldVelocity().Length();
			if (vellen > 3.0f)
			{
				this.server_Die();
			}
		}
	}
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}
	
	if (!this.hasTag("dead"))
	{
		Explode(this, 16.0f, 2.0f);
		
		if (isServer())
		{
			Vec2f vel = this.getOldVelocity();
			for (int i = 0; i < 4 +  XORRandom(4) ; i++)
			{
				CBlob@ blob = server_CreateBlob("flame", -1, this.getPosition() + Vec2f(0, -8));
				Vec2f nv = Vec2f((XORRandom(100) * 0.01f * vel.x * 1.30f), -(XORRandom(100) * 0.01f * 3.00f));
				
				blob.setVelocity(nv);
				blob.server_SetTimeToDie(3 + XORRandom(3));
			}
		}
		
		
		this.Tag("dead");
		this.getSprite().Gib();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable();
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}