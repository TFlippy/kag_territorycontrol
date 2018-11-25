#include "MapFlags.as"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
	this.getShape().getConsts().mapCollisions = false;
    this.getSprite().getConsts().accurateLighting = false;  
	this.getSprite().SetZ(100); //background

	this.Tag("builder always hit");

	this.SetLight(true);
	this.SetLightRadius(72.0f);
	this.SetLightColor(SColor(255, 255, 150, 50));

	// this.getCurrentScript().runFlags |= Script::tick_not_attached;	
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}