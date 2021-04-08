void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.setPosition(Vec2f(0,0)); // move boxes into one spot where it dont matter (moves shapes away from being ghosty in one area, objects and sounds work fine still)
	this.setVelocity(Vec2f(0,0));
	this.setAngularVelocity(0.0f);
	this.SetVisible(false);

	CShape@ shape = this.getShape();
	if (shape !is null)
	{
		shape.server_SetActive(false);
		shape.doTickScripts = false;

		ShapeConsts@ consts = shape.getConsts();
		consts.collidable = false;
		consts.mapCollisions = false;
	}
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.SetVisible(true);

	CShape@ shape = this.getShape();
	if (shape !is null)
	{
		shape.server_SetActive(true);
		shape.doTickScripts = true;
		shape.SetGravityScale(1.0f);

		ShapeConsts@ consts = shape.getConsts();
		consts.collidable = true;
		consts.mapCollisions = true;
	}
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	blob.AddScript("DisableInventoryCollisions");

	if (blob.isInInventory())
		onThisAddToInventory(blob, null);
}
