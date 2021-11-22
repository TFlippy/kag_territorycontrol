
void onInit(CBlob @ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getShape().SetRotationsAllowed(false);
	this.Tag("place norotate");

	this.Tag("ignore extractor");
	this.Tag("builder always hit");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || this.isAttached()) return;

	if (!blob.isAttached() && !blob.hasTag("player") && !blob.getShape().isStatic() && (blob.hasTag("material") || blob.hasTag("hopperable")))
	{
		if (isServer()) this.server_PutInInventory(blob);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	// return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
	return forBlob !is null && (forBlob.getPosition() - this.getPosition()).Length() <= 64;
}