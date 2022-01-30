#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";
#include "RgbStuff.as";

const f32 max_time = 3.00f;

void onInit(CBlob@ this)
{
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient_domino.png");
}

void onDie(CBlob@ this)
{
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	f32 true_level = this.get_f32("dominoed");		
	f32 level = 1.00f + true_level;
	
	if (true_level <= 0)
	{
		if (isServer())
		{
			this.server_Die();
		}
	
		if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		f32 time = f32(getGameTime() * level);
		
		f32 modifier = Maths::Min(level / max_time, 1);
		modifier = modifier * modifier * modifier;
		// f32 modifier = level / 3.00f;
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 1.20f * modifier;
			moveVars.jumpFactor *= 1.20f * modifier;
		}	
				
		if (modifier >= 1)
		{
			if (this.getTickSinceCreated() % 15 == 0)
			{
				f32 maxHealth = Maths::Ceil(this.getInitialHealth() * 2.00f);
				if (this.getHealth() < maxHealth)
				{				
					if (isServer())
					{
						this.server_SetHealth(Maths::Min(this.getHealth() + 0.0625f, maxHealth));
					}
					
					if (isClient())
					{
						for (int i = 0; i < 2; i++)
						{
							ParticleAnimated("HealParticle.png", this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), Vec2f(0, f32(XORRandom(100) * -0.02f)) * 0.25f, 0, 0.5f, 10, 0, true);
						}
					}
				}
			}	
		}
		else
		{
			f32 invModifier = 1.00f - modifier;
		
			if (getKnocked(this) == 0 && XORRandom(500 * modifier) <25 )
			{
				u8 knock = (30 + XORRandom(90)) * invModifier;
			
				SetKnocked(this, knock);
				this.getSprite().PlaySound("TraderScream.ogg", 0.8f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			}
			
			if (isClient())
			{
				if (this.isMyPlayer())
				{
					f32 rot;
					rot += Maths::Sin(getGameTime() / 30.0f) * invModifier * 1.8f;
					rot += Maths::Cos(getGameTime() / 25.0f) * invModifier * 1.3f;
					rot += Maths::Sin(380 + getGameTime() / 40.0f) * invModifier * 2.5f;
					
					CCamera@ cam = getCamera();
					cam.setRotation(rot);
					int colTime = (getGameTime() % 100) * 5;
					SColor col = RedToBlack(colTime,5 / invModifier);
								
					SetScreenFlash(255 * invModifier, col.getRed(), col.getGreen(), col.getBlue(), 2 * invModifier);
					ShakeScreen(100.0f * invModifier, 1, this.getPosition());
				}
			}
			
			if (XORRandom(500 * invModifier) == 0)
			{
				switch (XORRandom(2))
				{
					case 0:
						this.setKeyPressed(key_action1, true);
						break;
					
					case 1:
						this.setKeyPressed(key_action2, true);
						break;
				}
			
				
			}
		}
	
		// print("" + modifier);
		// print("" + level / max_time);
		this.set_f32("dominoed", Maths::Max(0, this.get_f32("dominoed") - (0.0003f)));
	}
	
	// print("" + true_level);
	// print("" + (1.00f / (level)));
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 true_level = this.get_f32("dominoed");		
	f32 level = 1.00f + true_level;
	f32 modifier = Maths::Min(level / max_time, 1);
	
	if (modifier >= 1)
	{
		return damage / Maths::Min(level, 2);
	}
	else
	{
		switch (customData)
		{
			case Hitters::nothing:
			case Hitters::suicide:
			case Hitters::suddengib:
				return 0;
		}
	}

	return damage;
}

SColor RedToBlack2(s16 time, f32 speed)
{
	float red = 0;
	if(time > 255)
	{
		red = 255;
		float rm = time * speed % 255;
		red -= rm;
	}
	else
	{
		red = time * speed;
	}
	

	return SColor(255,red,0,0);
}



