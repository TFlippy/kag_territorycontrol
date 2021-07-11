#include "Hitters.as"
#include "ParticleSparks.as";
#include "MinableMatsCommon.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(128) > 64);

	this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = false;

	CShape@ shape = this.getShape();
	shape.AddPlatformDirection(Vec2f(0, -1), 89, false);
	shape.SetRotationsAllowed(false);
	
	this.server_setTeamNum(-1); //allow anyone to break them

	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("blocks sword");

	
	HarvestBlobMat[] mats = {};
	mats.push_back(HarvestBlobMat(2.0f, "mat_ironingot"));
	this.set("minableMats", mats);	
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/build_wall.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob.getName() == "peasant")
	{
		this.getSprite().PlaySound("/metal_stone.ogg");
		sparks(worldPoint, 1, 1);
		
		return 0.00f;
	}
	else return damage;
}