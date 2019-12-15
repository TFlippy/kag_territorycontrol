#include "canGrow.as";
#include "MakeSeed.as";
#include "Hitters.as";
#include "CustomBlocks.as";
#include "MapType.as";

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

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	this.getShape().SetStatic(true);
	
	getRules().set_u8("map_type", MapType::jungle);

	if (isClient())
	{
		SetScreenFlash(255, 255, 255, 255);
	
		CMap@ map = this.getMap();
		map.CreateTileMap(0, 0, 8.0f, "Jungle_world.png");
		
		map.CreateSky(color_white, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
		map.CreateSkyGradient("skygradient_jungle.png"); // override sky color with gradient

		map.AddBackground("Jungle_BackgroundPlains.png", Vec2f(0.0f, -50.0f), Vec2f(0.2f, 0.2f), color_white);
		map.AddBackground("Jungle_BackgroundTrees.png", Vec2f(8.0f, -50.0f), Vec2f(0.1f, 0.1f), color_white);
		map.AddBackground("Jungle_BackgroundIsland.png", Vec2f(0.0f, -35.0f), Vec2f(0.3f, 0.3f), color_white);
		map.AddBackground("Jungle_BackgroundTrees2.png", Vec2f(8.0f, -20.0f), Vec2f(0.2f, 0.2f), color_white);
		// map.AddBackground("Jungle_BackgroundTrees.png", Vec2f(8.0f, -20.0f), Vec2f(0.05f, 0.05f), color_white);
		// map.AddBackground("Jungle_BackgroundIsland.png", Vec2f(0.0f, -10.0f), Vec2f(0.3f, 0.3f), color_white);
		
		
		// map.AddBackground("Jungle_BackgroundPlains.png", Vec2f(0.0f, -18.0f), Vec2f(0.3f, 0.3f), color_white);
		// map.AddBackground("Jungle_BackgroundTrees.png", Vec2f(0.0f,  -5.0f), Vec2f(0.4f, 0.4f), color_white);
		// map.AddBackground("Jungle_BackgroundIsland.png", Vec2f(0.0f, 0.0f), Vec2f(0.6f, 0.6f), color_white);
		// map.AddBackground("Jungle_BackgroundTrees.png", Vec2f(0.0f,  2.0f), Vec2f(0.7f, 0.7f), color_white);
	}
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		if (this.getTickSinceCreated() < 30 * 15)
		{
			for (int i = 0; i < 1000; i++)
			{	
				DecayStuff();
			}
		}
		else
		{
			this.getCurrentScript().tickFrequency = 600;
		}
	}
}

void DecayStuff()
{
	CMap@ map = getMap();
	
	Vec2f tilePos = Vec2f(XORRandom(map.tilemapwidth) * map.tilesize,XORRandom(map.tilemapheight) * map.tilesize);
	
	uint16 tile = map.getTile(tilePos).type;

	//It would be nice to check for nature here before spreading, but honestly TC is laggy as is, that'd only make it worse
	//CBlob@[] blobs;
	//map.getBlobsInRadius(tilePos, 32, @blobs);
	
	if(map.isTileCastle(tile)) //Mossy tiles
	{
		map.server_SetTile(tilePos, CMap::tile_castle_moss);
	}
	else if(map.getTile(tilePos).type == CMap::tile_castle_back) //Mossy tiles
	{
		map.server_SetTile(tilePos, CMap::tile_castle_back_moss);
	}
	else if(!map.isInWater(tilePos))
	{	//Grass tiles
		if(map.getTile(tilePos).type == CMap::tile_empty && (map.isTileGround(map.getTile(tilePos + Vec2f(0, 8)).type) || map.isTileStone(map.getTile(tilePos + Vec2f(0, 8)).type) || map.isTileThickStone(map.getTile(tilePos + Vec2f(0, 8)).type))) 
		{
			map.server_SetTile(tilePos, CMap::tile_grass + XORRandom(3));
			if (XORRandom(2) == 0) server_MakeSeed(tilePos + Vec2f(0, -8), seeds[XORRandom(seeds.length)]);
		}
	}
	else if (map.isTileWood(tile) && tile != CMap::tile_wood_d0) //Damage wood
	{
		map.server_DestroyTile(tilePos, 0.5f);
	}
	
	if(XORRandom(10) == 0)
	{
		if(map.isTileBackground(map.getTile(tilePos)) && map.isTileSolid(map.getTile(tilePos + Vec2f(0, -8)).type)) //Grow ivy
		{
			for(int i = 0; i < 20; i++){
				if(i*8+tilePos.x > 0)
				if(!map.isTileSolid(map.getTile(tilePos + Vec2f(0, -(8+8*i))).type)){
					
					if(map.isTileGrass(map.getTile(tilePos + Vec2f(0, -(8+8*i))).type)){
						server_CreateBlob("ivy",-1,tilePos+Vec2f(0,16));
					}
					
					break;
				}
			}
		}
	}
}