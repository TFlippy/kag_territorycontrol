// Lantern script
#include "FireParticle.as"
#include "FireCommon.as";
#include "Hitters.as";

const SColor lightColor = SColor(255, 255, 150, 50);
const float tickRate = 5;

void onInit(CBlob@ this)
{
	this.Tag("dangerous");
	this.set_u8("heat", 0);

	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(lightColor);
	
	this.getCurrentScript().tickFrequency = tickRate;
}

void onTick(CBlob@ this)
{
	if (this.isInWater())
	{
		if (!isClient()){ return;}
		makeSteamParticle(this, Vec2f(), XORRandom(100) > 50 ? "MediumSteam" : "SmallSteam");
		// this.getSprite().PlaySound("Steam.ogg");
		return;
	}
	
	if (XORRandom(100) < 70)
	{
		CMap@ map = getMap();
		Vec2f pos = this.getPosition();

		CBlob@[] blobs;
		
		if (map.getBlobsInRadius(pos, 8.0f, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{		
				CBlob@ blob = blobs[i];
				if (blob.hasTag("flesh") || blob.hasTag("plant")) map.server_setFireWorldspace(blob.getPosition(), true);
			}
		}
		
		if (map.getTile(pos).type == CMap::tile_wood_back) map.server_setFireWorldspace(pos, true);
		if (map.getTile(pos + Vec2f(0, 8)).type == CMap::tile_wood) map.server_setFireWorldspace(pos + Vec2f(0, 8), true);
	}
	if(isClient())
	{
		if ( XORRandom(100) < 60) this.getSprite().PlaySound("FireRoar.ogg");
		makeSteamParticle(this, Vec2f(), XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
	}
	
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(filename, this.getPosition() + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}

