// A script by TFlippy & Pirate-Rob

#include "CustomBlocks.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");
	this.Tag("oil_tank");
	this.Tag("extractable");
	
	if(isServer()){
		CMap@ map = getMap();
		for(int i = 0;i < 5;i++){
			map.server_SetTile(this.getPosition()+Vec2f(-8,8*i-16), CMap::tile_biron);
			map.server_SetTile(this.getPosition()+Vec2f(8,8*i-16), CMap::tile_biron);
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return ((this.getTeamNum() > 100 ? true : forBlob.getTeamNum() == this.getTeamNum()));
}