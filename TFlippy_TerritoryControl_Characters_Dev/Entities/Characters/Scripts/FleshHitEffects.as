
#include "Hitters.as"
#include "HittersTC.as"

void onInit(CBlob@ this)
{
	this.Tag("flesh");
}

string[] screams = 
{
	"man_scream.ogg",
	"MigrantScream1.ogg"
};

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (!isClient())
		return damage;

	if (hitterBlob !is this || customData == Hitters::crush)  //sound for anything actually painful
	{
		f32 capped_damage = Maths::Min(damage, 2.0f);

		//set this false if we whouldn't show blood effects for this hit
		bool showblood = true;

		//read customdata for hitter
		switch (customData)
		{
			case HittersTC::staff:
				// showblood = false;
				
				this.getSprite().PlaySound("nightstick_hit" + (1 + XORRandom(3)) + ".ogg", 0.9f, 0.8f);
				break;
		
			case Hitters::drown:
			case Hitters::burn:
			case Hitters::fire:
			case HittersTC::electric:
			case HittersTC::forcefield:
				showblood = false;
				break;

			case Hitters::sword:
				Sound::Play("SwordKill", this.getPosition());
				break;

			case Hitters::stab:
				if (this.getHealth() > 0.0f && damage > 1.0f)
				{
					this.Tag("cutthroat");
				}
				
				Sound::Play("KnifeStab.ogg", this.getPosition());
				break;
				
			case HittersTC::radiation:
				// All KAG players have a built-in Geiger counter.
				showblood = false;
				if (this.isMyPlayer()) 
				{
					Sound::Play("geiger" + XORRandom(3) + ".ogg", this.getPosition(), 0.7f, 1.0f);
				}
				break;

			default:
				Sound::Play("FleshHit.ogg", this.getPosition());
				break;
		}

		worldPoint.y -= this.getRadius() * 0.5f;

		// Scream when injured
		if (this.getHealth() < 1.00f && getGameTime() > this.get_u32("last_scream") && !this.hasTag("dead") && this.hasTag("human")) 
		{
			this.getSprite().PlaySound(screams[XORRandom(screams.length)], 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f); 
			this.set_u32("last_scream", getGameTime() + 30 * 10);
		}
		
		if (showblood)
		{
			if (capped_damage > 1.0f)
			{
				ParticleBloodSplat(worldPoint, true);
			}

			if (capped_damage > 0.25f)
			{
				for (f32 count = 0.0f ; count < capped_damage; count += 0.5f)
				{
					ParticleBloodSplat(worldPoint + getRandomVelocity(0, 0.75f + capped_damage * 2.0f * XORRandom(2), 360.0f), false);
				}
			}

			if (capped_damage > 0.01f)
			{
				f32 angle = (velocity).Angle();

				for (f32 count = 0.0f ; count < capped_damage + 0.6f; count += 0.1f)
				{
					Vec2f vel = getRandomVelocity(angle, 1.0f + 0.3f * capped_damage * 0.1f * XORRandom(40), 60.0f);
					vel.y -= 1.5f * capped_damage;
					
					f32 mod = XORRandom(100) * 0.01f;
					{
						
						CParticle@ p = ParticleBlood(worldPoint, vel * -1.0f, SColor(255 - (40 * mod), 126 - (20 * mod), 0, 0));
						if (p !is null)
						{
							p.timeout = 1 + XORRandom(60);
							p.scale = 0.75f + mod;
							p.fastcollision = true;
							// p.stretches = true;
						}
					}
					
					{
						CParticle@ p = ParticleBlood(worldPoint, vel * 1.7f, SColor(255, 126, 0, 0));
						if (p !is null)
						{
							p.timeout = 1 + XORRandom(60);
							p.scale = 0.75f + mod;
							p.fastcollision = true;
							// p.stretches = true;
						}
					}
						
	// int16 alivetime
					
					// ParticleBlood(worldPoint, vel * 1.7f, SColor(255, 126, 0, 0));
					
					// ParticlePixel(worldPoint, vel * -1.0f, SColor(255, 126, 0, 0), false, 60);
					// ParticlePixel(worldPoint, vel * 1.7f, SColor(255, 126, 0, 0), false, 60);
				}
			}
		}
	}

	return damage;
}

