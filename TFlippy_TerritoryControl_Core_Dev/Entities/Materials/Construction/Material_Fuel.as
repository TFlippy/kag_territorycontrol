#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.maxQuantity = 50;
	this.set_u8("fuel_energy", 100);
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
					CBlob@ blob = server_CreateBlob("fuelgas", -1, this.getPosition());
					blob.setVelocity(Vec2f(XORRandom(20) - 10, -XORRandom(10)));
					blob.server_SetTimeToDie(60 + XORRandom(60));
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