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
		gear.SetOffset(Vec2f(0.0f, -6.0f));
		gear.SetAnimation("default");
		gear.SetRelativeZ(-60);
	}
}

void onTick(CSprite@ this)
{
	if (this.getSpriteLayer("gear") !is null)
	{
		this.getSpriteLayer("gear").RotateBy(5, Vec2f(0.5f,-0.5f));
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
	if (isServer())
	{
		CBlob@[] blobs;
		// if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobs))
		if (getMap().getBlobsInBox(this.getPosition() + Vec2f(-40, -40), this.getPosition() + Vec2f(40, 40), @blobs))
		{
			for (uint i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];
				if (b.getInventory() !is null && !b.hasTag("player"))
				{
					if (!b.isInventoryAccessible(this) || b.hasTag("ignore extractor") || b.hasTag("vehicle")) continue;

					if (b.getInventory().getItemsCount() > 0)
					{
						for (int i = 0; i < b.getInventory().getItemsCount(); i++)
						{
							CBlob@ item = b.getInventory().getItem(i);
							if (item.getName() != "gyromat")
							{
								b.server_PutOutInventory(item);
								item.setPosition(this.getPosition());
								break;
							}
						}
					}
				}
			}
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.isOverlapping(this) && (forBlob.getCarriedBlob() is null || forBlob.getCarriedBlob().getName() == "gyromat");
	//return (forBlob.isOverlapping(this));
}

void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	if (blob.getName() != "gyromat")
	{
		this.server_PutOutInventory(blob);
		return;
	}

	this.getCurrentScript().tickFrequency = 90 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if (blob.getName() != "gyromat") return;

	this.getCurrentScript().tickFrequency = 90 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
}
