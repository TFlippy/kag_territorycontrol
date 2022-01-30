#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.maxQuantity = 50;
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
			if (isServer())
			{
				for (int i = 0; i < (quantity / 10) ; i++)
				{
					CBlob@ blob = server_CreateBlob("flame", -1, this.getPosition());
					blob.setVelocity(Vec2f(XORRandom(10) - 5, -XORRandom(6)));
					blob.server_SetTimeToDie(4 + XORRandom(4));
				}
			}
		}
		
		this.Tag("dead");
		this.getSprite().Gib();
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (blob !is null ? !blob.isCollidable() : !solid) return;
		f32 vellen = this.getOldVelocity().Length();

		if (vellen > 5.0f)
		{
			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}
