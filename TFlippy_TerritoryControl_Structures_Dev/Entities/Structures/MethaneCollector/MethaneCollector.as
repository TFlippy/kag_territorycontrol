// A script by TFlippy & Pirate-Rob

#include "MakeMat.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetStatic(true);

	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 300;

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("MethaneCollector_Loop.ogg");
	sprite.SetEmitSoundVolume(0.4f);
	sprite.SetEmitSoundSpeed(1.0f);
	sprite.SetEmitSoundPaused(false);
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ storage = FindStorage(this.getTeamNum());

		if (storage !is null)
		{
			MakeMat(storage, this.getPosition(), "mat_methane", 4 + XORRandom(5));
		}
		else if (this.getInventory().getCount("mat_methane") < 100)
		{
			MakeMat(this, this.getPosition(), "mat_methane", 4 + XORRandom(5));
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return ((this.getTeamNum() > 100 ? true : forBlob.getTeamNum() == this.getTeamNum()) && this.getDistanceTo(forBlob) < 32);
}

CBlob@ FindStorage(u8 team)
{
	if (team >= 100) return null;

	CBlob@[] blobs;
	getBlobsByName("gastank", @blobs);

	CBlob@[] validBlobs;

	for (u32 i = 0; i < blobs.length; i++)
	{
		if (blobs[i].getTeamNum() == team && blobs[i].getInventory().getCount("mat_methane") < 500)
		{
			validBlobs.push_back(blobs[i]);
		}
	}

	if (validBlobs.length == 0) return null;

	return validBlobs[XORRandom(validBlobs.length)];
}
