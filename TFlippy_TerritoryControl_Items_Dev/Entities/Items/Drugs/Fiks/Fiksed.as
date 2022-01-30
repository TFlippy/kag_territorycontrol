#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

const f32 health_increment = 0.0625f;

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;

	f32 true_level = this.get_f32("fiksed");
	f32 level = 1.00f + true_level;

	if (true_level <= 0)
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else if (true_level <= 8)
	{
		if (this.getTickSinceCreated() % 6 == 0)
		{
			f32 maxHealth = this.getInitialHealth() * 1.5f;
			if (this.getHealth() < maxHealth)
			{
				if (isServer())
				{
					this.server_SetHealth(this.getHealth() + health_increment * level);
					this.sub_f32("fiksed", health_increment);
				}

				if (isClient())
				{
					if (this.isMyPlayer()) this.getSprite().PlaySound("heart.ogg", 0.50f, 1.00f);

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
		this.set_f32("fiksed", this.get_f32("fiksed") * 0.50f);

		SetKnocked(this, 90);
		this.getSprite().PlaySound("drunk_fx4", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);	
	}

	// this.set_f32("fiksed", Maths::Max(0, this.get_f32("fiksed") - (0.0050f)));

	// print("" + true_level);
	// print("" + (1.00f / (level)));
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 true_level = this.get_f32("fiksed");
	f32 level = 1.00f + true_level;

	if (level > 1)
	{
		return damage / Maths::Min(level, 2);
	}

	return damage;
}
