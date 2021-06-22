#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{	
	this.maxQuantity = 4;
	this.Tag("explosive");
	this.Tag("medium weight");
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

	this.Tag("map_damage_dirt");
	
	f32 quantity = this.getQuantity();
		
	Explode(this, 48.0f, 5.0f);
	LinearExplosion(this, velocity, 48.0f * quantity, 16.0f * quantity / 2.0f, 4, 8.0f, Hitters::bomb);

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

	if (vellen > 8.0f)
	{
		DoExplosion(this, this.getOldVelocity());
	}
}