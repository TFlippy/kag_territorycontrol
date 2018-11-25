#include "Hitters.as";

void onInit(CBlob@ this)
{
	
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.getTickSinceCreated() < 60) return 0;
	
	switch (customData)
	{
		case Hitters::fall:
		case Hitters::fire:
		case Hitters::burn:
			return damage * 0.10f;
	}
	
	return damage;
}

void onTick(CBlob@ this)
{
	u32 tick = this.getTickSinceCreated();
	if (tick < 900 && getGameTime() % 10 == 0)
	{
		ParticleAnimated(CFileMatcher("LargeSmoke").getFirst(), this.getPosition() + Vec2f(XORRandom(32) - 16, XORRandom(16) - 8), Vec2f(0.5f, -0.75f), 0, 1.00f + (XORRandom(10) * 0.1f), 10 + XORRandom(10), 0, false);
	}
}