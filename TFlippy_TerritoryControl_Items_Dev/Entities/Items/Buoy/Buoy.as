// TFlippy
// Doesn't really do anything

#include "ParticleSparks.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("buoy");
	this.Tag("heavy weight");
	this.getShape().SetGravityScale(0.0f);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	Sound::Play("Entities/Characters/Knight/ShieldHit.ogg", worldPoint);
	sparks(worldPoint, -velocity.Angle(), Maths::Max(velocity.Length() * 0.05f, damage));

	switch (customData)
	{
		case Hitters::mine:
			return damage + 15.00f;
		case Hitters::mine_special:
			return damage + 15.00f;
		case Hitters::ballista:
			return damage + 15.00f;
		case Hitters::explosion:
			return damage + 20.00f;
		case Hitters::keg:
			return damage + 120.00f;
		case Hitters::stab:
			return damage + 2.50f;
	}

	return damage;
}


