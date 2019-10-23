
#include 'MaterialCommon.as';

// Use `.Tag('custom quantity')` to
// prevent the quantity from being
// set when initialized

// Remember to set the tag before
// initializing. It's only supposed
// to be set on the server-side. An
// example can be found in Material-
// Common.as

void onInit(CBlob@ this)
{
	if (isServer())
	{
		this.server_setTeamNum(-1);

		if (this.hasTag('custom quantity'))
		{
		  // Remove unused tag
			this.Untag('custom quantity');
		}
		else
		{
			this.server_SetQuantity(this.maxQuantity);
		}
	}

	this.Tag('material');

	this.getShape().getVars().waterDragScale = 12.0f;

	if (isClient())
	{
		// Force inventory icon update
		Material::updateFrame(this);
	}
	
	if (this.isInInventory())
	{
		CShape@ shape = this.getShape();
		if (shape !is null)
		{
			ShapeConsts@ consts = shape.getConsts();
			consts.collidable = false;
			consts.mapCollisions = false;
		}	
	}
}

void onQuantityChange(CBlob@ this, int old)
{
  if (isServer())
  {
    // Kill 0-materials
    if (this.getQuantity() == 0)
    {
      this.server_Die();
      return;
    }
  }

  if (isClient())
  {
    Material::updateFrame(this);
  }
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	// print("doesCollideWithBlob: " + this.getName() + " with " + blob.getName());

	// print("test");
	
	if (blob.hasTag('solid')) return true;
	if (blob.getShape().isStatic()) return true;
	// if (this.getTeamNum() != blob.getTeamNum() && this.hasTag("explosive") && blob.hasTag("building")) return true;
	
	return false;
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	// print("onThisAddToInventory:" + this.getName());

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
	// print("onThisRemoveFromInventory: " + this.getName());

	CShape@ shape = this.getShape();
	if (shape !is null)
	{
		ShapeConsts@ consts = shape.getConsts();
		consts.collidable = true;
		consts.mapCollisions = true;
	}
}

// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// if (blob !is null) print("onCollision: " + this.getName() + " with " + blob.getName());
	// else print("onCollision: " + this.getName() + " with World");
// }