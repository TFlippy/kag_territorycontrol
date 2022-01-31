#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.maxQuantity = 16;
	this.Tag("explosive");
	this.Tag("medium weight");
	this.Tag("map_damage_dirt");
}

void DoExplosion(CBlob@ this, Vec2f velocity)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, velocity, DoExplosion);
		return;
	}

	if (this.hasTag("dead")) return;
	this.Tag("dead");

	Explode(this, 64.0f, 4.0f);
	for (int i = 0; i < 4; i++)
	{
		Vec2f jitter = Vec2f((XORRandom(100) - 50) / 100.0f, (XORRandom(100) - 50) / 100.0f);
		LinearExplosion(this, Vec2f(velocity.x * jitter.x, velocity.y * jitter.y), 16.0f + XORRandom(8), 16 + XORRandom(8), 2, 4.00f, Hitters::explosion);
	}

	this.server_Die();
	this.getSprite().Gib();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::builder)
	{
		DoExplosion(this, velocity);
	}

	return damage;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !blob.isCollidable() : !solid) return;

	f32 vellen = this.getOldVelocity().Length();

	if (vellen > 6.0f)
	{
		DoExplosion(this, this.getOldVelocity());
	}
}