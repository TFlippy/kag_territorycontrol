void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	CShape@ shape = this.getShape();
	if (shape !is null)
	{
		ShapeConsts@ consts = shape.getConsts();
		consts.collidable = false;
		consts.mapCollisions = false;
	}	
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	CShape@ shape = this.getShape();
	if (shape !is null)
	{
		ShapeConsts@ consts = shape.getConsts();
		consts.collidable = true;
		consts.mapCollisions = true;
	}
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	blob.AddScript("DisableInventoryCollisions");
}