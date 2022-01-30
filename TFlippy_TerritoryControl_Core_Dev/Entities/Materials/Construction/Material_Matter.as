#include "Hitters.as";
#include "Explosion.as";
//#include "LoaderUtilities.as";
#include "CustomBlocks.as";

void onInit(CBlob@ this)
{	
	this.maxQuantity = 500;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (blob is null)
	{	
		CMap@ map = getMap();
		Vec2f pos = point2 - (normal * 4);
		Tile tile = map.getTile(pos);
		u16 type = tile.type;

		if (!map.isTileBedrock(type) && map.isTileSolid(pos) && (type < CMap::tile_matter || type > CMap::tile_matter_d2)) 
		{
			map.server_SetTile(pos, CMap::tile_matter);
			this.server_SetQuantity(Maths::Max(0, int(this.getQuantity()) - 1 - XORRandom(15)));
		}
	}
	else
	{
		if (isServer())
		{
			if (blob.getName() == "tree_pine" || blob.getName() == "tree_bushy")
			{
				CBlob@ tree = server_CreateBlob("crystaltree", this.getTeamNum(), blob.getPosition() + Vec2f(0, -32));
				
				blob.Tag("no drop");
				blob.server_Die();
			}
		}
	}
}