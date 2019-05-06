// PNG loader base class - extend this to add your own PNG loading functionality!

#include "BasePNGLoader.as";
#include "CustomBlocks.as";
// #include "PrettyMap.as";

namespace tc_colors
{
	enum color
	{
		color_mechhall = 0xffffbe0a,
		color_blackmarket = 0xff130d1d,
		color_ruin = 0xff808000,

		color_ivy = 0xff49ac00,
		color_crystal = 0xff1dffb7,
		color_lamppost = 0xffffdd26,

		color_fort_red = 0xffff2a2a,
		color_fort_blue = 0xff2a2aff,
		color_fort_green = 0xff2aff2a,
		color_fort_yellow = 0xffffff2a,
		color_fort_neutral = 0xff8e8e8e,

		color_tunnel_neutral = 0xff464678,
		color_coalmine_neutral = 0xff373750,
		color_merchant_neutral = 0xff7878ff,
		color_bitch_neutral = 0xff7832e1,
		color_pumpjack_neutral = 0xff14507d,
		color_trader_neutral = 0xff3737cd,
		color_hobo_neutral = 0xff493326,

		color_badgerden = 0xff46412d,
		color_chickencoop = 0xff964619,
		color_scoutchicken = 0xffb96437,
		color_lootchest = 0xffffd200,
		color_lootchest_random = 0xffff8200,
		color_bannerchicken = 0xffbe3838,
		color_irondoor_chicken = 0xffcfbaba,
		color_chickenmarket = 0xffdccb7b,
		color_civillianchicken = 0xffb98c75,
		color_zapper_chicken = 0xff75b9ab,
		color_sentry_chicken = 0xffff6408,
		color_ceiling_lamp = 0xffd7f5f8,
		color_car = 0xff523535,
		color_sam = 0xff6f848c,
		color_lws = 0xffd77474,
		color_merchantchicken = 0xffbec728,
		color_train = 0xff08b4b2,
		color_sat = 0xff08ffb6,
		color_helichopper = 0xff49ccca,
		
		color_pirategull = 0xffe4e6bb,
		color_badger = 0xff5a5546,
		color_barbedwire = 0xff5f6473,
		color_iron_platform = 0xffcccccc,

		color_glass = 0xff6d95a1,
		color_glass_bg = 0xff5a7a83,
		color_iron = 0xff5f5f5f,
		color_iron_bg = 0xff454545,
		color_concrete = 0xffadaa96,
		color_concrete_bg = 0xff656358,
		color_reinforced_concrete = 0xff90928a,
		color_reinforced_concrete_bg = 0xff454642,
		color_rail = 0xff777d84,
		color_rail_bg = 0xff494d52,
	};
}

class TCPNGLoader : PNGLoader
{
	TCPNGLoader()
	{
		super();
	}

	void handlePixel(const SColor &in pixel, int offset) override
	{
		
		PNGLoader::handlePixel(pixel, offset);

		switch (pixel.color)
		{
			case tc_colors::color_tunnel_neutral:
			{
				spawnBlob(map, "tunnel", offset, -1);
				break;
			}
			
			case tc_colors::color_coalmine_neutral:
			{
				spawnBlob(map, "coalmine", offset, -1);
				break;
			}
			
			case tc_colors::color_merchant_neutral:
			{
				spawnBlob(map, "merchant", offset, -1);
				break;
			}
			
			case tc_colors::color_trader_neutral:
			{
				autotile(offset);
				spawnBlob(map, "trader", offset, -1);
				break;
			}
			
			case tc_colors::color_hobo_neutral:
			{
				autotile(offset);
				spawnBlob(map, "hobo", offset, -1);
				break;
			}

			case tc_colors::color_bitch_neutral:
			{
				spawnBlob(map, "witchshack", offset, -1);
				break;
			}
			
			case tc_colors::color_pumpjack_neutral:
			{
				spawnBlob(map, "pumpjack", offset, -1);
				break;
			}
			
			case tc_colors::color_badgerden:
			{
				spawnBlob(map, "badger", offset, -1);
				break;
			}
			
			case tc_colors::color_chickencoop:
			{
				autotile(offset);
				spawnBlob(map, "chickencoop", offset, -1);
				break;
			}
			
			case tc_colors::color_scoutchicken:
			{
				autotile(offset);
			
				f32 rand = XORRandom(100);
				if (rand < 15)
				{
					CBlob@ blob = spawnBlob(map, "heavychicken", offset, -1);
					blob.set_bool("raider", false);
				}
				else if (rand < 50)
				{
					CBlob@ blob = spawnBlob(map, "soldierchicken", offset, -1);
					blob.set_bool("raider", false);
				}
				else
				{
					CBlob@ blob = spawnBlob(map, "scoutchicken", offset, -1);
					blob.set_bool("raider", false);
				}
			
				break;
			}
			
			case tc_colors::color_lootchest:
			{
				map.SetTile(offset, CMap::tile_biron);
				spawnBlob(map, "lootchest", offset, -1);
				break;
			}
			
			case tc_colors::color_lootchest_random:
			{
				if (XORRandom(100) < 50)
				{
					map.SetTile(offset, CMap::tile_biron);
					spawnBlob(map, "lootchest", offset, -1);
				}
				break;
			}
			
			case tc_colors::color_ruin:
			{
				spawnBlob(map, "ruins", offset, -1);
				break;
			}
			case tc_colors::color_ivy:
			{
				autotile(offset);
				CBlob@ blob = spawnBlob(map, "ivy", offset, -1);
				blob.setPosition(blob.getPosition() + Vec2f(0, 16));
				break;
			}
			case tc_colors::color_bannerchicken:
			{
				map.SetTile(offset, CMap::tile_biron);
				CBlob@ blob = spawnBlob(map, "bannerchicken", offset, -1);
				blob.setPosition(blob.getPosition() + Vec2f(0, 16));
				break;
			}
			case tc_colors::color_crystal:
			{
				spawnBlob(map, "crystal", offset, -1);
				break;
			}
			case tc_colors::color_lamppost:
			{
				CBlob@ blob = spawnBlob(map, "lamppost", offset, -1);
				blob.setPosition(blob.getPosition() + Vec2f(0, -8));
				break;
			}
			case tc_colors::color_badger:
			{
				autotile(offset);
				spawnBlob(map, "badger", offset, -1);
				break;
			}
			case tc_colors::color_pirategull:
			{
				autotile(offset);
				spawnBlob(map, "pirategull", offset, 230);
				break;
			}
			case tc_colors::color_glass:
			{
				map.SetTile(offset, CMap::tile_glass);
				break;
			}
			case tc_colors::color_glass_bg:
			{
				map.SetTile(offset, CMap::tile_bglass);
				break;
			}
			case tc_colors::color_iron:
			{
				map.SetTile(offset, CMap::tile_iron);
				break;
			}
			case tc_colors::color_iron_bg:
			{
				map.SetTile(offset, CMap::tile_biron);
				break;
			}
			case tc_colors::color_concrete:
			{
				map.SetTile(offset, CMap::tile_concrete);
				break;
			}
			case tc_colors::color_concrete_bg:
			{
				map.SetTile(offset, CMap::tile_bconcrete);
				break;
			}
			case tc_colors::color_reinforced_concrete:
			{
				map.SetTile(offset, CMap::tile_reinforcedconcrete);
				break;
			}
			case tc_colors::color_irondoor_chicken:
			{
				map.SetTile(offset, CMap::tile_biron);
				spawnBlob(map, "iron_door", offset, 250, true);	
				break;
			}
			case tc_colors::color_chickenmarket:
			{
				CBlob@ blob = spawnBlob(map, "chickenmarket", offset, 250);	
				blob.setPosition(blob.getPosition() + Vec2f(0, -16));
				break;
			}
			case tc_colors::color_civillianchicken:
			{
				autotile(offset);
				spawnBlob(map, "civillianchicken", offset, 250);
				break;
			}
			case tc_colors::color_barbedwire:
			{
				spawnBlob(map, "barbedwire", offset, -1);
				break;
			}
			case tc_colors::color_iron_platform:
			{
				map.SetTile(offset, CMap::tile_biron);
				spawnBlob(map, "iron_platform", offset, -1);
				break;
			}
			case tc_colors::color_zapper_chicken:
			{
				autotile(offset);
				CBlob@ blob = spawnBlob(map, "zapper", offset, 250);
				blob.setPosition(blob.getPosition() + Vec2f(0, -8));
				break;
			}
			case tc_colors::color_sentry_chicken:
			{
				autotile(offset);
				CBlob@ blob = spawnBlob(map, "sentry", offset, 250);
				blob.setPosition(blob.getPosition() + Vec2f(0, -8));
				break;
			}
			case tc_colors::color_ceiling_lamp:
			{
				map.SetTile(offset, CMap::tile_biron);
				CBlob@ blob = spawnBlob(map, "ceilinglamp", offset, 255);
				blob.setPosition(blob.getPosition() + Vec2f(0, -8));
				break;
			}
			case tc_colors::color_merchantchicken:
			{
				CBlob@ blob = spawnBlob(map, "merchantchicken", offset, 250);
				blob.setPosition(blob.getPosition() + Vec2f(0, 0));
				break;
			}
			case tc_colors::color_car:
			{
				spawnBlob(map, "car", offset, -1);
				break;
			}
			case tc_colors::color_sam:
			{
				autotile(offset);
				spawnBlob(map, "sam", offset, 250);
				break;
			}
			case tc_colors::color_lws:
			{
				autotile(offset);
				spawnBlob(map, "lws", offset, 250);
				break;
			}
			case tc_colors::color_sat:
			{
				autotile(offset);
				spawnBlob(map, "sat", offset, 250);
				break;
			}
			case tc_colors::color_helichopper:
			{
				CBlob@ blob = spawnBlob(map, "helichopper", offset, 250);
				blob.setPosition(blob.getPosition() + Vec2f(0, 0));
				break;
			}
			case tc_colors::color_train:
			{
				CBlob@ blob = spawnBlob(map, "train", offset, 250);
				map.SetTile(offset, CMap::tile_biron);
				blob.setPosition(blob.getPosition() + Vec2f(0, -11));
				break;
			}
			case tc_colors::color_rail:
			{
				map.SetTile(offset, CMap::tile_rail_0);
				break;
			}
			case tc_colors::color_rail_bg:
			{
				map.SetTile(offset, CMap::tile_rail_0_bg);
				break;
			}
		};
	}
}

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING TC PNG MAP " + fileName);

	TCPNGLoader loader();

	return loader.loadMap(map , fileName);
}

const SColor c_white = SColor(255, 255, 255, 255);
const SColor c_black = SColor(255, 0, 0, 0);
const SColor c_missing = SColor(255, 255, 0, 255);

const SColor c_sky = SColor(255, 237, 204, 166);

const SColor c_sky_top = SColor(0xff92e0ec);
const SColor c_sky_bottom = SColor(0xffcaa58a);

const SColor c_dirt = SColor(255, 191, 145, 87);
const SColor c_stone = SColor(255, 130, 106, 76);
const SColor c_thickStone = SColor(255, 102, 88, 70);
const SColor c_bedrock = SColor(255, 71, 71, 61);
const SColor c_gold = SColor(255, 237, 190, 47);

const SColor c_castle = SColor(0xff647160);
const SColor c_castle_moss = SColor(0xff619352);
const SColor c_wood = SColor(0xff845235);
const SColor c_grass = SColor(0xff8bd21a);

const SColor c_glass = SColor(0xffbde6ed);
const SColor c_iron = SColor(0xff879092);
const SColor c_plasteel = SColor(0xff958a7c);
const SColor c_concrete = SColor(0xffe4e0c4);

SColor[] fire_colors = 
{
	SColor(0xfff3ac5c),
	SColor(0xffdb5743),
	SColor(0xff7e3041)
};

void CalculateMinimapColour( CMap@ this, u32 offset, TileType type, SColor &out col)
{
	const int w = this.tilemapwidth;
	const int h = this.tilemapheight;
	
	const int x = offset % w;
	const int y = offset / w;
	const Vec2f pos = Vec2f(x * 8, y * 8);
	
	const f32 heightGradient = y / f32(h);
	
	const Tile tile = this.getTile(offset);
	
	bool air = type == CMap::tile_empty;
	
	const u8 flags = tile.flags;
	bool bg = flags & Tile::BACKGROUND != 0;
	bool solid = flags & Tile::SOLID != 0;

	// if (this.isTileGround(tile) || this.isTileStone(tile) || this.isTileBedrock(tile) || this.isTileGold(tile) || this.isTileThickStone(tile) || this.isTileCastle(tile) || this.isTileWood(tile))
	if (!air)
	{
		TileType l = this.getTile(offset - 1).type;
		TileType r = this.getTile(offset + 1).type;
		TileType u = this.getTile(offset - w).type;
		TileType d = this.getTile(offset + w).type;

		if (this.isTileGround(type) || this.isTileGroundBack(type))
		{
			col = c_dirt;
			if (this.isTileGrass(u))
			{
				col = col.getInterpolated(c_grass, 0.50f);
			}
		}
		else if (this.isTileThickStone(type))
		{
			col = c_thickStone;
		}
		else if (this.isTileStone(type))
		{
			col = c_stone;
		}
		else if (this.isTileBedrock(type))
		{
			col = c_bedrock;
		}
		else if (this.isTileGold(type))
		{
			col = c_thickStone;
		}
		else if (type >= CMap::tile_castle_moss && type <= CMap::tile_castle_moss + 16)
		{
			col = c_castle_moss;
		}
		else if (this.isTileCastle(type) || (type >= 64 && type <= 80))
		{
			col = c_castle;
		}
		else if (this.isTileWood(type) || (type >= CMap::tile_wood_back && type <= CMap::tile_wood_back +2))
		{
			col = c_wood;
		}
		else if (this.isTileGrass(type))
		{
			col = c_grass;
			col = col.getInterpolated(c_white, (x % 2) * 1.00f);
		}
		else if ((type >= CMap::tile_iron && type <= CMap::tile_iron_d8) || (type >= CMap::tile_biron && type <= CMap::tile_biron_d8))
		{
			col = c_iron;
		}
		else if ((type >= CMap::tile_glass && type <= CMap::tile_glass_d0) || (type >= CMap::tile_bglass && type <= CMap::tile_bglass_d0))
		{
			col = c_glass;
			col = col.getInterpolated(c_sky, 0.25f);
		}
		else if ((type >= CMap::tile_plasteel && type <= CMap::tile_plasteel_d14) || (type >= CMap::tile_bplasteel && type <= CMap::tile_bplasteel_d14))
		{
			col = c_plasteel;
		}
		else if (type >= CMap::tile_concrete && type <= CMap::tile_concrete_d7)
		{
			col = c_concrete;
		}
		else
		{
			col = c_missing;
		}
		
		// else
		// {
			// col = c_missing;
		// }
		
		if (!solid) 
		{
			col = col.getInterpolated(c_white, 0.85f);
			if (l == CMap::tile_empty || r == CMap::tile_empty || u == CMap::tile_empty || d == CMap::tile_empty) col = col.getInterpolated(c_black, 0.70f);
			// else
			// {
				// col = col.getInterpolated(c_black, 1.00f - ((x + y) % 2) * 0.10f);
			// }
		}
		else if (!this.isTileSolid(l) || !this.isTileSolid(r) || !this.isTileSolid(u) || !this.isTileSolid(d)) 
		{
			col = col.getInterpolated(c_black, 0.70f);
		}
		
		col = col.getInterpolated(c_white, 1.00f - ((1.00f - heightGradient) * 0.25f));
	}
	else
	{
		// col = c_sky;
		col = c_sky_bottom;
		col = col.getInterpolated(c_sky_top, heightGradient);
		col = col.getInterpolated(c_sky, 0.75f);
	}
	
	if (this.isInWater(pos)) col = col.getInterpolated(SColor(0xff1d85ab), 0.5f);
	if (this.isTileInFire(x, y)) col = col.getInterpolated(fire_colors[XORRandom(fire_colors.length)], 0.5f);
}