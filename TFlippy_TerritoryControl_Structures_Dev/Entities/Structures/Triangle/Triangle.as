//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"
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
	
	this.getShape().SetOffset(Vec2f(-1.25f, 1.25f));
	
	MakeDamageFrame( this );
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	string name = this.getName();
	HarvestBlobMat[] mats = {};
	if (name == "wood_triangle") mats.push_back(HarvestBlobMat(1.0f, "mat_wood"));
	else if (name == "stone_triangle") mats.push_back(HarvestBlobMat(1.0f, "mat_stone"));
	else if (name == "concrete_triangle") mats.push_back(HarvestBlobMat(2.0f, "mat_concrete"));
	else if (name == "iron_triangle") mats.push_back(HarvestBlobMat(1.0f, "mat_ironingot"));
	this.set("minableMats", mats);		 
}

void MakeDamageFrame( CBlob@ this )
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ( (hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
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
