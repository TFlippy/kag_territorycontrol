#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.maxQuantity = 50;
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	this.Tag("dead");

	f32 quantity = this.getQuantity();
		
	Explode(this, 16.0f, 2.0f);

	if (getNet().isServer())
	{
		for (int i = 0; i < (quantity / 10) + XORRandom(quantity / 10) ; i++)
		{
			CBlob@ blob = server_CreateBlob("flame", -1, this.getPosition());
			blob.setVelocity(Vec2f(XORRandom(10) - 5, -XORRandom(6)));
			blob.server_SetTimeToDie(4 + XORRandom(6));
		}
	}
	
	this.server_Die();
	this.getSprite().Gib();
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
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