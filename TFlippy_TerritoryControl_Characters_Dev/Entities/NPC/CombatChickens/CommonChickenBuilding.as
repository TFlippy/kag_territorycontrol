#include "Hitters.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::builder || customData == Hitters::drill)
	{
		return damage *= 7.0f;
	}

	return damage;
}