#include "PlantGrowthCommon.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(2) == 0);

	this.getCurrentScript().tickFrequency = 45;
	this.getSprite().SetZ(10.0f);

	this.Tag("builder always hit");
	this.Tag("nature");
	
	this.set_u8(growth_time, 30);
	this.set_u8(grown_amount, 8);
	
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
}

void GrowProtopopov(CBlob @this)
{
	this.Tag("has bulb");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
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
