#include "CustomBlocks.as";
#include "MapType.as";

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	this.getShape().SetStatic(true);
	
	getRules().set_u8("map_type", MapType::dead);

	if (isClient())
	{
		SetScreenFlash(255, 255, 255, 255);
	
		CMap@ map = this.getMap();
		map.CreateTileMap(0, 0, 8.0f, "Dead_world.png");
		
		map.CreateSky(color_white, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
		map.CreateSkyGradient("Dead_skygradient.png"); // override sky color with gradient

		map.AddBackground("Dead_BackgroundPlains.png", Vec2f(0.0f, -18.0f), Vec2f(0.3f, 0.3f), color_white);
		map.AddBackground("Dead_BackgroundTrees.png", Vec2f(0.0f,  -5.0f), Vec2f(0.4f, 0.4f), color_white);
		map.AddBackground("Dead_BackgroundIsland.png", Vec2f(0.0f, 0.0f), Vec2f(0.6f, 0.6f), color_white);
		
		client_AddToChat("The world has been transformed into a mithril wasteland, and is now barely habitable.", SColor(255, 255, 0, 0));
	}
	
	if (isServer())
	{
		CBlob@[] blobs;
		getBlobsByName("tree_bushy", @blobs);
		getBlobsByName("tree_pine", @blobs);
		
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			CBlob@ tree = server_CreateBlob("crystaltree", b.getTeamNum(), b.getPosition() + Vec2f(0, -32));
				
			b.Tag("no drop");
			b.server_Die();
		}
		
		CBlob@[] nature;
		getBlobsByName("bush", @nature);
		getBlobsByName("ivy", @nature);
		getBlobsByName("flower", @nature);
		getBlobsByName("badgerden", @nature);
		getBlobsByName("grain_plant", @nature);
		
		for (int i = 0; i < nature.length; i++)
		{
			CBlob@ b = nature[i];
			CBlob@ dust = server_CreateBlob("mat_matter", b.getTeamNum(), b.getPosition());
			dust.server_SetQuantity(5 + XORRandom(100));
			
			b.Tag("no drop");
			b.server_Die();
		}
	}
}