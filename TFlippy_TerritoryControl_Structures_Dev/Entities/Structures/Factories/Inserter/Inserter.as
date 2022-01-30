#include "MakeMat.as";

void onInit(CSprite@ this)
{
	this.SetZ(-50);

	// this.RemoveSpriteLayer("gear");
	// CSpriteLayer@ gear = this.addSpriteLayer("gear", "Inserter.png", 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	// if (gear !is null)
	// {
		// Animation@ anim = gear.addAnimation("default", 0, false);
		// anim.AddFrame(1);
		// gear.SetOffset(Vec2f(0.0f, 2.0f));
		// gear.SetAnimation("default");
		// gear.SetRelativeZ(-60);
	// }
}

// void onTick(CSprite@ this)
// {
	// if(this.getSpriteLayer("gear") !is null){
		// this.getSpriteLayer("gear").RotateBy(-15, Vec2f(0.0f, 0.0f));
	// }
// }

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (caller !is null && caller.isOverlapping(this) && caller.getCarriedBlob() !is this)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());

		int icon = !this.isFacingLeft() ? 18 : 17;

		CButton@ button = caller.CreateGenericButton(icon, Vec2f(0, 0), this, this.getCommandID("use"), "Use", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if (caller !is null)
	{
		if (cmd == this.getCommandID("use"))
		{
			this.SetFacingLeft(!this.isFacingLeft());
		}
	}
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;

	this.Tag("ignore extractor");
	this.Tag("builder always hit");
	this.addCommandID("use");

	this.inventoryButtonPos = Vec2f(0, 16);
}

void onTick(CBlob@ this)
{
	const bool cycle = this.get_bool("inserter_cycle");
	const f32 sign = this.isFacingLeft() ? -1 : 1;

	CMap@ map = getMap();

	if (cycle)
	{
		CBlob@ right = map.getBlobAtPosition(this.getPosition() + Vec2f(12 * sign, 0));
		if (right !is null)
		{
			CInventory@ inv = right.getInventory();
			CInventory@ t_inv = this.getInventory();

			if (inv !is null && t_inv !is null)
			{
				CBlob@ item = inv.getItem(0);
				if (item !is null)
				{
					string blobName = right.getName();
					if (t_inv.getItem(0) is null && 
					    blobName != "builder" && blobName != "engineer" && blobName != "hazmat" ) //certain classes won't be affected
					{
						this.server_PutInInventory(item);
						this.getSprite().PlaySound("bridge_open.ogg", 1.00f, 1.00f);
					}
				}
			}
		}
	}
	else
	{
		CBlob@ left = map.getBlobAtPosition(this.getPosition() + Vec2f(-12 * sign, 0));
		if (left !is null)
		{
			CInventory@ inv = this.getInventory();
			if (inv !is null)
			{
				CBlob@ item = inv.getItem(0);
				if (item !is null)
				{
					if (!left.server_PutInInventory(item))
					{
						this.server_PutInInventory(item);
						this.getSprite().PlaySound("bridge_close.ogg", 1.00f, 1.00f);
					}
				}
			}
		}
	}

	this.set_bool("inserter_cycle", !cycle);
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob !is null && forBlob.isOverlapping(this));
}