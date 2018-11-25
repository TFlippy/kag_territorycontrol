#include "Hitters.as"
#include "HittersTC.as"
#include "ParticleSparks.as";

void onInit(CBlob@ this)
{
	this.Tag("metal");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	const bool heavy = this.hasTag("heavy weight");
	f32 dmg = damage;
	
	switch (customData)
	{
		case Hitters::builder:
			dmg *= 1.25f;
			if (hitterBlob.hasTag("neutral")) DoMetalHitFX(this);
			break;

		case Hitters::spikes:
		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			dmg *= (this.hasTag("flesh") ? 0.80f : 0.20f);
			DoMetalHitFX(this);
			break;

		case Hitters::drill:
			dmg *= 0.50f;
			DoMetalHitFX(this);
			break;
			
		case Hitters::bomb_arrow:
		case Hitters::bomb:
			dmg *= 0.75f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 0.75f;
			break;

		case Hitters::fire:
			dmg *= 0.70f;
			break;
		
		case Hitters::burn:
			dmg *= 0.10f;
			break;
			
		case Hitters::cata_stones:
			dmg *= 0.60f;
			break;
		case Hitters::crush:
			dmg *= 0.80f;
			break;

		case Hitters::flying: // boat ram
			dmg *= 1.00f;
			break;
		
		// TC		
		case HittersTC::bullet_low_cal:
			dmg *= 0.33f;
			DoMetalHitFX(this);
			break;
			
		case HittersTC::bullet_high_cal:
			dmg *= 1.00f;
			DoMetalHitFX(this);
			break;
			
		case HittersTC::shotgun:
			dmg *= 0.10f;
			DoMetalHitFX(this);
			break;
			
		case HittersTC::radiation:
			dmg *= (this.hasTag("flesh") ? 0.50f : 0.00f);
			break;
			
		case HittersTC::electric:
			dmg *= (this.hasTag("flesh") ? 3.00f : 0.00f);
			break;
	}
	
	return dmg;
}

void DoMetalHitFX(CBlob@ this)
{
	this.getSprite().PlaySound("dig_stone.ogg", 1.0f, 0.8f + (XORRandom(100) / 1000.0f));
	// sparks(this.getPosition(), 1, 1);
}