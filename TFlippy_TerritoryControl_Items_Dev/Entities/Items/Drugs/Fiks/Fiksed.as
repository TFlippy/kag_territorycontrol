#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

void onInit(CBlob@ this)
{
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	f32 true_level = this.get_f32("fiksed");		
	f32 level = 1.00f + true_level;
	
	if (true_level <= 0)
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else if (true_level <= 2)
	{
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 1.15f;
			moveVars.jumpFactor *= 1.15f;
		}	
				
		if (this.getTickSinceCreated() % 10 == 0)
		{
			f32 maxHealth = Maths::Ceil(this.getInitialHealth() * 1.50f);
			if (this.getHealth() < maxHealth)
			{				
				if (getNet().isServer())
				{
					this.server_SetHealth(Maths::Min(this.getHealth() + 0.125f, maxHealth));
				}
				
				if (getNet().isClient())
				{
					for (int i = 0; i < 4; i++)
					{
						ParticleAnimated("HealParticle.png", this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), Vec2f(0, f32(XORRandom(100) * -0.02f)) * 0.25f, 0, 0.5f, 10, 0, true);
					}
				}
			}
		}	
	}
	else
	{
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 0.75f;
			moveVars.jumpFactor *= 0.50f;
		}	
				
		if (this.getTickSinceCreated() % 20 == 0)
		{
			if (this.getHealth() > 0.50f)
			{				
				if (getNet().isServer())
				{
					this.server_Hit(this, this.getPosition(), Vec2f(0, 0), 0.25f, HittersTC::radiation, true);
				}
			}
		}	
	}
	
	this.set_f32("fiksed", Maths::Max(0, this.get_f32("fiksed") - (0.0010f)));
	
	// print("" + true_level);
	// print("" + (1.00f / (level)));
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 true_level = this.get_f32("fiksed");		
	f32 level = 1.00f + true_level;

	if (level > 1)
	{
		return damage / Maths::Min(level, 4);
	}
	
	return damage;
}