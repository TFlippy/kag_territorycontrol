#include "Hitters.as"
#include "HittersTC.as"

void onInit(CBlob@ this)
{
	this.Tag("stone");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	const bool heavy = this.hasTag("heavy weight");
	f32 dmg = damage;
	
	switch (customData)
	{
		case Hitters::builder:
			dmg *= 4.00f;
			break;

		case Hitters::spikes:
		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			dmg *= 0.25f * (this.hasTag("blocks sword") ? 0.00f : 1.00f);
			break;

		case Hitters::drill:
			dmg *= 2.50f;
			break;
			
		case Hitters::bomb_arrow:
		case Hitters::bomb:
			dmg *= 1.50f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 2.00f;
			break;

		case Hitters::fire:
			dmg *= 0.00f;
			break;
		
		case Hitters::burn:
			dmg *= 0.00f;
			break;
			
		case Hitters::cata_stones:
			dmg *= 5.00f;
			break;
		case Hitters::crush:
			dmg *= 3.00f;
			break;

		case Hitters::flying: // boat ram
			dmg *= 5.00f;
			break;
		
		// TC		
		case HittersTC::bullet_low_cal:
			dmg *= 0.25f;
			break;
			
		case HittersTC::bullet_high_cal:
			dmg *= 1.00f;
			break;
			
		case HittersTC::shotgun:
			dmg *= 0.25f;
			break;
			
		case HittersTC::radiation:
			dmg *= 0.00f;
			break;
	}
	
	return dmg;
}