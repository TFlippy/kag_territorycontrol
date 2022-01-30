#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(0.0f);
	this.SetLightColor(SColor(255, 25, 200, 255));
	
	this.maxQuantity = 100;
	
	this.getCurrentScript().tickFrequency = 15;
	// this.getCurrentScript().runFlags |= Script::tick_not_inwater; // | Script::tick_not_ininventory;
	this.getCurrentScript().runFlags |= Script::tick_not_inwater | Script::tick_not_ininventory;
	
	this.Tag("dangerous");
}

void onTick(CBlob@ this)
{	
	this.doTickScripts = true;
	this.getCurrentScript().tickFrequency = (25 / Maths::Max(1, (this.getQuantity() / 2))) * 4.0f;
	
	// print("Freq: " + this.getCurrentScript().tickFrequency + "; Quantity: " + this.getQuantity());
	
	if (this.getQuantity() <= 0) return;
	
	f32 radius = 256 * this.getQuantity() / 50.0f;
	this.SetLightRadius(radius * 0.50f);
	
	if (XORRandom(100) < 90) 
	{
		if (isClient())
		{
			float mag = this.getQuantity() / 250.0f;
			MakeParticle(this, mag * 2.00f);
		}
	
		if (isServer())
		{
			if (XORRandom(100) < 25) this.server_SetQuantity(this.getQuantity() - 1);
		
			CBlob@[] blobsInRadius;
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
			{
				for (int i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ blob = blobsInRadius[i];
					if ((blob.hasTag("flesh") || blob.hasTag("nature")) && !blob.hasTag("dead"))
					{
						Vec2f pos = this.getPosition();
						Vec2f dir = blob.getPosition() - pos;
						f32 len = dir.Length();
						dir.Normalize();

						int counter = 1;

						for(int i = 0; i < len; i += 8)
						{
							if (getMap().isTileSolid(pos + dir * i)) counter++;
						}
						
						f32 distMod = Maths::Max(0, (1.00f - ((this.getPosition() - blob.getPosition()).Length() / radius)));
						
						if (XORRandom(100) < 100.0f * distMod) 
						{
							this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.0625f / counter, HittersTC::radiation, true);
						}
					}
				}
			}
		}
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}

void MakeParticle(CBlob@ this, float magnitude)
{
	CParticle@ p = ParticleAnimated("FalloutGas.png", this.getPosition() + getRandomVelocity(0, magnitude * 32, 360), Vec2f(), float(XORRandom(360)), 1.00f + (magnitude * 2 * (XORRandom(100) / 100.0f)), 3 + (6 * magnitude), -0.05f, false);
	if (p !is null)
	{
		p.setRenderStyle(RenderStyle::additive);
		// p.deadeffect = 0;
	}
}