// A script by TFlippy & Pirate-Rob

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "BuilderHittable.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	this.Tag("builder always hit");
	this.Tag("change team on fort capture");
	this.Tag("oil_tank");

	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png",6,Vec2f(8,8));
	this.SetMinimapRenderAlways(true);
	
	AddIconToken("$icon_oil$","Material_Oil.png",Vec2f(16,16),0);
}