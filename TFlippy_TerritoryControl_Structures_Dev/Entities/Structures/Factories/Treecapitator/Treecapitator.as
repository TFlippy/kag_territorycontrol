#include "Hitters.as"
#include "TreeCommon.as"

void onInit(CBlob @ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getShape().SetRotationsAllowed(false);
	this.Tag("place norotate");
	// this.Tag("ignore extractor");
	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 240;
}

void onTick(CBlob@ this)
{
	if (this.getInventory().isFull()) return;
	if (!this.getShape().isStatic()) return;

	if (isServer())
	{
		CMap@ map = getMap();

		CBlob@[] blobs;
		map.getBlobsAtPosition(this.getPosition() + Vec2f(8, 0), @blobs);
		map.getBlobsAtPosition(this.getPosition() + Vec2f(-8, 0), @blobs);

		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if (b !is null)
			{
				string bname = b.getName();

				if (bname == "grain" || bname == "pumpkin" || bname == "log" || bname == "ganjapod" )
				{
					this.server_PutInInventory(b);
				}
				else if (bname == "grain_plant" || bname == "pumpkin_plant" || bname == "ganja_plant")
				{
					if (b.hasTag("has pumpkin") || b.hasTag("has pod") || b.hasTag("has grain"))
					{
						this.server_Hit(b, b.getPosition(), Vec2f(0, 0), 2.00f, Hitters::saw);
					}
				}
				else if (b.hasTag("tree"))
				{
					TreeVars@ tree;
					b.get("TreeVars", @tree);
					if (tree !is null)
					{
						if (tree.height == tree.max_height)
						{
							this.server_Hit(b, b.getPosition(), Vec2f(0, 0), 4.00f, Hitters::saw);
						}
					}
				}
				else if (!b.getShape().isStatic())
				{
					this.server_Hit(b, b.getPosition(), Vec2f(0, 0), 0.50f, Hitters::saw);
				}
			}
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob !is null && (forBlob.getName() == "extractor" || forBlob.getName() == "filterextractor" || (forBlob.getPosition() - this.getPosition()).Length() <= 64);
}
