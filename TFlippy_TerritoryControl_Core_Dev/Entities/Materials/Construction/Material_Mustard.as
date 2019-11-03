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
				for (int i = 0; i < (quantity / 5) + XORRandom(quantity / 5) ; i++)
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