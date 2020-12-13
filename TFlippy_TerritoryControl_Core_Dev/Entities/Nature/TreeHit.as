#include "Hitters.as";
#include "HittersTC.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData != HittersTC::radiation && damage > 0.05f && isClient()) //sound for all damage
	{
		this.getSprite().PlayRandomSound("TreeChop");
		makeGibParticle("GenericGibs", worldPoint, getRandomVelocity((this.getPosition() - worldPoint).getAngle(), 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
		                0, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}

	if (customData == Hitters::burn || customData == Hitters::fire)
	{
		damage *= 3.0f;
	}
	
	if (customData == Hitters::sword)
	{
		damage *= 0.5f;
	}
	
	if (customData == Hitters::builder)
	{
		damage *= 4.0f;
	}

	if (isServer())
	{
		if ((customData == Hitters::fire || customData == Hitters::burn || customData == HittersTC::radiation || customData == Hitters::explosion) && damage >= this.getHealth())
		{
			CBlob@ tree = server_CreateBlob("deadtree", this.getTeamNum(), this.getPosition() + Vec2f(0, -32));
			
			this.Tag("no drop");
			this.server_Die();
		}
	}
	
	return damage;
}
