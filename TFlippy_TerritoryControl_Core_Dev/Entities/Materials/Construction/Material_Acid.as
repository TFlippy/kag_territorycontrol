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
		
	if (getNet().isServer())
	{
		for (int i = 0; i < (quantity / 8) + XORRandom(quantity / 8) ; i++)
		{
			CBlob@ blob = server_CreateBlob("acidgas", -1, this.getPosition());
			blob.setVelocity(Vec2f(XORRandom(16) - 8, -XORRandom(5)));
			blob.server_SetTimeToDie(30 + XORRandom(30));
		}
	}
	
	this.server_Die();
	this.getSprite().Gib();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !blob.isCollidable() : !solid) return;

	f32 vellen = this.getOldVelocity().Length();

	if (vellen > 3.0f)
	{
		this.server_Die();
	}
}

void onDie(CBlob@ this)
{
	if (!this.hasTag("dead"))
	{
		DoExplosion(this);
	}
}