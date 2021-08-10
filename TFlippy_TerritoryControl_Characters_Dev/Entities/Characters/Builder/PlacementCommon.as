//#include "LoaderUtilities.as";

#include "CustomBlocks.as";

// const f32 MAX_BUILD_LENGTH = 4.0f;

shared class BlockCursor
{
	Vec2f tileAimPos;
	bool cursorClose;
	bool buildable;
	bool supported;
	bool hasReqs;
	// for gui
	bool rayBlocked;
	bool buildableAtPos;
	Vec2f rayBlockedPos;
	bool blockActive;
	bool blobActive;
	bool sameTileOnBack;
	CBitStream missing;

	BlockCursor()
	{
		blobActive = blockActive = buildableAtPos = rayBlocked = hasReqs = supported = buildable = cursorClose = sameTileOnBack = false;
	}
};

void AddCursor(CBlob@ this)
{
	if (!this.exists("blockCursor"))
	{
		BlockCursor bc;
		this.set("blockCursor", bc);
	}
}

bool canPlaceNextTo(CMap@ map, const Tile &in tile)
{
	return tile.support > 0;
}

bool isBuildableAtPos(CBlob@ this, Vec2f p, TileType buildTile, CBlob @blob, bool &out sameTile)
{
	f32 radius = 0.0f;
	CMap@ map = this.getMap();
	sameTile = false;

	if (blob is null) // BLOCKS
	{
		radius = map.tilesize;
	}
	else // BLOB
	{
		radius = blob.getRadius();
	}

	//check height + edge proximity
	if (p.y < 2 * map.tilesize ||
	        p.x < 2 * map.tilesize ||
	        p.x > (map.tilemapwidth - 2.0f)*map.tilesize)
	{
		return false;
	}

	// tilemap check
	const bool buildSolid = (map.isTileSolid(buildTile) || (blob !is null && blob.isCollidable()) || (buildTile == CMap::tile_iron || buildTile == CMap::tile_glass 
	|| buildTile == CMap::tile_plasteel || buildTile == CMap::tile_tnt || buildTile == CMap::tile_concrete || buildTile == CMap::tile_reinforcedconcrete || buildTile == CMap::tile_kudzu
	|| buildTile == CMap::tile_goldingot || buildTile == CMap::tile_mithrilingot || buildTile == CMap::tile_copperingot || buildTile == CMap::tile_steelingot || buildTile == CMap::tile_ironingot));
	Vec2f tilespace = map.getTileSpacePosition(p);
	const int offset = map.getTileOffsetFromTileSpace(tilespace);
	Tile backtile = map.getTile(offset);
	Tile left = map.getTile(offset - 1);
	Tile right = map.getTile(offset + 1);
	Tile up = map.getTile(offset - map.tilemapwidth);
	Tile down = map.getTile(offset + map.tilemapwidth);

	if (buildTile > 0 && buildTile < 255 && blob is null && buildTile == map.getTile(offset).type)
	{
		sameTile = true;
		return false;
	}
/*
	if ((buildTile == CMap::tile_wood && backtile.type >= CMap::tile_wood_d1 && backtile.type <= CMap::tile_wood_d0) || 			 	//wood block
	    (buildTile == CMap::tile_iron && backtile.type >= CMap::tile_iron_d0 && backtile.type <= CMap::tile_iron_d8) || 			 	//iron block
		(buildTile == CMap::tile_glass && backtile.type == CMap::tile_glass_d0) ||													 	//glass block
		(buildTile == CMap::tile_plasteel && backtile.type >= CMap::tile_plasteel_d0 && backtile.type <= CMap::tile_plasteel_d14) || 	//plasteel block
		(buildTile == CMap::tile_bglass && backtile.type == CMap::tile_bglass_d0) ||												 	//background glass block
		(buildTile == CMap::tile_biron && backtile.type >= CMap::tile_biron_d0 && backtile.type <= CMap::tile_biron_d8) ||			 	//background iron block
		(buildTile == CMap::tile_bplasteel && backtile.type >= CMap::tile_bplasteel_d0 && backtile.type <= CMap::tile_bplasteel_d14) || //background plasteel block
		(buildTile == CMap::tile_concrete && backtile.type >= CMap::tile_concrete_d0 && backtile.type <= CMap::tile_concrete_d7) ||		//concrete block
		(buildTile == CMap::tile_castle && backtile.type >= CMap::tile_castle_d1 && backtile.type <= CMap::tile_castle_d0))				//castle block
	{
		//repair like tiles
	}
	else if (backtile.type == CMap::tile_wood && buildTile == CMap::tile_castle)
	{
		// can build stone on wood, do nothing
	}
	else if (backtile.type >= CMap::tile_bglass && backtile.type <= CMap::tile_bglass_v14)
	{
		return false;
	}
	else if (buildTile == CMap::tile_wood_back && backtile.type == CMap::tile_castle_back)
	{
		//cant build wood on stone background
		return false;
	}*/

	if ((buildTile == CMap::tile_glass && backtile.type == CMap::tile_glass_d0) ||																																						//glass block
		(buildTile == CMap::tile_wood && backtile.type >= CMap::tile_wood_d1 && backtile.type <= CMap::tile_wood_d0) || 																												//wood block
		(buildTile == CMap::tile_castle && backtile.type >= CMap::tile_castle_d1 && backtile.type <= CMap::tile_castle_d0) ||																											//castle block
		(buildTile == CMap::tile_concrete && ((backtile.type >= CMap::tile_concrete_d0 && backtile.type <= CMap::tile_concrete_d7) || (backtile.type >= CMap::tile_mossyconcrete && backtile.type <= CMap::tile_mossyconcrete_d4))) ||	//concrete block
	    (buildTile == CMap::tile_iron && backtile.type >= CMap::tile_iron_d0 && backtile.type <= CMap::tile_rustyiron_d4) || 																											//iron block
		(buildTile == CMap::tile_reinforcedconcrete && backtile.type >= CMap::tile_reinforcedconcrete_d0 && backtile.type <= CMap::tile_reinforcedconcrete_d15) ||																		//reinforced concrete block
		(buildTile == CMap::tile_plasteel && backtile.type >= CMap::tile_plasteel_d0 && backtile.type <= CMap::tile_plasteel_d14) ||																									//plasteel block
		(buildTile == CMap::tile_kudzu && backtile.type == CMap::tile_kudzu_d0))																																						//kudzu block
	{
		//repair like tiles
	}
	else if (((backtile.type >= CMap::tile_glass && backtile.type <= CMap::tile_glass_d0) 																														&& (buildTile == CMap::tile_wood || buildTile == CMap::tile_castle || buildTile == CMap::tile_concrete || buildTile == CMap::tile_iron || buildTile == CMap::tile_reinforcedconcrete || buildTile == CMap::tile_plasteel)) ||
			((backtile.type == CMap::tile_wood || (backtile.type >= 200 && backtile.type <= 204)) 																												&& (buildTile == CMap::tile_castle || buildTile == CMap::tile_concrete || buildTile == CMap::tile_iron || buildTile == CMap::tile_reinforcedconcrete || buildTile == CMap::tile_plasteel)) ||
			((backtile.type == CMap::tile_castle || (backtile.type >= 58 && backtile.type <= 63)) 																												&& (buildTile == CMap::tile_concrete || buildTile == CMap::tile_iron || buildTile == CMap::tile_reinforcedconcrete || buildTile == CMap::tile_plasteel)) ||
			(((backtile.type >= CMap::tile_concrete && backtile.type <= CMap::tile_concrete_d7) || (backtile.type >= CMap::tile_mossyconcrete && backtile.type <= CMap::tile_mossyconcrete_d4))					&& (buildTile == CMap::tile_iron || buildTile == CMap::tile_reinforcedconcrete || buildTile == CMap::tile_plasteel)) ||
			((backtile.type >= CMap::tile_iron && backtile.type <= CMap::tile_rustyiron_d4)																														&& (buildTile == CMap::tile_reinforcedconcrete || buildTile == CMap::tile_plasteel)) ||
			(((backtile.type >= CMap::tile_reinforcedconcrete && backtile.type <= CMap::tile_reinforcedconcrete_d15) || (backtile.type >= CMap::tile_plasteel_d0 && backtile.type <= CMap::tile_plasteel_d14))	&& buildTile == CMap::tile_plasteel) ||

			((backtile.type >= CMap::tile_bglass && backtile.type <= CMap::tile_bglass_d0) 																								&& (buildTile == CMap::tile_wood_back || buildTile == CMap::tile_castle_back || buildTile == CMap::tile_bconcrete || buildTile == CMap::tile_biron || buildTile == CMap::tile_bplasteel)) ||
			((backtile.type == CMap::tile_wood_back || backtile.type == 207) 																											&& (buildTile == CMap::tile_castle_back || buildTile == CMap::tile_bconcrete || buildTile == CMap::tile_biron || buildTile == CMap::tile_bplasteel)) ||
			((backtile.type == CMap::tile_castle_back || (backtile.type >= 76 && backtile.type <= 79)) 																					&& (buildTile == CMap::tile_bconcrete || buildTile == CMap::tile_biron || buildTile == CMap::tile_bplasteel)) ||
			((backtile.type >= CMap::tile_bconcrete && backtile.type <= CMap::tile_mossybconcrete_d4)					 																&& (buildTile == CMap::tile_biron || buildTile == CMap::tile_bplasteel)) ||
			(((backtile.type >= CMap::tile_biron && backtile.type <= CMap::tile_biron_d8) || (backtile.type >= CMap::tile_bplasteel_d0 && backtile.type <= CMap::tile_bplasteel_d14)) 	&& buildTile == CMap::tile_bplasteel))
	{
		//replace with more powerfull
	}
	else if ((buildTile == CMap::tile_bglass 		&& ((backtile.type >= CMap::tile_bglass && backtile.type <= CMap::tile_bglass_v14) || backtile.type == CMap::tile_wood_back || backtile.type == 207 || backtile.type == CMap::tile_castle_back || (backtile.type >= 76 && backtile.type <= 79) || (backtile.type >= CMap::tile_bconcrete && backtile.type <= CMap::tile_mossybconcrete_d4) || (backtile.type >= CMap::tile_biron && backtile.type <= CMap::tile_biron_d8) || (backtile.type >= CMap::tile_bplasteel && backtile.type <= CMap::tile_bplasteel_d14))) ||
			(buildTile == CMap::tile_wood_back 		&& (backtile.type == CMap::tile_castle_back || (backtile.type >= 76 && backtile.type <= 79) || (backtile.type >= CMap::tile_bconcrete && backtile.type <= CMap::tile_mossybconcrete_d4) || (backtile.type >= CMap::tile_biron && backtile.type <= CMap::tile_biron_d8) || (backtile.type >= CMap::tile_bplasteel && backtile.type <= CMap::tile_bplasteel_d14))) ||
			(buildTile == CMap::tile_castle_back 	&& ((backtile.type >= CMap::tile_bconcrete && backtile.type <= CMap::tile_mossybconcrete_d4) || (backtile.type >= CMap::tile_biron && backtile.type <= CMap::tile_biron_d8) || (backtile.type >= CMap::tile_bplasteel && backtile.type <= CMap::tile_bplasteel_d14))) ||
			(buildTile == CMap::tile_bconcrete	 	&& ((backtile.type >= CMap::tile_bconcrete && backtile.type <= CMap::tile_bconcrete_v14) || (backtile.type >= CMap::tile_biron && backtile.type <= CMap::tile_biron_d8) || (backtile.type >= CMap::tile_bplasteel && backtile.type <= CMap::tile_bplasteel_d14))) ||
			(buildTile == CMap::tile_biron 			&& ((backtile.type >= CMap::tile_biron && backtile.type <= CMap::tile_biron_m) || (backtile.type >= CMap::tile_bplasteel && backtile.type <= CMap::tile_bplasteel_d14))) ||
			(buildTile == CMap::tile_bplasteel 		&& (backtile.type == CMap::tile_bplasteel_v0)))
	{
		return false;
	}

	else if (buildTile == CMap::tile_ground)
	{
		if (backtile.type == CMap::tile_ground_back || backtile.type == CMap::tile_ground_d0 || backtile.type == CMap::tile_ground_d1)
		{
			// print("gud");
		}
		else return false;
	}/*
	else if (buildTile == CMap::tile_bglass)
	{
		if (backtile.type == CMap::tile_ground_back || (backtile.type >= 25 && backtile.type <= 28) || backtile.type == CMap::tile_empty)
		{
			// print("gud");
		}
		else return false;
	}
	else if (buildTile == CMap::tile_biron)
	{
		if (backtile.type == CMap::tile_ground_back || (backtile.type >= 25 && backtile.type <= 28) || backtile.type == CMap::tile_wood_back || backtile.type == CMap::tile_castle_back || backtile.type == CMap::tile_castle_back_moss || backtile.type == CMap::tile_empty)
		{
			// print("gud");
		}
		else return false;
	}
	else if (buildTile == CMap::tile_bplasteel)
	{
		if (backtile.type == CMap::tile_ground_back || (backtile.type >= 25 && backtile.type <= 28) || backtile.type == CMap::tile_wood_back || backtile.type == CMap::tile_castle_back || backtile.type == CMap::tile_castle_back_moss || backtile.type == CMap::tile_empty || backtile.type == CMap::tile_biron)
		{
			// print("gud");
		}
		else return false;
	}*/
	else if (map.isTileSolid(backtile) || map.hasTileSolidBlobs(backtile))
	{
		if (!buildSolid && !map.hasTileSolidBlobsNoPlatform(backtile) && !map.isTileSolid(backtile))
		{
			//skip onwards, platforms don't block backwall
		}
		else
		{
			return false;
		}
	}

	//printf("c");
	bool canPlaceOnBackground = ((blob is null) || (blob.getShape().getConsts().support > 0));   // if this is a blob it has to do support - so spikes cant be placed on back

	if (
	    (!canPlaceOnBackground || !map.isTileBackgroundNonEmpty(backtile)) &&      // can put against background
	    !(                                              // can put sticking next to something
	        canPlaceNextTo(map, left) || (canPlaceOnBackground && map.isTileBackgroundNonEmpty(left))  ||
	        canPlaceNextTo(map, right) || (canPlaceOnBackground && map.isTileBackgroundNonEmpty(right)) ||
	        canPlaceNextTo(map, up)   || (canPlaceOnBackground && map.isTileBackgroundNonEmpty(up))    ||
	        canPlaceNextTo(map, down) || (canPlaceOnBackground && map.isTileBackgroundNonEmpty(down))
	    )
	)
	{
		return false;
	}
	// no blocking actors?
	// printf("d");
	if (blob is null || !blob.hasTag("ignore blocking actors"))
	{
		bool isLadder = false;
		bool isSpikes = false;
		bool isDummyTile = buildTile > 255 && buildTile < 384;

		if (blob !is null)
		{
			const string bname = blob.getName();
			isLadder = bname == "ladder";
			isSpikes = bname == "spikes";
		}

		Vec2f middle = p;

		if (!(buildTile == CMap::tile_bglass || buildTile == CMap::tile_biron || buildTile == CMap::tile_bplasteel) && !isLadder && (isDummyTile ? true : (buildSolid || isSpikes)) && map.getSectorAtPosition(middle, "no build") !is null)
		{
			return false;
		}

		//if (blob is null)
		//middle += Vec2f(map.tilesize*0.5f, map.tilesize*0.5f);

		const string name = blob !is null ? blob.getName() : "";
		CBlob@[] blobsInRadius;
		if (map.getBlobsInRadius(middle, buildSolid ? map.tilesize : 0.0f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (!b.isAttached() && b !is blob)
				{
					if (blob !is null || buildSolid)
					{
						if (b is this)					// this is me
						{
							if (!isSpikes && (b.getPosition() - middle).getLength() <= radius)
							{
								return false;

							}

						}
						else
						{
							Vec2f bpos = b.getPosition();

							const string bname = b.getName();

							bool cantBuild = (b.isCollidable() || b.getShape().isStatic());

							// cant place on any other blob
							if (cantBuild &&
							        !b.hasTag("dead") &&
							        !b.hasTag("material") &&
							        !b.hasTag("projectile") &&
							        bname != "bush")
							{
								f32 angle_decomp = Maths::FMod(Maths::Abs(b.getAngleDegrees()), 180.0f);
								bool rotated = angle_decomp > 45.0f && angle_decomp < 135.0f;
								f32 width = rotated ? b.getHeight() : b.getWidth();
								f32 height = rotated ? b.getWidth() : b.getHeight();
								if ((middle.x > bpos.x - width * 0.5f) && (middle.x < bpos.x + width * 0.5f)
								        && (middle.y > bpos.y - height * 0.5f) && (middle.y < bpos.y + height * 0.5f))
								{
									return false;
								}
							}
						}
					}
				}
			}
		}
	}

	return true;
}

void SetTileAimpos(CBlob@ this, BlockCursor@ bc)
{
	// calculate tile mouse pos
	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	Vec2f mouseNorm = aimpos - pos;
	f32 mouseLen = mouseNorm.Length();
	const f32 maxLen = this.get_f32("max_build_length");
	mouseNorm /= mouseLen;

	if (mouseLen > maxLen * getMap().tilesize)
	{
		f32 d = maxLen * getMap().tilesize;
		Vec2f p = pos + Vec2f(d * mouseNorm.x, d * mouseNorm.y);
		p = getMap().getTileSpacePosition(p);
		bc.tileAimPos = getMap().getTileWorldPosition(p);
	}
	else
	{
		bc.tileAimPos = getMap().getTileSpacePosition(aimpos);
		bc.tileAimPos = getMap().getTileWorldPosition(bc.tileAimPos);
	}

	bc.cursorClose = (mouseLen < getMaxBuildDistance(this));
}

f32 getMaxBuildDistance(CBlob@ this)
{
	return (this.get_f32("max_build_length") + 0.51f) * getMap().tilesize;
}

void SetupBuildDelay(CBlob@ this)
{
	this.set_u32("build time", getGameTime());
	// this.set_u32("build delay", this.getName() == "builder" ? 4 : 8);  // move this to builder init // okay
}

bool isBuildDelayed(CBlob@ this)
{
	return (getGameTime() <= this.get_u32("build time"));
}

void SetBuildDelay(CBlob@ this)
{
	SetBuildDelay(this, this.get_u32("build delay"));
}

void SetBuildDelay(CBlob@ this, uint time)
{
	this.set_u32("build time", getGameTime() + time);
}

bool isBuildRayBlocked(Vec2f pos, Vec2f target, Vec2f &out point)
{
	CMap@ map = getMap();

	Vec2f vector = target - pos;
	vector.Normalize();
	target -= vector * map.tilesize;

	f32 halfsize = map.tilesize * 0.5f;

	return map.rayCastSolid(pos + Vec2f(0, halfsize), target, point) &&
	       map.rayCastSolid(pos + Vec2f(halfsize, 0), target, point) &&
	       map.rayCastSolid(pos + Vec2f(0, -halfsize), target, point) &&
	       map.rayCastSolid(pos + Vec2f(-halfsize, 0), target, point);
}
