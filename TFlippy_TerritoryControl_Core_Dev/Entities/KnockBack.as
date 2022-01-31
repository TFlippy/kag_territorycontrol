// Knockback on hit - put before any damaging things but after any scalers
#include "Hitters.as"
#include "HittersTC.as"

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 x_side = 0.0f;
	f32 y_side = 0.0f;
	//if (hitterBlob !is null)
	{
		//Vec2f dif = hitterBlob.getPosition() - this.getPosition();
		if (velocity.x > 0.7)
		{
			x_side = 1.0f;
		}
		else if (velocity.x < -0.7)
		{
			x_side = -1.0f;
		}

		if (velocity.y > 0.5)
		{
			y_side = 1.0f;
		}
		else
		{
			y_side = -1.0f;
		}
	}
	f32 scale = 1.0f;

	//scale per hitter
	switch (customData)
	{
		case Hitters::fall:
		case Hitters::drown:
		case Hitters::burn:
		case Hitters::crush:
		case Hitters::spikes:
		case Hitters::arrow:
		case HittersTC::poison:
			scale = 0.0f;
			break;
			
		case HittersTC::bullet_low_cal:
		case HittersTC::shotgun:
			scale = 0.7f;
			break;

		case HittersTC::bullet_high_cal:
		case HittersTC::railgun_lance:
			scale = 0.6f;
			break;
			
		default: 
			break;
	}

	Vec2f f(x_side, y_side);

	if (damage > 0.125f)
	{
		this.AddForce(f * 15.0f * Maths::Min(40.00f, scale * Maths::Log(2.0f * (10.0f + (damage * 2.0f)))));
	}

	return damage; //damage not affected
}
