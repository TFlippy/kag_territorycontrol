#include "MapFlags.as"
#include "MinableMatsCommon.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getShape().SetRotationsAllowed( false );
	this.getShape().getConsts().mapCollisions = false;
	this.getSprite().getConsts().accurateLighting = false;  
	this.getSprite().SetZ(100); //background

	this.Tag("builder always hit");
	this.Tag("blocks sword");

	this.SetLight(true);
	this.SetLightRadius(72.0f);
	this.SetLightColor(SColor(255, 255, 150, 50));

	// this.getCurrentScript().runFlags |= Script::tick_not_attached;

	HarvestBlobMat[] mats = {};
	mats.push_back(HarvestBlobMat(15.0f, "mat_stone")); 
	mats.push_back(HarvestBlobMat(1.0f, "mat_copperwire"));
	this.set("minableMats", mats);	
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}