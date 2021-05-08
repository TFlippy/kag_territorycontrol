
// determine color of all sides of the map border

bool tileOnRow(CMap@ map, const int[]@ row)
{
	//looks for tiles along an X axis of a maps width
	const int mapTileWidth = map.tilemapwidth;

	for (int x = 0; x < mapTileWidth; x++)
	{
		for (int i = 0; i < row.length; i++)
		{
			const int y = row[i];
			if (map.getTileFromTileSpace(Vec2f(x, y)).type != CMap::tile_empty) return true;
		}
	}
	return false;
}

bool tileOnColumn(CMap@ map, const int[]@ column)
{
	//looks for tiles along a Y axis of a maps height
	const int mapTileHeight = map.tilemapheight;

	for (int y = 0; y < mapTileHeight; y++)
	{
		for (int i = 0; i < column.length; i++)
		{
			const int x = column[i];
			if (map.getTileFromTileSpace(Vec2f(x, y)).type != CMap::tile_empty || map.isInWater(map.getTileWorldPosition(Vec2f(x, y)))) return true;
		}
	}
	return false;
}

void onTick(CRules@ this) //enable on first tick in order to work at all times
{
	Reset(this, getMap());

	this.RemoveScript("DefaultBorder.as");
}

void Reset(CRules@ this, CMap@ map)
{
	if (map !is null)
	{
		map.SetBorderFadeWidth(24.0f);

		const int[] sideBorders = {0, map.tilemapwidth - 1};
		const int[] topBorder = {0};
		const int[] bottomBorder = {map.tilemapheight - 1};

		map.SetBorderColourLeft(tileOnColumn(@map, @sideBorders) ? 0xff000000 : 0x000000);
		map.SetBorderColourRight(tileOnColumn(@map, @sideBorders) ? 0xff000000 : 0x000000);
		map.SetBorderColourTop(tileOnRow(@map, @topBorder) ? 0xff000000 : 0x000000);
		map.SetBorderColourBottom(tileOnRow(@map, @bottomBorder) ? 0xff000000 : 0x000000);

		//remove background on sky maps
		//if (!tileOnRow(@map, @bottomRow)) map.CreateSky(color_white, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
	}
}
