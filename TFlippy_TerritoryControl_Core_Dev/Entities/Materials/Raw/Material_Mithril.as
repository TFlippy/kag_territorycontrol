#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(24.0f);
	this.SetLightColor(SColor(255, 25, 255, 100));

	this.maxQuantity = 250;

	this.getCurrentScript().tickFrequency = 15;
	this.getCurrentScript().runFlags |= Script::tick_not_inwater | Script::tick_not_ininventory;

	this.Tag("dangerous");
}

void onTick(CBlob@ this)
{
	if (this.getTickSinceCreated() < 120 || this.getQuantity() < 30) return;

	this.getCurrentScript().tickFrequency = (125 / Maths::Max(1, (this.getQuantity() / 2))) * 10.0f;

	// print("Freq: " + this.getCurrentScript().tickFrequency + "; Quantity: " + this.getQuantity());

	const f32 radius = 256 *  this.getQuantity() / 250.0f;
	// this.SetLightRadius(radius * 0.35f); // re-enable when asu's build releases it

	if (this.getQuantity() < 60) return;

	if (XORRandom(100) < 50)
	{
		if (isClient())
		{
			float mag = this.getQuantity() / 250.0f;
			MakeParticle(this, mag);
		}

		if (isServer())
		{
			this.server_SetQuantity(this.getQuantity() - 2);
			CMap@ map = getMap();

			CBlob@[] blobsInRadius;
			if (map.getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
			{
				for (int i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ blob = blobsInRadius[i];
					if ((blob.hasTag("flesh") || blob.hasTag("nature")) && !blob.hasTag("dead"))
					{
						Vec2f pos = this.getPosition();
						Vec2f bpos = blob.getPosition();
						Vec2f dir = bpos - pos;
						f32 len = dir.Length();
						dir.Normalize();

						int counter = 1;

						for(int i = 0; i < len; i += 8)
						{
							if (map.isTileSolid(pos + dir * i)) counter++;
						}

						const f32 distMod = Maths::Max(0, (1.00f - ((pos - bpos).Length() / radius)));

						if (XORRandom(100) < 100.0f * distMod)
						{
							this.server_Hit(blob, bpos, Vec2f(0, 0), 0.125f / counter, HittersTC::radiation, true);
						}
					}
				}
			}
		}
	}
}

void MakeParticle(CBlob@ this, float magnitude)
{
	CParticle@ p = ParticleAnimated("FalloutGas.png", this.getPosition() + getRandomVelocity(0, magnitude, 360), Vec2f(), float(XORRandom(360)), 1.00f + (magnitude * (XORRandom(100) / 100.0f)), 3 + (3 * magnitude), -0.05f, false);
	if (p !is null)
	{
		p.setRenderStyle(RenderStyle::additive);
		// p.deadeffect = 0;
	}
}