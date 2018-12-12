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
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		boom.setPosition(this.getPosition());
		boom.set_u8("boom_frequency", 6);
		boom.set_u8("boom_start", 10);
		boom.set_u8("boom_end", (Maths::Sqrt(quantity * 10) * 10));
		boom.Tag("no mithril");
		boom.Tag("no fallout");
		boom.Tag("reflash");
		boom.set_f32("flash_distance", 1024);
		boom.Init();
	
		// for (int i = 0; i < quantity / 5; i++)
		// {
			// CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
			// boom.setPosition(this.getPosition() + getRandomVelocity(0, i * 32, 360));
			// boom.set_u8("boom_start", 10);
			// boom.set_u8("boom_end", 15);
			// boom.Tag("no mithril");
			// boom.Tag("no fallout");
			// boom.set_f32("flash_distance", 1024);
			// boom.Init();
		// }
	}
		
	// if (getNet().isServer())
	// {
		// for (int i = 0; i < (quantity / 5) + XORRandom(quantity / 5) ; i++)
		// {
			// CBlob@ blob = server_CreateBlob("fuelgas", -1, this.getPosition());
			// blob.setVelocity(Vec2f(XORRandom(20) - 10, -XORRandom(10)));
			// blob.server_SetTimeToDie(60 + XORRandom(60));
		// }
	// }
	
	this.server_Die();
	this.getSprite().Gib();
}

// f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
// {
	// if (customData == Hitters::fire || customData == Hitters::burn)
	// {
		// DoExplosion(this);
	// }

	// return damage;
// }

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !blob.isCollidable() : !solid) return;

	f32 vellen = this.getOldVelocity().Length();

	if (vellen > 5.0f)
	{
		DoExplosion(this);
	}
}