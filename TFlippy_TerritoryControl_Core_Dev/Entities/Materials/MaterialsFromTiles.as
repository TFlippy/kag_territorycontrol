#include "MakeMat.as";
#include "ParticleSparks.as";
//#include "LoaderUtilities.as";
#include "CustomBlocks.as";

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	if (damage <= 0.0f) return;

	CMap@ map = getMap();

	if (isClient())
	{
		TileType tile = map.getTile(worldPoint).type;
		// hit bedrock
		if (map.isTileBedrock(tile))
		{
			this.getSprite().PlaySound("/metal_stone.ogg", 0.7f, 1.0f);
			sparks(worldPoint, velocity.Angle(), damage);
		}
	}

	if (isServer())
	{
		TileType tile = map.getTile(worldPoint).type;

		map.server_DestroyTile(worldPoint, damage, this);

		if (this.exists("hitmap_chance") ? (XORRandom(100) < (this.get_f32("hitmap_chance") * 100.00f)) : true)
		{
			f32 multiplier = this.exists("mining_multiplier") ? this.get_f32("mining_multiplier") : 1.00f;
			multiplier += Maths::Min(this.get_f32("bobonged"), 4);
			multiplier += this.get_f32("team_mining_multiplier");

			f32 depth = 1 - ((worldPoint.y / 8) / map.tilemapheight);
			// print("" + depth);
			// print("Map height: " +  map.tilemapheight + "Y: " + worldPoint.y);

			if (map.isTileStone(tile))
			{
				if (map.isTileThickStone(tile)){
					MakeMat(this, worldPoint, "mat_stone", (10 + XORRandom(5)) * multiplier);

					if (depth < 0.90f && XORRandom(100) < 70) MakeMat(this, worldPoint, "mat_copper", (1 + XORRandom(3 * (1 - depth))) * multiplier);
					if (depth < 0.60f && XORRandom(100) < 60) MakeMat(this, worldPoint, "mat_iron", (5 + XORRandom(8)) * multiplier);
					if (depth < 0.10f && XORRandom(100) < 10) MakeMat(this, worldPoint, "mat_mithril", (2 + XORRandom(6)) * multiplier);
					if (depth < 0.60f && XORRandom(100) < 10) MakeMat(this, worldPoint, "mat_coal", (15 + XORRandom(10)) * multiplier);
				} 
				else 
				{
					MakeMat(this, worldPoint, "mat_stone", (4 + XORRandom(4)) * multiplier);
					if (depth > 0.40f && depth < 0.80f && XORRandom(100) < 50) MakeMat(this, worldPoint, "mat_copper", (1 + XORRandom(2 * (1 - depth))) * multiplier);
					if (depth < 0.60f && XORRandom(100) < 30) MakeMat(this, worldPoint, "mat_iron", (3 + XORRandom(6)) * multiplier);
					if (depth < 0.60f && XORRandom(100) < 30) MakeMat(this, worldPoint, "mat_coal", (1 + XORRandom(3)) * multiplier);
				}

				if (XORRandom(100) == 1) 
				{
					CBlob@[] blobs;
					getBlobsByName("methanedeposit", @blobs);

					if (blobs.length < 8)
					{
						map.server_DestroyTile(worldPoint, 200, this);
						server_CreateBlob("methanedeposit", -1, worldPoint);
					}
				}
			}
			else if (map.isTileGold(tile))
			{
				MakeMat(this, worldPoint, "mat_gold", (2 + XORRandom(4)) * multiplier);

				if (depth < 0.10f && XORRandom(100) < 35)
				{
					MakeMat(this, worldPoint, "mat_mithril", (3 + XORRandom(8)) * multiplier * (1.2f - depth));
				}
			}
			else if (map.isTileGround(tile))
			{
				// MakeMat(this, worldPoint, "mat_sand", 2 * multiplier);
				MakeMat(this, worldPoint, "mat_dirt", (1 + XORRandom(3)) * multiplier);
				if (depth < 0.80f && XORRandom(100) < 10) MakeMat(this, worldPoint, "mat_copper", (1 + XORRandom(2)) * multiplier);
				if (depth < 0.35f && XORRandom(100) < 60 * (1 - depth)) MakeMat(this, worldPoint, "mat_sulphur", (1 + XORRandom(5)) * multiplier * (1.3f - depth));
			}
			else if (tile >= CMap::tile_matter && tile <= CMap::tile_matter_d2)
			{
				MakeMat(this, worldPoint, "mat_matter", (1 + XORRandom(10)) * multiplier);
			}
			else if (tile == CMap::tile_concrete_d7)
			{
				MakeMat(this, worldPoint, "mat_concrete", 4);
			}
			else if (tile >= CMap::tile_iron && tile <= CMap::tile_iron_d4)
			{
				MakeMat(this, worldPoint, "mat_iron", 1);
			}
			else if (tile >= CMap::tile_kudzu && tile <= CMap::tile_kudzu_d0)
			{
				MakeMat(this, worldPoint, "mat_wood", 1);
				MakeMat(this, worldPoint, "mat_dirt", 1);
			}
			else if (tile >= CMap::tile_goldingot && tile <= CMap::tile_goldingot_d1)
			{
				MakeMat(this, worldPoint, "mat_goldingot", 5);
			}
			else if (tile >= CMap::tile_mithrilingot && tile <= CMap::tile_mithrilingot_d1)
			{
				MakeMat(this, worldPoint, "mat_mithrilingot", 5);
			}
			else if (tile >= CMap::tile_copperingot && tile <= CMap::tile_copperingot_d1)
			{
				MakeMat(this, worldPoint, "mat_copperingot", 5);
			}
			else if (tile >= CMap::tile_steelingot && tile <= CMap::tile_steelingot_d1)
			{
				MakeMat(this, worldPoint, "mat_steelingot", 5);
			}
			else if (tile >= CMap::tile_ironingot && tile <= CMap::tile_ironingot_d1)
			{
				MakeMat(this, worldPoint, "mat_ironingot", 5);
			}

			if (map.isTileSolid(tile))
			{
				if (map.isTileCastle(tile) && tile >= CMap::tile_castle_d1 && tile != CMap::tile_castle_d0)
				{
					MakeMat(this, worldPoint, "mat_stone", 1);
				}
				else if (map.isTileWood(tile))
				{
					MakeMat(this, worldPoint, "mat_wood", 1);
				}
			}
		}
	}
}
