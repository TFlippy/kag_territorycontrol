void AddTilesBySector(Vec2f ul, Vec2f lr, string sectorName, TileType tile, TileType omitTile = 255)
{
	if (isServer())
	{
		CMap@ map = getMap();
		const f32 tilesize = map.tilesize;
		Vec2f tpos = ul;
		while (tpos.x < lr.x)
		{
			while (tpos.y < lr.y)
			{
				if (map.getSectorAtPosition(tpos, sectorName) !is null && map.getTile(tpos).type != omitTile)
				{
					map.server_SetTile(tpos, tile);
				}
				tpos.y += tilesize;
			}
			tpos.x += tilesize;
			tpos.y = ul.y;
		}
	}
}

void AddTilesBySectorSoft(Vec2f ul, Vec2f lr, string sectorName, TileType tile)
{
	if (isServer())
	{
		CMap@ map = getMap();
		const f32 tilesize = map.tilesize;
		Vec2f tpos = ul;

		while (tpos.x < lr.x)
		{
			while (tpos.y < lr.y)
			{
				uint16 oldTile = map.getTile(tpos).type;

				if (map.getSectorAtPosition(tpos, sectorName) !is null && 
				   (oldTile < tile || map.hasTileFlag(map.getTileOffset(tpos), Tile::FLAMMABLE))) //which tiles can be overwritten
				{
					map.server_SetTile(tpos, tile);
				}
				tpos.y += tilesize;
			}
			tpos.x += tilesize;
			tpos.y = ul.y;
		}
	}
}
