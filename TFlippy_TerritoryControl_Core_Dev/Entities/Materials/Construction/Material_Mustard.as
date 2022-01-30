#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.maxQuantity = 50;
	this.Tag("dangerous");
	this.Tag("mat_gas");
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
		f32 quantity = this.getQuantity();
		if (quantity > 0)
		{
			if (isClient())
			{
				this.getSprite().PlaySound("gas_leak.ogg");
			}
		
			if (isServer())
			{
				for (int i = 0; i < (quantity / 10) + XORRandom(quantity / 10) ; i++)
				{
					CBlob@ blob = server_CreateBlob("mustard", -1, this.getPosition());
					blob.setVelocity(Vec2f(2 - XORRandom(4), 2 - XORRandom(4)));
				}
			}
		}
		
		this.Tag("dead");
		this.getSprite().Gib();
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire || customData == Hitters::burn)
	{
		if (isServer()) this.server_Die();
	}

	return damage;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (blob !is null ? !blob.isCollidable() : !solid) return;
		f32 vellen = this.getOldVelocity().Length();

		if (vellen > 4.0f)
		{
			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}
