// PNG loader base class - extend this to add your own PNG loading functionality!

#include "BasePNGLoader.as";
#include "DummyCommon.as";
#include "ParticleSparks.as";
#include "Explosion.as";
#include "Hitters.as";
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

		color_iron_platform_up 		= 0xffccccca, // 0, 90, 180, and (270 or -90) degrees
		color_iron_platform_right 	= 0xffcccccb,
		color_iron_platform_down 	= 0xffcccccc,
		color_iron_platform_left 	= 0xffcccccd,

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

		color_matter = 0xff50deb1,
		color_plasteel = 0xffd1c59f,
		color_plasteel_bg = 0xff6e6753,

		color_rustyiron = 0xff5f4f4f,
		// color_rustyiron_bg = 0xff453535,
		color_mossyconcrete = 0xff95aa7e,
		color_mossyconcrete_bg = 0xff4d6340,

		color_damaged_iron = 0xff2f2f2f,
		color_damaged_iron_bg = 0xff151515,
		color_damaged_concrete = 0xff7d7a66,
		color_damaged_concrete_bg = 0xff353328,
		color_damaged_glass = 0xff3d6571,
		color_damaged_glass_bg = 0xff2a4a53,

		color_damaged_reinforced_concrete = 0xff60625a,
		// color_damaged_reinforced_concrete_bg = 0xff151612,
		color_damaged_rustyiron = 0xff2f1f1f,
		// color_damaged_rustyiron_bg = 0xff150505,
		color_damaged_mossyconcrete = 0xff657a4e,
		color_damaged_mossyconcrete_bg = 0xff1d3310,

		color_biome_jungle = 0xff327800,
		color_biome_arctic = 0xff64b4ff,
		color_biome_desert = 0xffffd364,
		color_biome_dead = 0xff736e64
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
				autotile(offset);
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
					blob.set_bool("raider", XORRandom(100) < 10);
				}
				else if (rand < 50)
				{
					CBlob@ blob = spawnBlob(map, "soldierchicken", offset, -1);
					blob.set_bool("raider", XORRandom(100) < 25);
				}
				else
				{
					CBlob@ blob = spawnBlob(map, "scoutchicken", offset, -1);
					blob.set_bool("raider", XORRandom(100) < 50);
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
			case tc_colors::color_plasteel:
			{
				map.SetTile(offset, CMap::tile_plasteel);
				break;
			}
			case tc_colors::color_plasteel_bg:
			{
				map.SetTile(offset, CMap::tile_bplasteel);
				break;
			}
			case tc_colors::color_matter:
			{
				map.SetTile(offset, CMap::tile_matter);
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
				autotile(offset);
				spawnBlob(map, "barbedwire", offset, -1);
				break;
			}
			case tc_colors::color_iron_platform_up:
			{
				map.SetTile(offset, CMap::tile_biron);
				spawnBlob(map, "iron_platform", offset, -1, true);
				break;
			}
			case tc_colors::color_iron_platform_right:
			{
				map.SetTile(offset, CMap::tile_biron);
				spawnBlob(map, "iron_platform", offset, -1, true, Vec2f_zero,  90);
				break;
			}
			case tc_colors::color_iron_platform_down:
			{
				map.SetTile(offset, CMap::tile_biron);
				spawnBlob(map, "iron_platform", offset, -1, true, Vec2f_zero,  90);
				break;
			}
			case tc_colors::color_iron_platform_left:
			{
				map.SetTile(offset, CMap::tile_biron);
				spawnBlob(map, "iron_platform", offset, -1, true, Vec2f_zero,  90);
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
			case tc_colors::color_rustyiron:
			{
				map.SetTile(offset, CMap::tile_rustyiron);
				break;
			}
			// case tc_colors::color_rustyiron_bg:
			// {
				// map.SetTile(offset, CMap::tile_bconcrete);
				// break;
			// }
			case tc_colors::color_mossyconcrete:
			{
				map.SetTile(offset, CMap::tile_mossyconcrete);
				break;
			}
			case tc_colors::color_mossyconcrete_bg:
			{
				map.SetTile(offset, CMap::tile_mossybconcrete);
				break;
			}

			case tc_colors::color_damaged_iron:
			{
				switch (XORRandom(9))
				{
					case 0: map.SetTile(offset, CMap::tile_iron_d0); break;
					case 1: map.SetTile(offset, CMap::tile_iron_d1); break;
					case 2: map.SetTile(offset, CMap::tile_iron_d2); break;
					case 3: map.SetTile(offset, CMap::tile_iron_d3); break;
					case 4: map.SetTile(offset, CMap::tile_iron_d4); break;
					case 5: map.SetTile(offset, CMap::tile_iron_d5); break;
					case 6: map.SetTile(offset, CMap::tile_iron_d6); break;
					case 7: map.SetTile(offset, CMap::tile_iron_d7); break;
					case 8: map.SetTile(offset, CMap::tile_iron_d8); break;
				}
				break;
			}
			case tc_colors::color_damaged_iron_bg:
			{
				switch (XORRandom(9))
				{
					case 0: map.SetTile(offset, CMap::tile_biron_d0); break;
					case 1: map.SetTile(offset, CMap::tile_biron_d1); break;
					case 2: map.SetTile(offset, CMap::tile_biron_d2); break;
					case 3: map.SetTile(offset, CMap::tile_biron_d3); break;
					case 4: map.SetTile(offset, CMap::tile_biron_d4); break;
					case 5: map.SetTile(offset, CMap::tile_biron_d5); break;
					case 6: map.SetTile(offset, CMap::tile_biron_d6); break;
					case 7: map.SetTile(offset, CMap::tile_biron_d7); break;
					case 8: map.SetTile(offset, CMap::tile_biron_d8); break;
				}
				break;
			}
			case tc_colors::color_damaged_concrete:
			{
				switch (XORRandom(8))
				{
					case 0: map.SetTile(offset, CMap::tile_concrete_d0); break;
					case 1: map.SetTile(offset, CMap::tile_concrete_d1); break;
					case 2: map.SetTile(offset, CMap::tile_concrete_d2); break;
					case 3: map.SetTile(offset, CMap::tile_concrete_d3); break;
					case 4: map.SetTile(offset, CMap::tile_concrete_d4); break;
					case 5: map.SetTile(offset, CMap::tile_concrete_d5); break;
					case 6: map.SetTile(offset, CMap::tile_concrete_d6); break;
					case 7: map.SetTile(offset, CMap::tile_concrete_d7); break;
				}
				break;
			}
			case tc_colors::color_damaged_concrete_bg:
			{
				switch (XORRandom(8))
				{
					case 0: map.SetTile(offset, CMap::tile_bconcrete_d0); break;
					case 1: map.SetTile(offset, CMap::tile_bconcrete_d1); break;
					case 2: map.SetTile(offset, CMap::tile_bconcrete_d2); break;
					case 3: map.SetTile(offset, CMap::tile_bconcrete_d3); break;
					case 4: map.SetTile(offset, CMap::tile_bconcrete_d4); break;
					case 5: map.SetTile(offset, CMap::tile_bconcrete_d5); break;
					case 6: map.SetTile(offset, CMap::tile_bconcrete_d6); break;
					case 7: map.SetTile(offset, CMap::tile_bconcrete_d7); break;
				}
				break;
			}
			case tc_colors::color_damaged_reinforced_concrete:
			{
				switch (XORRandom(16))
				{
					case 0: map.SetTile(offset, CMap::tile_reinforcedconcrete_d0); break;
					case 1: map.SetTile(offset, CMap::tile_reinforcedconcrete_d1); break;
					case 2: map.SetTile(offset, CMap::tile_reinforcedconcrete_d2); break;
					case 3: map.SetTile(offset, CMap::tile_reinforcedconcrete_d3); break;
					case 4: map.SetTile(offset, CMap::tile_reinforcedconcrete_d4); break;
					case 5: map.SetTile(offset, CMap::tile_reinforcedconcrete_d5); break;
					case 6: map.SetTile(offset, CMap::tile_reinforcedconcrete_d6); break;
					case 7: map.SetTile(offset, CMap::tile_reinforcedconcrete_d7); break;
					case 8: map.SetTile(offset, CMap::tile_reinforcedconcrete_d8); break;
					case 9: map.SetTile(offset, CMap::tile_reinforcedconcrete_d9); break;
					case 10: map.SetTile(offset, CMap::tile_reinforcedconcrete_d10); break;
					case 11: map.SetTile(offset, CMap::tile_reinforcedconcrete_d11); break;
					case 12: map.SetTile(offset, CMap::tile_reinforcedconcrete_d12); break;
					case 13: map.SetTile(offset, CMap::tile_reinforcedconcrete_d13); break;
					case 14: map.SetTile(offset, CMap::tile_reinforcedconcrete_d14); break;
					case 15: map.SetTile(offset, CMap::tile_reinforcedconcrete_d15); break;
				}
				break;
			}
			case tc_colors::color_damaged_mossyconcrete:
			{
				switch (XORRandom(5))
				{
					case 0: map.SetTile(offset, CMap::tile_mossyconcrete_d0); break;
					case 1: map.SetTile(offset, CMap::tile_mossyconcrete_d1); break;
					case 2: map.SetTile(offset, CMap::tile_mossyconcrete_d2); break;
					case 3: map.SetTile(offset, CMap::tile_mossyconcrete_d3); break;
					case 4: map.SetTile(offset, CMap::tile_mossyconcrete_d4); break;
				}
				break;
			}
			case tc_colors::color_damaged_mossyconcrete_bg:
			{
				switch (XORRandom(5))
				{
					case 0: map.SetTile(offset, CMap::tile_mossybconcrete_d0); break;
					case 1: map.SetTile(offset, CMap::tile_mossybconcrete_d1); break;
					case 2: map.SetTile(offset, CMap::tile_mossybconcrete_d2); break;
					case 3: map.SetTile(offset, CMap::tile_mossybconcrete_d3); break;
					case 4: map.SetTile(offset, CMap::tile_mossybconcrete_d4); break;
				}
				break;
			}
			case tc_colors::color_damaged_rustyiron:
			{
				switch (XORRandom(5))
				{
					case 0: map.SetTile(offset, CMap::tile_rustyiron_d0); break;
					case 1: map.SetTile(offset, CMap::tile_rustyiron_d1); break;
					case 2: map.SetTile(offset, CMap::tile_rustyiron_d2); break;
					case 3: map.SetTile(offset, CMap::tile_rustyiron_d3); break;
					case 4: map.SetTile(offset, CMap::tile_rustyiron_d4); break;
				}
				break;
			}
			case tc_colors::color_damaged_glass:
			{
				map.SetTile(offset, CMap::tile_glass_d0);
				break;
			}
			case tc_colors::color_damaged_glass_bg:
			{
				map.SetTile(offset, CMap::tile_bglass_d0);
				break;
			}
			case tc_colors::color_biome_desert:
			{
				CBlob@ blob = spawnBlob(map, "info_desert", offset, -1);
				blob.setPosition(Vec2f(0, 0));
				break;
			}
			case tc_colors::color_biome_jungle:
			{
				CBlob@ blob = spawnBlob(map, "info_jungle", offset, -1);
				blob.setPosition(Vec2f(0, 0));
				break;
			}
			case tc_colors::color_biome_arctic:
			{
				CBlob@ blob = spawnBlob(map, "info_arctic", offset, -1);
				blob.setPosition(Vec2f(0, 0));
				break;
			}
			case tc_colors::color_biome_dead:
			{
				CBlob@ blob = spawnBlob(map, "info_dead", offset, -1);
				blob.setPosition(Vec2f(0, 0));
				break;
			}
		};
	}
}

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING TC PNG MAP " + fileName);

	TCPNGLoader loader();

	bool result = loader.loadMap(map , fileName);

	// if (isServer())
	// {
		// server_CreateBlob("info_arctic", 255, Vec2f(0, 0));
	// }

	return result;
}

const SColor c_white = SColor(255, 255, 255, 255);
const SColor c_black = SColor(255, 0, 0, 0);
const SColor c_missing = SColor(255, 255, 0, 255);

const SColor c_sky = SColor(255, 237, 204, 166);

const SColor c_sky_top = SColor(0xff92e0ec);
const SColor c_sky_bottom = SColor(0xffcaa58a);

const SColor c_dirt = SColor(255, 191, 145, 87);
const SColor c_dirt_bg = SColor(255, 150, 115, 69);
const SColor c_stone = SColor(255, 130, 106, 76);
const SColor c_thickStone = SColor(255, 102, 88, 70);
const SColor c_bedrock = SColor(255, 71, 71, 61);
const SColor c_gold = SColor(255, 237, 190, 47);

const SColor c_castle = SColor(0xff656e70);
const SColor c_castle_moss = SColor(0xff292a2b);
const SColor c_wood = SColor(0xff845235);
const SColor c_grass = SColor(0xff8bd21a);

const SColor c_glass = SColor(0xffbde6ed);
const SColor c_iron = SColor(0xff879092);
const SColor c_rustyiron = SColor(0xff928987);
const SColor c_plasteel = SColor(0xff958a7c);
const SColor c_concrete = SColor(0xffe4e0c4);
const SColor c_bconcrete = SColor(0xffe4e0c4);
const SColor c_mossyconcrete = SColor(0xffd8e4c4);
const SColor c_mossybconcrete = SColor(0xffd8e4c4);
const SColor c_reinforcedconcrete = SColor(0xffbcbbb3);
const SColor c_snow = SColor(0xffd3decf);
const SColor c_track = SColor(0xff474b4d);
const SColor c_matter = SColor(0xff4d756f);

SColor[] fire_colors =
{
	SColor(0xfff3ac5c),
	SColor(0xffdb5743),
	SColor(0xff7e3041)
};

void CalculateMinimapColour(CMap@ this, u32 offset, TileType type, SColor &out col)
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

		// TODO: Shove damage frame numbers into an enum
		switch(type)
		{
			// DIRT
			case CMap::tile_ground:
			case CMap::tile_ground_d1:
			case 30:
			case CMap::tile_ground_d0:
				col = c_dirt;
				if (this.isTileGrass(u))
				{
					col = col.getInterpolated(c_grass, 0.50f);
				}
			break;

			// DIRT BACKGROUND
			case CMap::tile_ground_back:
				col = c_dirt_bg;
				//col = col.getInterpolated(c_dirt, heightGradient);
			break;

			// THICKSTONE
			case CMap::tile_thickstone:
			case CMap::tile_thickstone_d1:
			case 215:
			case 216: // OTHER DAMAGE FRAMES
			case 217:
			case CMap::tile_thickstone_d0:
				col = c_thickStone;
			break;

			// STONE
			case CMap::tile_stone:
			case CMap::tile_stone_d1:
			case 101:
			case 102:
			case 103:
			case CMap::tile_stone_d0:
				col = c_stone;
			break;

			// BEDROCK
			case CMap::tile_bedrock:
				col = c_bedrock;
			break;

			// GOLD
			case CMap::tile_gold:
			case 90:
			case 91:
			case 92:
			case 93:
			case 94:
				col = c_thickStone;
			break;

			// MOSS
			case CMap::tile_castle_moss:
			case 225:
			case 226:
			case 227:
			case 228:
			case 229:
			case 230:
			case 231:
			case 232:
			case 233:
			case 234:
			case 235:
			case 236:
			case 237:
			case 238:
			case 239:
			case 340:
				col = c_castle_moss;
			break;

			// CASTLE
			case CMap::tile_castle:
			case CMap::tile_castle_d1:
			case 59:
			case 60:
			case 61:
			case 62:
			case CMap::tile_castle_d0:
			case 64:
			case 65:
			case 66:
			case 67:
			case 68:
			case 69:
			case 70:
			case 71:
			case 72:
			case 73:
			case 74:
			case 75:
			case 76:
			case 77:
			case 78:
			case 79:
				col = c_castle;
			break;

			// WOOD
			case CMap::tile_wood:
			case 199:
			case CMap::tile_wood_d1:
			case 201:
			case 202:
			case CMap::tile_wood_d0:
			case CMap::tile_wood_back:
			case 206:
			case 207:
				col = c_wood;
			break;

			// GRASS
			case CMap::tile_grass:
			case 26:
			case 27:
			case 28:
				col = c_grass;
				col = col.getInterpolated(c_white, (x % 2) * 1.00f);
			break;

			// IRON
			case CMap::tile_iron:
			case CMap::tile_iron_v0:
			case CMap::tile_iron_v1:
			case CMap::tile_iron_v2:
			case CMap::tile_iron_v3:
			case CMap::tile_iron_v4:
			case CMap::tile_iron_v5:
			case CMap::tile_iron_v6:
			case CMap::tile_iron_v7:
			case CMap::tile_iron_v8:
			case CMap::tile_iron_v9:
			case CMap::tile_iron_v10:
			case CMap::tile_iron_v11:
			case CMap::tile_iron_v12:
			case CMap::tile_iron_v13:
			case CMap::tile_iron_v14:

			case CMap::tile_iron_d0:
			case CMap::tile_iron_d1:
			case CMap::tile_iron_d2:
			case CMap::tile_iron_d3:
			case CMap::tile_iron_d4:
			case CMap::tile_iron_d5:
			case CMap::tile_iron_d6:
			case CMap::tile_iron_d7:
			case CMap::tile_iron_d8:

			case CMap::tile_biron:
			case CMap::tile_biron_u:
			case CMap::tile_biron_d:
			case CMap::tile_biron_m:
			case CMap::tile_biron_d0:
			case CMap::tile_biron_d1:
			case CMap::tile_biron_d2:
			case CMap::tile_biron_d3:
			case CMap::tile_biron_d4:
			case CMap::tile_biron_d5:
			case CMap::tile_biron_d6:
			case CMap::tile_biron_d7:
			case CMap::tile_biron_d8:
				col = c_iron;
			break;


			// KUDZU
			case CMap::tile_kudzu:
			case CMap::tile_kudzu_v0:
			case CMap::tile_kudzu_v1:
			case CMap::tile_kudzu_v2:
			case CMap::tile_kudzu_v3:
			case CMap::tile_kudzu_v4:
			case CMap::tile_kudzu_v5:
			case CMap::tile_kudzu_v6:
			case CMap::tile_kudzu_v7:
			case CMap::tile_kudzu_v8:
			case CMap::tile_kudzu_v9:
			case CMap::tile_kudzu_v10:
			case CMap::tile_kudzu_v11:
			case CMap::tile_kudzu_v12:
			case CMap::tile_kudzu_v13:
			case CMap::tile_kudzu_v14:
			case CMap::tile_kudzu_f14: //Flower variant
				col = c_grass;
			break;
			case CMap::tile_kudzu_d0:
				col = c_wood;
			break;

			// GLASS
			case CMap::tile_glass:
			case CMap::tile_glass_v0:
			case CMap::tile_glass_v1:
			case CMap::tile_glass_v2:
			case CMap::tile_glass_v3:
			case CMap::tile_glass_v4:
			case CMap::tile_glass_v5:
			case CMap::tile_glass_v6:
			case CMap::tile_glass_v7:
			case CMap::tile_glass_v8:
			case CMap::tile_glass_v9:
			case CMap::tile_glass_v10:
			case CMap::tile_glass_v11:
			case CMap::tile_glass_v12:
			case CMap::tile_glass_v13:
			case CMap::tile_glass_v14:
			case CMap::tile_glass_d0:

			case CMap::tile_bglass:
			case CMap::tile_bglass_v0:
			case CMap::tile_bglass_v1:
			case CMap::tile_bglass_v2:
			case CMap::tile_bglass_v3:
			case CMap::tile_bglass_v4:
			case CMap::tile_bglass_v5:
			case CMap::tile_bglass_v6:
			case CMap::tile_bglass_v7:
			case CMap::tile_bglass_v8:
			case CMap::tile_bglass_v9:
			case CMap::tile_bglass_v10:
			case CMap::tile_bglass_v11:
			case CMap::tile_bglass_v12:
			case CMap::tile_bglass_v13:
			case CMap::tile_bglass_v14:
			case CMap::tile_bglass_d0:
				col = c_glass;
				col = col.getInterpolated(c_sky, 0.25f);
			break;

			// PLASTEEL
			case CMap::tile_plasteel:
			case CMap::tile_plasteel_d0:
			case CMap::tile_plasteel_d1:
			case CMap::tile_plasteel_d2:
			case CMap::tile_plasteel_d3:
			case CMap::tile_plasteel_d4:
			case CMap::tile_plasteel_d5:
			case CMap::tile_plasteel_d6:
			case CMap::tile_plasteel_d7:
			case CMap::tile_plasteel_d8:
			case CMap::tile_plasteel_d9:
			case CMap::tile_plasteel_d10:
			case CMap::tile_plasteel_d11:
			case CMap::tile_plasteel_d12:
			case CMap::tile_plasteel_d13:
			case CMap::tile_plasteel_d14:

			case CMap::tile_bplasteel:
			case CMap::tile_bplasteel_v0:
			case CMap::tile_bplasteel_d0:
			case CMap::tile_bplasteel_d1:
			case CMap::tile_bplasteel_d2:
			case CMap::tile_bplasteel_d3:
			case CMap::tile_bplasteel_d4:
			case CMap::tile_bplasteel_d5:
			case CMap::tile_bplasteel_d6:
			case CMap::tile_bplasteel_d7:
			case CMap::tile_bplasteel_d8:
			case CMap::tile_bplasteel_d9:
			case CMap::tile_bplasteel_d10:
			case CMap::tile_bplasteel_d11:
			case CMap::tile_bplasteel_d12:
			case CMap::tile_bplasteel_d13:
			case CMap::tile_bplasteel_d14:
				col = c_plasteel;
			break;

			// RUSTYIRON
			case CMap::tile_rustyiron:
			case CMap::tile_rustyiron_d0:
			case CMap::tile_rustyiron_d1:
			case CMap::tile_rustyiron_d2:
			case CMap::tile_rustyiron_d3:
			case CMap::tile_rustyiron_d4:
				col = c_rustyiron;
			break;

			// CONCRETE
			case CMap::tile_concrete:
			case CMap::tile_concrete_v0:
			case CMap::tile_concrete_v1:
			case CMap::tile_concrete_v2:
			case CMap::tile_concrete_v3:
			case CMap::tile_concrete_v4:
			case CMap::tile_concrete_v5:
			case CMap::tile_concrete_v6:
			case CMap::tile_concrete_v7:
			case CMap::tile_concrete_v8:
			case CMap::tile_concrete_v9:
			case CMap::tile_concrete_v10:
			case CMap::tile_concrete_v11:
			case CMap::tile_concrete_v12:
			case CMap::tile_concrete_v13:
			case CMap::tile_concrete_v14:

			case CMap::tile_concrete_d0:
			case CMap::tile_concrete_d1:
			case CMap::tile_concrete_d2:
			case CMap::tile_concrete_d3:
			case CMap::tile_concrete_d4:
			case CMap::tile_concrete_d5:
			case CMap::tile_concrete_d6:
			case CMap::tile_concrete_d7:

			case CMap::tile_bconcrete:
			case CMap::tile_bconcrete_v0:
			case CMap::tile_bconcrete_v1:
			case CMap::tile_bconcrete_v2:
			case CMap::tile_bconcrete_v3:
			case CMap::tile_bconcrete_v4:
			case CMap::tile_bconcrete_v5:
			case CMap::tile_bconcrete_v6:
			case CMap::tile_bconcrete_v7:
			case CMap::tile_bconcrete_v8:
			case CMap::tile_bconcrete_v9:
			case CMap::tile_bconcrete_v10:
			case CMap::tile_bconcrete_v11:
			case CMap::tile_bconcrete_v12:
			case CMap::tile_bconcrete_v13:
			case CMap::tile_bconcrete_v14:

			case CMap::tile_bconcrete_d0:
			case CMap::tile_bconcrete_d1:
			case CMap::tile_bconcrete_d2:
			case CMap::tile_bconcrete_d3:
			case CMap::tile_bconcrete_d4:
			case CMap::tile_bconcrete_d5:
			case CMap::tile_bconcrete_d6:
			case CMap::tile_bconcrete_d7:
				col = c_concrete;
			break;

			// MOSSY CONCRETE
			case CMap::tile_mossyconcrete:
			case CMap::tile_mossyconcrete_d0:
			case CMap::tile_mossyconcrete_d1:
			case CMap::tile_mossyconcrete_d2:
			case CMap::tile_mossyconcrete_d3:
			case CMap::tile_mossyconcrete_d4:

			case CMap::tile_mossybconcrete:
			case CMap::tile_mossybconcrete_d0:
			case CMap::tile_mossybconcrete_d1:
			case CMap::tile_mossybconcrete_d2:
			case CMap::tile_mossybconcrete_d3:
			case CMap::tile_mossybconcrete_d4:
				col = c_mossyconcrete;
			break;

			// REINFORCE CONCRETE
			case CMap::tile_reinforcedconcrete:
			case CMap::tile_reinforcedconcrete_v0:
			case CMap::tile_reinforcedconcrete_v1:
			case CMap::tile_reinforcedconcrete_v2:
			case CMap::tile_reinforcedconcrete_v3:
			case CMap::tile_reinforcedconcrete_v4:
			case CMap::tile_reinforcedconcrete_v5:
			case CMap::tile_reinforcedconcrete_v6:
			case CMap::tile_reinforcedconcrete_v7:
			case CMap::tile_reinforcedconcrete_v8:
			case CMap::tile_reinforcedconcrete_v9:
			case CMap::tile_reinforcedconcrete_v10:
			case CMap::tile_reinforcedconcrete_v11:
			case CMap::tile_reinforcedconcrete_v12:
			case CMap::tile_reinforcedconcrete_v13:
			case CMap::tile_reinforcedconcrete_v14:

			case CMap::tile_reinforcedconcrete_d0:
			case CMap::tile_reinforcedconcrete_d1:
			case CMap::tile_reinforcedconcrete_d2:
			case CMap::tile_reinforcedconcrete_d3:
			case CMap::tile_reinforcedconcrete_d4:
			case CMap::tile_reinforcedconcrete_d5:
			case CMap::tile_reinforcedconcrete_d6:
			case CMap::tile_reinforcedconcrete_d7:
			case CMap::tile_reinforcedconcrete_d8:
			case CMap::tile_reinforcedconcrete_d9:
			case CMap::tile_reinforcedconcrete_d10:
			case CMap::tile_reinforcedconcrete_d11:
			case CMap::tile_reinforcedconcrete_d12:
			case CMap::tile_reinforcedconcrete_d13:
			case CMap::tile_reinforcedconcrete_d14:
			case CMap::tile_reinforcedconcrete_d15:
				col = c_reinforcedconcrete;
			break;

			// SNOW
			case CMap::tile_snow_pile:
			case CMap::tile_snow_pile_v0:
			case CMap::tile_snow_pile_v1:
			case CMap::tile_snow_pile_v2:
			case CMap::tile_snow_pile_v3:
			case CMap::tile_snow_pile_v4:
			case CMap::tile_snow_pile_v5:

			case CMap::tile_snow:
			case CMap::tile_snow_v0:
			case CMap::tile_snow_v1:
			case CMap::tile_snow_v2:
			case CMap::tile_snow_v3:
			case CMap::tile_snow_v4:
			case CMap::tile_snow_v5:
			case CMap::tile_snow_d0:
			case CMap::tile_snow_d1:
			case CMap::tile_snow_d2:
			case CMap::tile_snow_d3:
				col = c_snow;
			break;

			case CMap::tile_rail_0:
			case CMap::tile_rail_1:
			case CMap::tile_rail_0_bg:
			case CMap::tile_rail_1_bg:
				col = c_track;
			break;

			case CMap::tile_matter:
			case CMap::tile_matter_d0:
			case CMap::tile_matter_d1:
			case CMap::tile_matter_d2:
				col = c_matter;
			break;

			case CMap::tile_goldingot:
			case CMap::tile_goldingot_d0:
			case CMap::tile_goldingot_d1:
				col = c_gold;
			break;

			case CMap::tile_mithrilingot:
			case CMap::tile_mithrilingot_d0:
			case CMap::tile_mithrilingot_d1:
				col = c_gold;
			break;

			case CMap::tile_copperingot:
			case CMap::tile_copperingot_d0:
			case CMap::tile_copperingot_d1:
				col = c_gold;
			break;

			case CMap::tile_steelingot:
			case CMap::tile_steelingot_d0:
			case CMap::tile_steelingot_d1:
				col = c_gold;
			break;

			case CMap::tile_ironingot:
			case CMap::tile_ironingot_d0:
			case CMap::tile_ironingot_d1:
				col = c_gold;
			break;


			default:
				col = c_missing;
			break;
		}


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
	// if (this.isTileInFire(x, y)) col = col.getInterpolated(fire_colors[XORRandom(fire_colors.length)], 0.5f);
}

bool isGrassTile(u16 tile)
{
	return tile >= 25 && tile <= 28;
}

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	if(map.getTile(offset).type > 255)
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
		CRules@ rules = getRules();
		if(map.getTile(offset).type == CMap::tile_matter)
		{
			CBitStream params;
			params.write_Vec2f(map.getTileWorldPosition(offset));
			rules.SendCommand(rules.getCommandID("remove_tile"), params);
		}
	}

	// print("collapse");

	return true;
}

TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if(map.getTile(index).type > 255)
	{
		switch(oldTileType)
		{
			case CMap::tile_glass:
				return CMap::tile_glass_d0;

			case CMap::tile_glass_v0:
			case CMap::tile_glass_v1:
			case CMap::tile_glass_v2:
			case CMap::tile_glass_v3:
			case CMap::tile_glass_v4:
			case CMap::tile_glass_v5:
			case CMap::tile_glass_v6:
			case CMap::tile_glass_v7:
			case CMap::tile_glass_v8:
			case CMap::tile_glass_v9:
			case CMap::tile_glass_v10:
			case CMap::tile_glass_v11:
			case CMap::tile_glass_v12:
			case CMap::tile_glass_v13:
			case CMap::tile_glass_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_glass_d0);

				for (u8 i = 0; i < 4; i++)
				{
					glass_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_glass_d0;
			}

			case CMap::tile_glass_d0:
				return CMap::tile_empty;


			case CMap::tile_plasteel:
				return CMap::tile_plasteel_d0;

			case CMap::tile_plasteel_d0:
			case CMap::tile_plasteel_d1:
			case CMap::tile_plasteel_d2:
			case CMap::tile_plasteel_d3:
			case CMap::tile_plasteel_d4:
			case CMap::tile_plasteel_d5:
			case CMap::tile_plasteel_d6:
			case CMap::tile_plasteel_d7:
			case CMap::tile_plasteel_d8:
			case CMap::tile_plasteel_d9:
			case CMap::tile_plasteel_d10:
			case CMap::tile_plasteel_d11:
			case CMap::tile_plasteel_d12:
			case CMap::tile_plasteel_d13:
				return oldTileType + 1;

			case CMap::tile_plasteel_d14:
				return CMap::tile_empty;


			case CMap::tile_matter:
				return CMap::tile_matter_d0;

			case CMap::tile_matter_d0:
			case CMap::tile_matter_d1:
				return oldTileType + 1;

			case CMap::tile_matter_d2:
				return CMap::tile_empty;

			case CMap::tile_brick_v0:
			case CMap::tile_brick_v1:
			case CMap::tile_brick_v2:
			case CMap::tile_brick_v3:
				return CMap::tile_brick_v0;


			case CMap::tile_bglass:
				return CMap::tile_bglass_d0;

			case CMap::tile_bglass_v0:
			case CMap::tile_bglass_v1:
			case CMap::tile_bglass_v2:
			case CMap::tile_bglass_v3:
			case CMap::tile_bglass_v4:
			case CMap::tile_bglass_v5:
			case CMap::tile_bglass_v6:
			case CMap::tile_bglass_v7:
			case CMap::tile_bglass_v8:
			case CMap::tile_bglass_v9:
			case CMap::tile_bglass_v10:
			case CMap::tile_bglass_v11:
			case CMap::tile_bglass_v12:
			case CMap::tile_bglass_v13:
			case CMap::tile_bglass_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_bglass_d0);

				for (u8 i = 0; i < 4; i++)
				{
					bglass_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_bglass_d0;
			}

			case CMap::tile_bglass_d0:
				return CMap::tile_empty;


			case CMap::tile_biron:
				return CMap::tile_biron_d0;

			case CMap::tile_biron_u:
			case CMap::tile_biron_d:
			case CMap::tile_biron_m:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_biron_d0);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);

				OnBIronTileUpdate(false, true, map, map.getTileWorldPosition(index));
				return CMap::tile_biron_d0;
			}

			case CMap::tile_biron_d0:
			case CMap::tile_biron_d1:
			case CMap::tile_biron_d2:
			case CMap::tile_biron_d3:
			case CMap::tile_biron_d4:
			case CMap::tile_biron_d5:
			case CMap::tile_biron_d6:
			case CMap::tile_biron_d7:
				return oldTileType + 1;

			case CMap::tile_biron_d8:
				return CMap::tile_empty;


			case CMap::tile_bplasteel:
			case CMap::tile_bplasteel_v0:
				return CMap::tile_bplasteel_d0;

			case CMap::tile_bplasteel_d0:
			case CMap::tile_bplasteel_d1:
			case CMap::tile_bplasteel_d2:
			case CMap::tile_bplasteel_d3:
			case CMap::tile_bplasteel_d4:
			case CMap::tile_bplasteel_d5:
			case CMap::tile_bplasteel_d6:
			case CMap::tile_bplasteel_d7:
			case CMap::tile_bplasteel_d8:
			case CMap::tile_bplasteel_d9:
			case CMap::tile_bplasteel_d10:
			case CMap::tile_bplasteel_d11:
			case CMap::tile_bplasteel_d12:
			case CMap::tile_bplasteel_d13:
				return oldTileType + 1;

			case CMap::tile_bplasteel_d14:
				return CMap::tile_empty;


			case CMap::tile_tnt:
			{
				OnTNTTileHit(map, index, damage, map.isInFire(map.getTileWorldPosition(index)));
				return CMap::tile_empty;
			}

			case CMap::tile_kudzu:
				return CMap::tile_kudzu_d0;

			case CMap::tile_kudzu_v0:
			case CMap::tile_kudzu_v1:
			case CMap::tile_kudzu_v2:
			case CMap::tile_kudzu_v3:
			case CMap::tile_kudzu_v4:
			case CMap::tile_kudzu_v5:
			case CMap::tile_kudzu_v6:
			case CMap::tile_kudzu_v7:
			case CMap::tile_kudzu_v8:
			case CMap::tile_kudzu_v9:
			case CMap::tile_kudzu_v10:
			case CMap::tile_kudzu_v11:
			case CMap::tile_kudzu_v12:
			case CMap::tile_kudzu_v13:
			case CMap::tile_kudzu_v14:
			case CMap::tile_kudzu_f14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_kudzu_d0);

				for (u8 i = 0; i < 4; i++)
				{
					kudzu_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_kudzu_d0;
			}

			case CMap::tile_kudzu_d0:
				return CMap::tile_empty;

			case CMap::tile_concrete:
				return CMap::tile_concrete_d0;

			case CMap::tile_concrete_v0:
			case CMap::tile_concrete_v1:
			case CMap::tile_concrete_v2:
			case CMap::tile_concrete_v3:
			case CMap::tile_concrete_v4:
			case CMap::tile_concrete_v5:
			case CMap::tile_concrete_v6:
			case CMap::tile_concrete_v7:
			case CMap::tile_concrete_v8:
			case CMap::tile_concrete_v9:
			case CMap::tile_concrete_v10:
			case CMap::tile_concrete_v11:
			case CMap::tile_concrete_v12:
			case CMap::tile_concrete_v13:
			case CMap::tile_concrete_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_concrete_d0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);

				for (u8 i = 0; i < 4; i++)
				{
					concrete_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_concrete_d0;
			}

			case CMap::tile_concrete_d0:
			case CMap::tile_concrete_d1:
			case CMap::tile_concrete_d2:
			case CMap::tile_concrete_d3:
			case CMap::tile_concrete_d4:
			case CMap::tile_concrete_d5:
			case CMap::tile_concrete_d6:
				return oldTileType + 1;

			case CMap::tile_concrete_d7:
			{
				return CMap::tile_empty;
			}

			case CMap::tile_iron:
				return CMap::tile_iron_d0;

			case CMap::tile_iron_v0:
			case CMap::tile_iron_v1:
			case CMap::tile_iron_v2:
			case CMap::tile_iron_v3:
			case CMap::tile_iron_v4:
			case CMap::tile_iron_v5:
			case CMap::tile_iron_v6:
			case CMap::tile_iron_v7:
			case CMap::tile_iron_v8:
			case CMap::tile_iron_v9:
			case CMap::tile_iron_v10:
			case CMap::tile_iron_v11:
			case CMap::tile_iron_v12:
			case CMap::tile_iron_v13:
			case CMap::tile_iron_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_iron_d0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);

				for (u8 i = 0; i < 4; i++)
				{
					iron_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_iron_d0;
			}

			case CMap::tile_iron_d0:
			case CMap::tile_iron_d1:
			case CMap::tile_iron_d2:
			case CMap::tile_iron_d3:
			case CMap::tile_iron_d4:
			case CMap::tile_iron_d5:
			case CMap::tile_iron_d6:
			case CMap::tile_iron_d7:
				return oldTileType + 1;

			case CMap::tile_iron_d8:
				return CMap::tile_empty;

			case CMap::tile_rustyiron:
				return CMap::tile_rustyiron_d0;

			case CMap::tile_rustyiron_d0:
			case CMap::tile_rustyiron_d1:
			case CMap::tile_rustyiron_d2:
			case CMap::tile_rustyiron_d3:
				return oldTileType + 1;

			case CMap::tile_rustyiron_d4:
				return CMap::tile_empty;

			case CMap::tile_reinforcedconcrete:
				return CMap::tile_reinforcedconcrete_d0;

			case CMap::tile_reinforcedconcrete_v0:
			case CMap::tile_reinforcedconcrete_v1:
			case CMap::tile_reinforcedconcrete_v2:
			case CMap::tile_reinforcedconcrete_v3:
			case CMap::tile_reinforcedconcrete_v4:
			case CMap::tile_reinforcedconcrete_v5:
			case CMap::tile_reinforcedconcrete_v6:
			case CMap::tile_reinforcedconcrete_v7:
			case CMap::tile_reinforcedconcrete_v8:
			case CMap::tile_reinforcedconcrete_v9:
			case CMap::tile_reinforcedconcrete_v10:
			case CMap::tile_reinforcedconcrete_v11:
			case CMap::tile_reinforcedconcrete_v12:
			case CMap::tile_reinforcedconcrete_v13:
			case CMap::tile_reinforcedconcrete_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_reinforcedconcrete_d0);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::FLAMMABLE);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);

				for (u8 i = 0; i < 4; i++)
				{
					reinforcedconcrete_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_reinforcedconcrete_d0;
			}

			case CMap::tile_reinforcedconcrete_d0:
			case CMap::tile_reinforcedconcrete_d1:
			case CMap::tile_reinforcedconcrete_d2:
			case CMap::tile_reinforcedconcrete_d3:
			case CMap::tile_reinforcedconcrete_d4:
			case CMap::tile_reinforcedconcrete_d5:
			case CMap::tile_reinforcedconcrete_d6:
			case CMap::tile_reinforcedconcrete_d7:
			case CMap::tile_reinforcedconcrete_d8:
			case CMap::tile_reinforcedconcrete_d9:
			case CMap::tile_reinforcedconcrete_d10:
			case CMap::tile_reinforcedconcrete_d11:
			case CMap::tile_reinforcedconcrete_d12:
			case CMap::tile_reinforcedconcrete_d13:
			case CMap::tile_reinforcedconcrete_d14:
				return oldTileType + 1;

			case CMap::tile_reinforcedconcrete_d15:
				return CMap::tile_empty;

			case CMap::tile_mossyconcrete:
				return CMap::tile_mossyconcrete_d0;

			case CMap::tile_mossyconcrete_d0:
			case CMap::tile_mossyconcrete_d1:
			case CMap::tile_mossyconcrete_d2:
			case CMap::tile_mossyconcrete_d3:
				return oldTileType + 1;

			case CMap::tile_mossyconcrete_d4:
				return CMap::tile_empty;

			case CMap::tile_bconcrete:
				return CMap::tile_bconcrete_d0;

			case CMap::tile_bconcrete_v0:
			case CMap::tile_bconcrete_v1:
			case CMap::tile_bconcrete_v2:
			case CMap::tile_bconcrete_v3:
			case CMap::tile_bconcrete_v4:
			case CMap::tile_bconcrete_v5:
			case CMap::tile_bconcrete_v6:
			case CMap::tile_bconcrete_v7:
			case CMap::tile_bconcrete_v8:
			case CMap::tile_bconcrete_v9:
			case CMap::tile_bconcrete_v10:
			case CMap::tile_bconcrete_v11:
			case CMap::tile_bconcrete_v12:
			case CMap::tile_bconcrete_v13:
			case CMap::tile_bconcrete_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_bconcrete_d0);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);

				for (u8 i = 0; i < 4; i++)
				{
					bconcrete_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_bconcrete_d0;
			}

			case CMap::tile_bconcrete_d0:
			case CMap::tile_bconcrete_d1:
			case CMap::tile_bconcrete_d2:
			case CMap::tile_bconcrete_d3:
			case CMap::tile_bconcrete_d4:
			case CMap::tile_bconcrete_d5:
			case CMap::tile_bconcrete_d6:
				return oldTileType + 1;

			case CMap::tile_bconcrete_d7:
			{
				return CMap::tile_empty;
			}

			case CMap::tile_mossybconcrete:
				return CMap::tile_mossybconcrete_d0;

			case CMap::tile_mossybconcrete_d0:
			case CMap::tile_mossybconcrete_d1:
			case CMap::tile_mossybconcrete_d2:
			case CMap::tile_mossybconcrete_d3:
				return oldTileType + 1;

			case CMap::tile_mossybconcrete_d4:
				return CMap::tile_empty;

			case CMap::tile_snow:
			case CMap::tile_snow_v0:
			case CMap::tile_snow_v1:
			case CMap::tile_snow_v2:
			case CMap::tile_snow_v3:
			case CMap::tile_snow_v4:
			case CMap::tile_snow_v5:
				return CMap::tile_snow_d0;

			case CMap::tile_snow_d0:
			case CMap::tile_snow_d1:
			case CMap::tile_snow_d2:
				return oldTileType + 1;

			case CMap::tile_snow_d3:
				return CMap::tile_empty;

			case CMap::tile_snow_pile:
			case CMap::tile_snow_pile_v0:
			case CMap::tile_snow_pile_v1:
			case CMap::tile_snow_pile_v2:
			case CMap::tile_snow_pile_v3:
				return oldTileType + 2;

			case CMap::tile_snow_pile_v4:
			case CMap::tile_snow_pile_v5:
				return CMap::tile_empty;

			case CMap::tile_goldingot:
			case CMap::tile_goldingot_d0:
				return oldTileType + 1;
			case CMap::tile_goldingot_d1:
				return CMap::tile_empty;

			case CMap::tile_mithrilingot:
			case CMap::tile_mithrilingot_d0:
				return oldTileType + 1;
			case CMap::tile_mithrilingot_d1:
				return CMap::tile_empty;

			case CMap::tile_copperingot:
			case CMap::tile_copperingot_d0:
				return oldTileType + 1;
			case CMap::tile_copperingot_d1:
				return CMap::tile_empty;

			case CMap::tile_steelingot:
			case CMap::tile_steelingot_d0:
				return oldTileType + 1;
			case CMap::tile_steelingot_d1:
				return CMap::tile_empty;

			case CMap::tile_ironingot:
			case CMap::tile_ironingot_d0:
				return oldTileType + 1;
			case CMap::tile_ironingot_d1:
				return CMap::tile_empty;
		}
	}
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if (tile_new == CMap::tile_ground && isClient()) Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

	switch(tile_new)
	{
		case CMap::tile_empty:
		case CMap::tile_ground_back:
		{
			if(tile_old == CMap::tile_iron_d8 || tile_old == CMap::tile_biron_d8 || tile_old == CMap::tile_rustyiron_d4)
				OnIronTileDestroyed(map, index);
			else if (tile_old == CMap::tile_bglass_d0 || tile_old == CMap::tile_glass_d0)
				OnGlassTileDestroyed(map, index);
			else if (tile_old == CMap::tile_plasteel_d14 || tile_old == CMap::tile_bplasteel_d14)
				OnPlasteelTileDestroyed(map, index);
			else if (tile_old == CMap::tile_concrete_d7 || tile_old == CMap::tile_reinforcedconcrete_d15 || tile_old == CMap::tile_mossyconcrete_d4 || tile_old == CMap::tile_bconcrete_d7)
				OnConcreteTileDestroyed(map, index);
			else if (tile_old == CMap::tile_matter_d2)
				OnMatterTileDestroyed(map, index);
			else if (tile_old == CMap::tile_snow_d3 || tile_old == CMap::tile_snow_pile_v4 || tile_old == CMap::tile_snow_pile_v5)
				OnSnowTileDestroyed(map, index);
			else if (tile_old == CMap::tile_kudzu_d0)
				OnKudzuTileHit(map, index);

			if(isTileSnowPile(map.getTile(index-map.tilemapwidth).type) && map.tilemapwidth < index)
				map.server_SetTile(map.getTileWorldPosition(index-map.tilemapwidth), CMap::tile_empty);
			break;
		}
	}

	if (map.getTile(index).type > 255)
	{
		u32 id = tile_new;
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case CMap::tile_glass:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				glass_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				map.RemoveTileFlag( index, Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}

			case CMap::tile_glass_v0:
			case CMap::tile_glass_v1:
			case CMap::tile_glass_v2:
			case CMap::tile_glass_v3:
			case CMap::tile_glass_v4:
			case CMap::tile_glass_v5:
			case CMap::tile_glass_v6:
			case CMap::tile_glass_v7:
			case CMap::tile_glass_v8:
			case CMap::tile_glass_v9:
			case CMap::tile_glass_v10:
			case CMap::tile_glass_v11:
			case CMap::tile_glass_v12:
			case CMap::tile_glass_v13:
			case CMap::tile_glass_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);

				break;

			case CMap::tile_glass_d0:
				OnGlassTileHit(map, index);
				break;


			case CMap::tile_plasteel:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;

			case CMap::tile_plasteel_d0:
			case CMap::tile_plasteel_d1:
			case CMap::tile_plasteel_d2:
			case CMap::tile_plasteel_d3:
			case CMap::tile_plasteel_d4:
			case CMap::tile_plasteel_d5:
			case CMap::tile_plasteel_d6:
			case CMap::tile_plasteel_d7:
			case CMap::tile_plasteel_d8:
			case CMap::tile_plasteel_d9:
			case CMap::tile_plasteel_d10:
			case CMap::tile_plasteel_d11:
			case CMap::tile_plasteel_d12:
			case CMap::tile_plasteel_d13:
			case CMap::tile_plasteel_d14:
				OnPlasteelTileHit(map, index);
				break;

			case CMap::tile_matter:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;

			case CMap::tile_matter_d0:
			case CMap::tile_matter_d1:
			case CMap::tile_matter_d2:
				OnMatterTileHit(map, index);
				break;

			case CMap::tile_brick_v0:
			case CMap::tile_brick_v1:
			case CMap::tile_brick_v2:
			case CMap::tile_brick_v3:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

				break;

			case CMap::tile_bglass:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				bglass_SetTile(map, pos);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

				break;
			}

			case CMap::tile_bglass_v0:
			case CMap::tile_bglass_v1:
			case CMap::tile_bglass_v2:
			case CMap::tile_bglass_v3:
			case CMap::tile_bglass_v4:
			case CMap::tile_bglass_v5:
			case CMap::tile_bglass_v6:
			case CMap::tile_bglass_v7:
			case CMap::tile_bglass_v8:
			case CMap::tile_bglass_v9:
			case CMap::tile_bglass_v10:
			case CMap::tile_bglass_v11:
			case CMap::tile_bglass_v12:
			case CMap::tile_bglass_v13:
			case CMap::tile_bglass_v14:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);

				break;

			case CMap::tile_bglass_d0:
				OnBGlassTileHit(map, index);
				break;

			case CMap::tile_biron:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				OnBIronTileUpdate(false, true, map, pos);

				TileType up = map.getTile(pos - Vec2f( 0.0f, 8.0f)).type;
				TileType down = map.getTile(pos + Vec2f( 0.0f, 8.0f)).type;
				bool isUp = (up >= CMap::tile_biron && up <= CMap::tile_biron_m) ? true : false;
				bool isDown = (down >= CMap::tile_biron && down <= CMap::tile_biron_m) ? true : false;

				if(isUp && isDown)
					map.SetTile(index, CMap::tile_biron_m);
				else if(isUp || isDown)
				{
					if(isUp && !isDown)
						map.SetTile(index, CMap::tile_biron_u);
					if(!isUp && isDown)
						map.SetTile(index, CMap::tile_biron_d);
				}
				else
					map.SetTile(index, CMap::tile_biron);

				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);




				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

				break;
			}

			case CMap::tile_biron_u:
			case CMap::tile_biron_d:
			case CMap::tile_biron_m:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;

			case CMap::tile_biron_d0:
			case CMap::tile_biron_d1:
			case CMap::tile_biron_d2:
			case CMap::tile_biron_d3:
			case CMap::tile_biron_d4:
			case CMap::tile_biron_d5:
			case CMap::tile_biron_d6:
			case CMap::tile_biron_d7:
			case CMap::tile_biron_d8:
				OnBIronTileHit(map, index);
				break;

			case CMap::tile_bplasteel:
				if((index / map.tilemapwidth + index % map.tilemapwidth) % 2 == 0) map.SetTile(index, CMap::tile_bplasteel_v0);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;

			case CMap::tile_bplasteel_d0:
			case CMap::tile_bplasteel_d1:
			case CMap::tile_bplasteel_d2:
			case CMap::tile_bplasteel_d3:
			case CMap::tile_bplasteel_d4:
			case CMap::tile_bplasteel_d5:
			case CMap::tile_bplasteel_d6:
			case CMap::tile_bplasteel_d7:
			case CMap::tile_bplasteel_d8:
			case CMap::tile_bplasteel_d9:
			case CMap::tile_bplasteel_d10:
			case CMap::tile_bplasteel_d11:
			case CMap::tile_bplasteel_d12:
			case CMap::tile_bplasteel_d13:
			case CMap::tile_bplasteel_d14:
				OnBPlasteelTileHit(map, index);
				break;

			case CMap::tile_tnt:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES | Tile::FLAMMABLE);
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE);

				if (isClient()) Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;

			//Kudzu
			case CMap::tile_kudzu:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES | Tile::FLAMMABLE);
				kudzu_SetTile(map, pos);
				map.RemoveTileFlag( index, Tile::WATER_PASSES);

				if (isClient()) Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}

			case CMap::tile_kudzu_v0:
			case CMap::tile_kudzu_v1:
			case CMap::tile_kudzu_v2:
			case CMap::tile_kudzu_v3:
			case CMap::tile_kudzu_v4:
			case CMap::tile_kudzu_v5:
			case CMap::tile_kudzu_v6:
			case CMap::tile_kudzu_v7:
			case CMap::tile_kudzu_v8:
			case CMap::tile_kudzu_v9:
			case CMap::tile_kudzu_v10:
			case CMap::tile_kudzu_v11:
			case CMap::tile_kudzu_v12:
			case CMap::tile_kudzu_v13:
			case CMap::tile_kudzu_v14:
			case CMap::tile_kudzu_f14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES | Tile::FLAMMABLE);
				break;

			case CMap::tile_kudzu_d0:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES); // | Tile::FLAMMABLE);
				OnKudzuTileHit(map, index);
				break;
			//Kudzu End

			case CMap::tile_concrete:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				concrete_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

				break;
			}

			case CMap::tile_concrete_v0:
			case CMap::tile_concrete_v1:
			case CMap::tile_concrete_v2:
			case CMap::tile_concrete_v3:
			case CMap::tile_concrete_v4:
			case CMap::tile_concrete_v5:
			case CMap::tile_concrete_v6:
			case CMap::tile_concrete_v7:
			case CMap::tile_concrete_v8:
			case CMap::tile_concrete_v9:
			case CMap::tile_concrete_v10:
			case CMap::tile_concrete_v11:
			case CMap::tile_concrete_v12:
			case CMap::tile_concrete_v13:
			case CMap::tile_concrete_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_concrete_d0:
			case CMap::tile_concrete_d1:
			case CMap::tile_concrete_d2:
			case CMap::tile_concrete_d3:
			case CMap::tile_concrete_d4:
			case CMap::tile_concrete_d5:
			case CMap::tile_concrete_d6:
			case CMap::tile_concrete_d7:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnConcreteTileHit(map, index);
				break;

			case CMap::tile_rail_0:
			case CMap::tile_rail_1:
				map.AddTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
				map.RemoveTileFlag( index, Tile::COLLISION | Tile::SOLID | Tile::FLAMMABLE);
				break;

			case CMap::tile_rail_0_bg:
			case CMap::tile_rail_1_bg:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::FLAMMABLE | Tile::WATER_PASSES);
				break;

			case CMap::tile_iron:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				iron_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

				break;
			}

			case CMap::tile_iron_v0:
			case CMap::tile_iron_v1:
			case CMap::tile_iron_v2:
			case CMap::tile_iron_v3:
			case CMap::tile_iron_v4:
			case CMap::tile_iron_v5:
			case CMap::tile_iron_v6:
			case CMap::tile_iron_v7:
			case CMap::tile_iron_v8:
			case CMap::tile_iron_v9:
			case CMap::tile_iron_v10:
			case CMap::tile_iron_v11:
			case CMap::tile_iron_v12:
			case CMap::tile_iron_v13:
			case CMap::tile_iron_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;

			case CMap::tile_iron_d0:
			case CMap::tile_iron_d1:
			case CMap::tile_iron_d2:
			case CMap::tile_iron_d3:
			case CMap::tile_iron_d4:
			case CMap::tile_iron_d5:
			case CMap::tile_iron_d6:
			case CMap::tile_iron_d7:
			case CMap::tile_iron_d8:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnIronTileHit(map, index);
				break;

			case CMap::tile_rustyiron:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_rustyiron_d0:
			case CMap::tile_rustyiron_d1:
			case CMap::tile_rustyiron_d2:
			case CMap::tile_rustyiron_d3:
			case CMap::tile_rustyiron_d4:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnIronTileHit(map, index);
				break;

			case CMap::tile_reinforcedconcrete:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				reinforcedconcrete_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

				break;
			}

			case CMap::tile_reinforcedconcrete_v0:
			case CMap::tile_reinforcedconcrete_v1:
			case CMap::tile_reinforcedconcrete_v2:
			case CMap::tile_reinforcedconcrete_v3:
			case CMap::tile_reinforcedconcrete_v4:
			case CMap::tile_reinforcedconcrete_v5:
			case CMap::tile_reinforcedconcrete_v6:
			case CMap::tile_reinforcedconcrete_v7:
			case CMap::tile_reinforcedconcrete_v8:
			case CMap::tile_reinforcedconcrete_v9:
			case CMap::tile_reinforcedconcrete_v10:
			case CMap::tile_reinforcedconcrete_v11:
			case CMap::tile_reinforcedconcrete_v12:
			case CMap::tile_reinforcedconcrete_v13:
			case CMap::tile_reinforcedconcrete_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_reinforcedconcrete_d0:
			case CMap::tile_reinforcedconcrete_d1:
			case CMap::tile_reinforcedconcrete_d2:
			case CMap::tile_reinforcedconcrete_d3:
			case CMap::tile_reinforcedconcrete_d4:
			case CMap::tile_reinforcedconcrete_d5:
			case CMap::tile_reinforcedconcrete_d6:
			case CMap::tile_reinforcedconcrete_d7:
			case CMap::tile_reinforcedconcrete_d8:
			case CMap::tile_reinforcedconcrete_d9:
			case CMap::tile_reinforcedconcrete_d10:
			case CMap::tile_reinforcedconcrete_d11:
			case CMap::tile_reinforcedconcrete_d12:
			case CMap::tile_reinforcedconcrete_d13:
			case CMap::tile_reinforcedconcrete_d14:
			case CMap::tile_reinforcedconcrete_d15:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnConcreteTileHit(map, index);
				break;

			case CMap::tile_mossyconcrete:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_mossyconcrete_d0:
			case CMap::tile_mossyconcrete_d1:
			case CMap::tile_mossyconcrete_d2:
			case CMap::tile_mossyconcrete_d3:
			case CMap::tile_mossyconcrete_d4:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnConcreteTileHit(map, index);
				break;

			case CMap::tile_bconcrete:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				bconcrete_SetTile(map, pos);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

				break;
			}

			case CMap::tile_bconcrete_v0:
			case CMap::tile_bconcrete_v1:
			case CMap::tile_bconcrete_v2:
			case CMap::tile_bconcrete_v3:
			case CMap::tile_bconcrete_v4:
			case CMap::tile_bconcrete_v5:
			case CMap::tile_bconcrete_v6:
			case CMap::tile_bconcrete_v7:
			case CMap::tile_bconcrete_v8:
			case CMap::tile_bconcrete_v9:
			case CMap::tile_bconcrete_v10:
			case CMap::tile_bconcrete_v11:
			case CMap::tile_bconcrete_v12:
			case CMap::tile_bconcrete_v13:
			case CMap::tile_bconcrete_v14:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);
				break;

			case CMap::tile_bconcrete_d0:
			case CMap::tile_bconcrete_d1:
			case CMap::tile_bconcrete_d2:
			case CMap::tile_bconcrete_d3:
			case CMap::tile_bconcrete_d4:
			case CMap::tile_bconcrete_d5:
			case CMap::tile_bconcrete_d6:
			case CMap::tile_bconcrete_d7:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);
				OnBConcreteTileHit(map, index);
				break;

			case CMap::tile_mossybconcrete:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);
				break;

			case CMap::tile_mossybconcrete_d0:
			case CMap::tile_mossybconcrete_d1:
			case CMap::tile_mossybconcrete_d2:
			case CMap::tile_mossybconcrete_d3:
			case CMap::tile_mossybconcrete_d4:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);
				OnBConcreteTileHit(map, index);
				break;

			case CMap::tile_snow:
				if(isClient())
				{
					int add = index % 7;
					if(add > 0)
					map.SetTile(index, CMap::tile_snow + add);
				}
				map.SetTileSupport(index, 1);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_snow_v0:
			case CMap::tile_snow_v1:
			case CMap::tile_snow_v2:
			case CMap::tile_snow_v3:
			case CMap::tile_snow_v4:
			case CMap::tile_snow_v5:
				map.SetTileSupport(index, 1);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_snow_d0:
			case CMap::tile_snow_d1:
			case CMap::tile_snow_d2:
			case CMap::tile_snow_d3:
				map.SetTileSupport(index, 1);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				if(isClient()) OnSnowTileHit(map, index);
				break;

			case CMap::tile_snow_pile:
			case CMap::tile_snow_pile_v0:
			case CMap::tile_snow_pile_v1:
			case CMap::tile_snow_pile_v2:
			case CMap::tile_snow_pile_v3:
			case CMap::tile_snow_pile_v4:
			case CMap::tile_snow_pile_v5:
				if(tile_new > tile_old && isTileSnowPile(tile_old)) // if pile got smaller do particles
				{
					if(isClient()) OnSnowTileHit(map, index);
				}
				map.SetTileSupport(index, 0);
				map.AddTileFlag(index, Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;


			case CMap::tile_goldingot:
			{
				map.RemoveTileFlag( index, Tile::WATER_PASSES);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
			}
			case CMap::tile_goldingot_d0:
			case CMap::tile_goldingot_d1:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;

			case CMap::tile_mithrilingot:
			{
				map.RemoveTileFlag( index, Tile::WATER_PASSES);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
			}
			case CMap::tile_mithrilingot_d0:
			case CMap::tile_mithrilingot_d1:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;

			case CMap::tile_copperingot:
			{
				map.RemoveTileFlag( index, Tile::WATER_PASSES);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
			}
			case CMap::tile_copperingot_d0:
			case CMap::tile_copperingot_d1:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			
			case CMap::tile_steelingot:
			{
				map.RemoveTileFlag( index, Tile::WATER_PASSES);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
			}
			case CMap::tile_steelingot_d0:
			case CMap::tile_steelingot_d1:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			
			case CMap::tile_ironingot:
			{
				map.RemoveTileFlag( index, Tile::WATER_PASSES);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
			}
			case CMap::tile_ironingot_d0:
			case CMap::tile_ironingot_d1:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
		}
	}
}


void OnIronTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES );

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);
		sparks(pos, 1, 1);
	}
}

void OnBIronTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);
		sparks(pos, 1, 1);
	}
}

void OnIronTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("destroy_stone.ogg", pos, 1.0f, 1.0f);
	}
}

void OnBIronTileUpdate(bool updateThis, bool updateOthers, CMap@ map, Vec2f pos)
{
	TileType up = map.getTile(pos - Vec2f( 0.0f, 8.0f)).type;
	TileType down = map.getTile(pos + Vec2f( 0.0f, 8.0f)).type;
	bool isUp = (up >= CMap::tile_biron && up <= CMap::tile_biron_m) ? true : false;
	bool isDown = (down >= CMap::tile_biron && down <= CMap::tile_biron_m) ? true : false;

	if(updateThis)
	{
		if(isUp && isDown)
			map.server_SetTile(pos, CMap::tile_biron_m);
		else if(isUp || isDown)
		{
			if(isUp && !isDown)
				map.server_SetTile(pos, CMap::tile_biron_u);
			if(!isUp && isDown)
				map.server_SetTile(pos, CMap::tile_biron_d);
		}
		else
			map.server_SetTile(pos, CMap::tile_biron);
	}
	if(updateOthers)
	{
		if(isUp)
			OnBIronTileUpdate(true, false, map, pos - Vec2f( 0.0f, 8.0f));
		if(isDown)
			OnBIronTileUpdate(true, false, map, pos + Vec2f( 0.0f, 8.0f));
	}
}

void iron_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_iron + iron_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		iron_Update(map, pos + directions[i]);
	}
}

u8 iron_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (isIronTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void iron_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (isIronTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_iron+iron_GetMask(map,pos));
}

bool isIronTile(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_iron && tile <= CMap::tile_iron_v14;
}

void OnGlassTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("GlassBreak2.ogg", pos, 1.0f, 1.0f);
		glasssparks(pos, 5 + XORRandom(5));
	}
}

void OnBGlassTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("GlassBreak2.ogg", pos, 1.0f, 1.0f);
		glasssparks(pos, 3 + XORRandom(2));
	}
}

void OnGlassTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("GlassBreak1.ogg", pos, 1.0f, 1.0f);
		glasssparks(pos, 5 + XORRandom(3));
	}
}

void glasssparks(Vec2f at, int amount)
{
	switch(XORRandom(4))
	{
		case 1:
			at += Vec2f(4, 0);
			break;
		case 2:
			at += Vec2f(0, 4);
			break;
		case 3:
			at += Vec2f(8, 4);
			break;
		case 4:
			at += Vec2f(4, 8);
			break;
	}
	SColor[] colors =
	{
		SColor(255, 217, 242, 246),
		SColor(255, 255, 255, 255),
		SColor(255, 85, 119, 130),
		SColor(255, 79, 145, 167),
		SColor(255, 48, 60, 65),
		SColor(255, 21, 27, 30)
	};

	if (isClient())
	{
		for (int i = 0; i < amount; i++)
		{
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
			ParticlePixel(at, vel, colors[XORRandom(6)], true);
			makeGibParticle("GlassSparks.png", at, vel, 0, XORRandom(5)-1, Vec2f(4.0f, 4.0f), 2.0f, 1, "GlassBreak1.ogg");
		}
	}
}

u8 glass_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (isGlassTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

u8 bglass_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (isBGlassTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void glass_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_glass + glass_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		glass_Update(map, pos + directions[i]);
	}
}

void bglass_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_bglass + bglass_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		bglass_Update(map, pos + directions[i]);
	}
}

void glass_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (isGlassTile(map, pos))
		map.server_SetTile(pos,CMap::tile_glass+glass_GetMask(map,pos));
}

void bglass_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (isBGlassTile(map, pos))
		map.server_SetTile(pos,CMap::tile_bglass+bglass_GetMask(map,pos));
}

bool isGlassTile(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_glass && tile <= CMap::tile_glass_v14;
}

bool isBGlassTile(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bglass && tile <= CMap::tile_bglass_v14;
}

u8 kudzu_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		//if (isKudzuTile(map, pos + directions[i])) mask |= 1 << i;
		if (kudzu_MaskOk(map, pos + directions[i])) mask |= 1 << i;
	}
	if (mask == 15 && XORRandom(6) == 0)
	{
		mask = 16; //flowers
	}

	return mask;
}

bool kudzu_MaskOk(CMap@ map, Vec2f pos) //Kudzu has connected textures with other solid tiles even non kudzu tiles
{
	const u32 offset = map.getTileOffset(pos);
	u16 tile = map.getTile(pos).type;
	
	return map.hasTileFlag(offset, Tile::SOLID) && tile != CMap::tile_kudzu_d0;
}

void kudzu_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_kudzu + kudzu_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		kudzu_Update(map, pos + directions[i]);
	}
}

void kudzu_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (isKudzuTile(map, pos))
	{
		map.server_SetTile(pos,CMap::tile_kudzu+kudzu_GetMask(map,pos));
	}
}

bool isKudzuTile(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_kudzu && tile <= CMap::tile_kudzu_f14;
}

void OnKudzuTileHit(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("/cut_grass.ogg", pos, 1.0f, 1.0f);
	}
}

void OnPlasteelTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES );

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.7f);
	}
}

void OnBPlasteelTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);
	}
}

void OnPlasteelTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("destroy_stone.ogg", pos, 1.0f, 1.0f);
	}
}

void OnConcreteTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES );

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		for (int i = 0; i < 3; i++)
		{
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
			SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 57, 51, 47)
			: SColor(255, 110, 100, 93);
			ParticlePixel(pos+Vec2f(4, 0), vel, color, true);
		}
		Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 1.0f);
	}
}

void OnBConcreteTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		for (int i = 0; i < 3; i++)
		{
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
			SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 57, 51, 47)
			: SColor(255, 110, 100, 93);
			ParticlePixel(pos+Vec2f(4, 0), vel, color, true);
		}
		Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 1.0f);
	}
}

void OnConcreteTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		for (int i = 0; i < 15; i++)
		{
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
			SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 57, 51, 47)
			: SColor(255, 110, 100, 93);
			ParticlePixel(pos+Vec2f(4, 0), vel, color, true);
		}
		ParticleAnimated("Smoke.png", pos+Vec2f(4, 0),
		Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);
		Sound::Play("destroy_wall.ogg", pos, 1.0f, 1.0f);
	}
}

void concrete_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_concrete + concrete_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		concrete_Update(map, pos + directions[i]);
	}
}

u8 concrete_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (isConcreteTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void concrete_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (isConcreteTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_concrete+concrete_GetMask(map,pos));
}

bool isConcreteTile(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_concrete && tile <= CMap::tile_concrete_v14;
}

void reinforcedconcrete_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_reinforcedconcrete + reinforcedconcrete_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		reinforcedconcrete_Update(map, pos + directions[i]);
	}
}

u8 reinforcedconcrete_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (isReinforcedConcreteTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void reinforcedconcrete_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (isReinforcedConcreteTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_reinforcedconcrete+reinforcedconcrete_GetMask(map,pos));
}

bool isReinforcedConcreteTile(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_reinforcedconcrete && tile <= CMap::tile_reinforcedconcrete_v14;
}

void bconcrete_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_bconcrete + bconcrete_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		bconcrete_Update(map, pos + directions[i]);
	}
}

u8 bconcrete_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (isBConcreteTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void bconcrete_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (isBConcreteTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_bconcrete+bconcrete_GetMask(map,pos));
}

bool isBConcreteTile(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bconcrete && tile <= CMap::tile_bconcrete_v14;
}

void tntsparks(Vec2f at)
{
	if(!isClient()){return;}
	at += Vec2f(4, 0);
	for (int i = 0; i < 15; i++)
	{
		Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
		vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
		SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 196, 71, 30)
		: SColor(255, 142, 42, 9);
		ParticlePixel(at, vel, color, true);
	}
}

void OnTNTTileHit(CMap@ map, u32 index, f32 damage, bool onfire)
{
	map.AddTileFlag(index, Tile::BACKGROUND);

	Vec2f pos = map.getTileWorldPosition(index);
	if(onfire || damage > 1.7f)
	{
		map.server_SetTile(pos,CMap::tile_empty);

		WorldExplode(pos, 60, 10);
	}
	else
	{
		if (isClient())
		{
			Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg",
				map.getTileWorldPosition(index), 1.0f, 1.0f);
			tntsparks(map.getTileWorldPosition(index));
		}
	}
}

void OnMatterTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		mattersparks(pos, 5);
		Sound::Play("dig_stone.ogg", pos, 0.8f, 1.2f);
	}
}

void OnBrickTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.7f);
	}
}

const Vec2f[] directions =
{
	Vec2f(0, -8),
	Vec2f(0, 8),
	Vec2f(8, 0),
	Vec2f(-8, 0)
};


void OnMatterTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		ParticleAnimated("MatterSmoke.png", pos+Vec2f(4, 4), Vec2f(0, -1), 0.0f, 1.0f, 3, 0.0f, false);
		Sound::Play("destroy_gold.ogg", pos, 0.8f, 1.2f);
	}
}

void mattersparks(Vec2f at, int amount)
{
	switch(XORRandom(4))
	{
		case 1:
			at += Vec2f(4, 0);
			break;
		case 2:
			at += Vec2f(0, 4);
			break;
		case 3:
			at += Vec2f(8, 4);
			break;
		case 4:
			at += Vec2f(4, 8);
			break;
	}
	SColor[] colors =
	{
		SColor(255, 34, 149, 42),
		SColor(255, 255, 63, 202),
		SColor(255, 118, 218, 255),
		SColor(255, 229, 179, 255),
		SColor(255, 15, 20, 106),
		SColor(255, 12, 69, 16)
	};

	if(isClient())
	{
		for (int i = 0; i < amount; i++)
		{
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
			ParticlePixel(at, vel, colors[XORRandom(6)], true);
		}
	}
}

void OnSnowTileHit(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		for (int i = 0; i < 3; i++)
		{
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
			SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 57, 51, 47)
			: SColor(255, 110, 100, 93);
			ParticlePixel(pos+Vec2f(4, 0), vel, color, true);
		}
		Sound::Play("dig_dirt" + (1 + XORRandom(3)), pos, 0.80f, 1.30f);
	}
}

void OnSnowTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		for (int i = 0; i < 15; i++)
		{
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
			SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 57, 51, 47)
			: SColor(255, 110, 100, 93);
			ParticlePixel(pos+Vec2f(4, 0), vel, color, true);
		}
		ParticleAnimated("Smoke.png", pos+Vec2f(4, 0),
		Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);
		Sound::Play("destroy_dirt.ogg", pos, 0.80f, 1.30f);
	}
}
