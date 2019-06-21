#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.maxQuantity = 500;
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	this.Tag("dead");

	f32 quantity = this.getQuantity();
		
	if (getNet().isServer())
	{
		f32 size = Maths::Pow(quantity * 0.25f, 1.50f) * 25;
	
		CBlob@ boom = server_CreateBlobNoInit("antimatterexplosion");
		boom.setPosition(this.getPosition());
		boom.set_u8("boom_frequency", 1);
		boom.set_f32("boom_size", 0);
		boom.set_f32("boom_increment", 4.00f);
		boom.set_f32("boom_end", size);
		boom.set_f32("flash_distance", size * 4.00f);
		boom.Init();
	
		// CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		// boom.setPosition(this.getPosition());
		// boom.set_u8("boom_frequency", 6);
		// boom.set_u8("boom_start", 10);
		// boom.set_u8("boom_end", (Maths::Sqrt(quantity * 10) * 10));
		// boom.Tag("no mithril");
		// boom.Tag("no fallout");
		// boom.Tag("reflash");
		// boom.set_f32("flash_distance", 1024);
		// boom.Init();
	}

	this.server_Die();
	this.getSprite().Gib();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (getNet().isServer())
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