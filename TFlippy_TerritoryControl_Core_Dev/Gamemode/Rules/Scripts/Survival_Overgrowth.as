#define SERVER_ONLY
#include "canGrow.as";
#include "MakeSeed.as";
#include "Hitters.as";

// A tiny mod by TFlippy

const string[] seeds =
{
	"tree_pine",
	"tree_bushy",
	"bush",
	"grain_plant",
	"flowers"
};

const Vec2f[] dir =
{
	Vec2f(8, 0),
	Vec2f(-8, 0),
	Vec2f(0, 8)
};

float tickrate = 5;

void onRestart(CRules@ this)
{
	CMap@ map = getMap();
	tickrate = Maths::Ceil(30 / (3 + (0.02 * map.tilemapwidth)));
}

void DecayStuff()
{
	CMap@ map = getMap();
	
	int newPos = XORRandom(map.tilemapwidth) * map.tilesize;
	int newLandY = map.getLandYAtX(newPos / 8) * 8;
	
	Vec2f tilePos = Vec2f(newPos, newLandY - 8);
	Vec2f offsetPos = Vec2f(tilePos.x + (XORRandom(10) - 5) * 8, tilePos.y + (XORRandom(6) - 3) * 8);
	Vec2f tilePosNeg8 = tilePos + Vec2f(0, -8);
	
	if (!map.isInWater(tilePosNeg8) return;
	
	uint16 tile = map.getTile(tilePos).type;
	uint16 offsetTile = map.getTile(offsetPos).type;
	
	CBlob@[] blobs;
	map.getBlobsInRadius(tilePos, 32, @blobs);
	
	if (map.isTileGround(tile))
	{
		if (map.getTile(tilePosNeg8).type == CMap::tile_empty)
		{
			map.server_SetTile(tilePosNeg8, CMap::tile_grass + XORRandom(3));
			if (XORRandom(2) == 0 && blobs.length < 4) server_MakeSeed(tilePosNeg8, seeds[XORRandom(seeds.length)]);
		}
		else if (!map.isTileSolid(tilePos + Vec2f(0, -8)))
		{
			if (XORRandom(2) == 0 && blobs.length < 4) server_MakeSeed(tilePosNeg8, seeds[XORRandom(3)]);
		}
		
		Vec2f offsetChainPos = Vec2f(offsetPos.x + (XORRandom(2) - 1) * 8, offsetPos.y + (XORRandom(2) - 1) * 8);
		
		for (int i = 0; i < 6; i++)
		{
			if (map.getTile(offsetChainPos).type == CMap::tile_castle_back)
			{
				if (XORRandom(100) < 80) map.server_SetTile(offsetChainPos, CMap::tile_castle_back_moss); else map.server_DestroyTile(offsetChainPos, 5.0f);
			}
			else if (map.getTile(offsetChainPos).type == CMap::tile_castle)
			{
				map.server_SetTile(offsetChainPos, CMap::tile_castle_moss);
			}
			offsetChainPos = Vec2f(offsetChainPos.x + (XORRandom(2) - 1) * 8, offsetChainPos.y - (XORRandom(2)) * 8);
		}
		
		if (map.isTileCastle(offsetTile))
		{
			map.server_SetTile(offsetPos, CMap::tile_castle_moss);
		}
		else if (map.isTileWood(offsetTile))
		{
			map.server_DestroyTile(offsetPos, 0.5f);
		}
	}
	else
	{
		return;
	}
}

void onTick(CRules@ this)
{
	if (getGameTime() % tickrate == 0)
	{
		DecayStuff();
		// print("Overgrowth tickrate: " + tickrate);
	}
}