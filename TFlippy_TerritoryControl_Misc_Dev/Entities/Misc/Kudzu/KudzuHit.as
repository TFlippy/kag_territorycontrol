#include "Hitters.as"
#include "HittersTC.as"
#include "ParticleSparks.as";
#include "FireCommon.as"

void onInit(CBlob@ this)
{
	this.Tag("kudzu");
	this.Tag("builder always hit");
	this.Tag(spread_fire_tag);
	this.getSprite().SetRelativeZ(500);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	
	switch (customData)
	{
		case Hitters::builder:
			dmg *= 2.00f;
			if (isClient())
			{
				cuttingEffects(this, damage);
			}
			break;

		case Hitters::spikes:
		case Hitters::sword:
		case Hitters::stab:
			dmg *=  1.50f;
			if (isClient())
			{
				cuttingEffects(this, damage);
			}
			break;

		case Hitters::arrow:
			dmg *= 0.20f;
			break;
			
		case Hitters::bomb_arrow:
		case Hitters::bomb:
			dmg *= 0.25f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 0.25f;
			break;

		case Hitters::fire:
			dmg *= this.hasTag("Mut_FireResistance") ? 0.00f : 1.00f;
			break;
		
		case Hitters::burn:
			dmg *= this.hasTag("Mut_FireResistance") ? 0.00f : 2.00f;
			break;
			
		case Hitters::crush:
			dmg *= 0.40f;
			break;

		
		// TC		
		case HittersTC::bullet_low_cal:
			dmg *= 0.33f;
			break;
			
		case HittersTC::bullet_high_cal:
			dmg *= 0.50f;
			break;
			
		case HittersTC::shotgun:
			dmg *= 0.10f;
			break;
			
		case HittersTC::radiation:
			dmg *= this.hasTag("Mut_RadiationResistance") ? 0.00f : 1.50f;
			break;
			
		case HittersTC::electric:
			dmg *= 0.05f;
			break;
	}
	//print(this.getHealth() + "");
	return dmg;
}

void cuttingEffects(CBlob@ this, f32 damage)
{
	Sound::Play("/cut_grass", this.getPosition());
	for (int i = 0; i < (damage); ++i)
	{
		makeGibParticle("GenericGibs",
		this.getPosition(), getRandomVelocity(-90, (Maths::Min(Maths::Max(0.5f, damage), 2.0f) * 4.0f) , 270),
		7, 3 + XORRandom(4), Vec2f(8, 8),
		1.0f, 0, "", 0);
	}
}
