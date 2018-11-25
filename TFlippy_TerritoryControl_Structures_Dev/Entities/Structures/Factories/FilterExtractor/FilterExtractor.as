#include "MakeMat.as";

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-50);

	this.RemoveSpriteLayer("gear");
	CSpriteLayer@ gear = this.addSpriteLayer("gear", "Extractor.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	
	if (gear !is null)
	{
		Animation@ anim = gear.addAnimation("default", 0, false);
		anim.AddFrame(2);
		gear.SetOffset(Vec2f(0.0f, -3.0f));
		gear.SetAnimation("default");
		gear.SetRelativeZ(-60);
	}
}

void onTick(CSprite@ this)
{
	if(this.getSpriteLayer("gear") !is null){
		this.getSpriteLayer("gear").RotateBy(3, Vec2f(0.5f,-0.5f));
	}
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 90;

	this.Tag("ignore extractor");
	this.Tag("builder always hit");
}

void onTick(CBlob@ this)
{
	if (getNet().isServer())
	{
		CBlob@[] blobs;
		// if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobs))
		if (getMap().getBlobsInBox(this.getPosition() + Vec2f(-32, -32), this.getPosition() + Vec2f(32, 32), @blobs))
		{
			for (uint i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];
				if(b.getInventory() !is null && !b.hasTag("player"))
				{
					if (!b.isInventoryAccessible(this) || b.hasTag("ignore extractor")) continue;

					int count = b.getInventory().getItemsCount();
					for (int i = 0; i < count; i++)
					{
						CBlob@ item = b.getInventory().getItem(i);
						if (item !is null && this.hasBlob(item.getConfig(), 0) || this.hasBlob(item.getConfig(), 1))
						{
							b.server_PutOutInventory(item);
							item.setPosition(this.getPosition());
						
							return;
						}
					}
					
					// if (b.getInventory().getItemsCount() > 0)
					// {
						// // return !(this.hasBlob(blob.getConfig(), 0) || this.hasBlob(blob.getConfig(), 1));
					
						// CBlob@ item = b.getInventory().getItem(0);

						// b.server_PutOutInventory(item);
						// item.setPosition(this.getPosition());
					// }
				}
			}
		}
	}
}
