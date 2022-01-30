//common "can a plant grow at this tile" code

bool isNotTouchingOthers(CBlob@ this)
{
	CBlob@[] overlapping;

	if (this.getOverlapping(@overlapping))
	{
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ blob = overlapping[i];
			if (blob.getName() == "seed" || blob.getName() == "tree_bushy" || blob.getName() == "tree_pine")
			{
				return false;
			}
		}
	}

	return true;
}

bool canGrowAt(CBlob@ this, Vec2f pos)
{
	if (!this.getShape().isStatic()) // they can be static from grid placement
	{
		if (!this.isOnGround() || this.isInWater() || this.isAttached() || !isNotTouchingOthers(this))
		{
			return false;
		}
	}

	CMap@ map = this.getMap();

	/*if ( map.isTileGrass( map.getTile( pos ) )) {
	return false;
	}*/   // waiting for better days

	if (map.getSectorAtPosition(pos, "no build") !is null)
	{
		return false;
	}

	TileType tile = map.getTile(Vec2f(pos.x, pos.y + 5)).type;
	return map.isTileGroundStuff(tile) || map.isTileWood(tile) || tile == CMap::tile_castle_moss;
}
