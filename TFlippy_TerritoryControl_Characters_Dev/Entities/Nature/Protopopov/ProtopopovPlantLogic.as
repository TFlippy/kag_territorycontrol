#include "PlantGrowthCommon.as";
#include "MakeSeed.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(2) == 0);

	this.getCurrentScript().tickFrequency = 45;
	this.getSprite().SetZ(10.0f);

	this.Tag("builder always hit");
	this.Tag("nature");
	this.Tag("protopopov");
	
	// this.set_u8(growth_chance, default_growth_chance);
	this.set_u8(growth_time, 30);
	this.set_u8(grown_amount, 8);
	
	// this script gets removed so onTick won't be run on client on server join, just onInit
	if (this.hasTag("instant_grow"))
	{
		GrowProtopopov(this);
	}
}


void onTick(CBlob@ this)
{
	if (this.hasTag(grown_tag))
	{
		GrowProtopopov(this);
	}
	
	// if (isServer() && this.hasTag("has bulb") && XORRandom(5) == 0 && getTaggedBlobsInRadius(getMap(), this.getPosition(), 64, "protopopov") < 4)
	// {
		// CBlob@ seed = server_MakeSeed(this.getPosition() + Vec2f(0, -32), "protopopov_plant", 90);
		// if (seed !is null)
		// {
			// seed.setVelocity(Vec2f(((XORRandom(100) / 100.00f) * 12.00f) - 6.0f, -4 -((XORRandom(100) / 100.00f) * 4.00f)));
		// }
	// }
}

void GrowProtopopov(CBlob @this)
{
	this.Tag("has bulb");
	// this.getCurrentScript().runFlags |= Script::remove_after_this;
}

// u32 getTaggedBlobsInRadius(CMap@ map, const Vec2f pos, const f32 radius, const string tag)
// {
	// CBlob@[] blobs;
	// map.getBlobsInRadius(pos, radius, @blobs);

	// u32 counter = 0;
	
	// for (int i = 0; i < blobs.length; i++)
	// {
		// if (blobs[i].hasTag(tag)) counter++;
	// }

	// return counter;
// }
