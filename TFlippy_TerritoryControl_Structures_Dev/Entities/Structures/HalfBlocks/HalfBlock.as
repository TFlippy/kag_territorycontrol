//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"
#include "ParticleSparks.as";
#include "MinableMatsCommon.as";

int openRecursion = 0;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
    this.getSprite().getConsts().accurateLighting = true;  
	this.Tag("builder always hit");
	
    //this.Tag("place norotate");
    
    //block knight sword
	this.Tag("blocks sword");

	this.Tag("blocks water");
	
	this.getShape().SetOffset(Vec2f(0, 2));
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;	

	string name = this.getName();
	HarvestBlobMat[] mats = {};
	if (name == "stone_halfblock") mats.push_back(HarvestBlobMat(1.0f, "mat_stone"));
	else if (name == "iron_halfblock") mats.push_back(HarvestBlobMat(1.0f, "mat_ironingot"));
	this.set("minableMats", mats);			 
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (hitterBlob.getName() == "peasant" && this.hasTag("metal"))
	{
		this.getSprite().PlaySound("/metal_stone.ogg");
		sparks(worldPoint, 1, 1);
		
		return 0.00f;
	}
	else
	{
		f32 dmg = damage;
		switch(customData)
		{
			case Hitters::builder:
				dmg *= 2.5f;
				break;
		}		
		return dmg;
	}
}
