#include "CustomBlocks.as";
#include "MapType.as";

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	this.getShape().SetStatic(true);
	
	getRules().set_u8("map_type", MapType::arctic);

	if (isClient())
	{
		SetScreenFlash(255, 255, 255, 255);
	
		CMap@ map = this.getMap();
		map.CreateTileMap(0, 0, 8.0f, "Arctic_World.png");
		
		map.CreateSky(color_white, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
		map.CreateSkyGradient("Arctic_Skygradient.png");

		map.AddBackground("Arctic_BackgroundPlains.png", Vec2f(0.0f, -18.0f), Vec2f(0.3f, 0.3f), color_white);
		map.AddBackground("Arctic_BackgroundTrees.png", Vec2f(0.0f,  -5.0f), Vec2f(0.4f, 0.4f), color_white);
		map.AddBackground("Arctic_BackgroundIsland.png", Vec2f(0.0f, 0.0f), Vec2f(0.6f, 0.6f), color_white);
	}
}