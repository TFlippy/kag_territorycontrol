#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.maxQuantity = 50;
	this.Tag("mat_gas");
}

void DoExplosion(CBlob@ this)
{
	if (!this.hasTag("dead"))
	{
		f32 quantity = this.getQuantity();
		if (quantity > 0)
		{
			if (isServer())
			{
				for (int i = 0; i < (quantity / 8) + XORRandom(quantity / 8) ; i++)
				{
					CBlob@ blob = server_CreateBlobNoInit("acidgas");
					blob.server_setTeamNum(-1);
					blob.setPosition(this.getPosition());
					blob.setVelocity(Vec2f(XORRandom(16) - 8, -XORRandom(5)));
					blob.set_u16("acid_strength", 100);
					blob.Init();
					blob.server_SetTimeToDie(30 + XORRandom(30));
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

		if (vellen > 3.0f)
		{
			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}