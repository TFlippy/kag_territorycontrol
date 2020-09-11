#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("ammo");

	this.maxQuantity = 3;
	this.Tag("explosive");
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
		Vec2f jitter = Vec2f((XORRandom(200) - 100) / 200.0f, (XORRandom(200) - 100) / 200.0f);
		LinearExplosion(this, Vec2f(velocity.x * jitter.x, velocity.y * jitter.y), 24.0f + XORRandom(32), 24.0f, 4, 10.0f, Hitters::explosion);
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

	if (vellen > 10.0f)
	{
		DoExplosion(this, this.getOldVelocity());
	}
}