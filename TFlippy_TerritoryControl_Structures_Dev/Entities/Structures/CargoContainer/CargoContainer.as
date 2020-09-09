#include "CargoAttachmentCommon.as"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-10.0f);
	
	
	this.inventoryButtonPos = Vec2f(-22, 0);
	this.set_Vec2f("store_offset", Vec2f(4, 0));
	this.Tag("remote_storage");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachCargo(this, blob);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob !is null && (this.getTeamNum() >= 100 ? true : this.getTeamNum() == forBlob.getTeamNum());	
}