#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("explosive");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::sword:
			damage = 0;
			break;
	}
	
	return damage;
}

// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// print("hit");
	
	// return this.getTeamNum() != blob.getTeamNum() && blob.hasTag("building");
// }

// bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
// {
	// return this.getTeamNum() != blob.getTeamNum() && blob.hasTag("building");
// }