void HandleCustomTile( CMap@ map, int offset, SColor pixel )
{
	// print("custom");

	// if (pixel == color_goo)
	// {
		// map.SetTile(offset, CMap::tile_goo );
		// map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );

		// //map.AddTileFlag( offset, Tile::BACKGROUND );
		// //map.AddTileFlag( offset, Tile::LADDER );
		// //map.AddTileFlag( offset, Tile::LIGHT_PASSES );
		// //map.AddTileFlag( offset, Tile::WATER_PASSES );
		// //map.AddTileFlag( offset, Tile::FLAMMABLE );
		// //map.AddTileFlag( offset, Tile::PLATFORM );
		// //map.AddTileFlag( offset, Tile::LIGHT_SOURCE );
	// }
}

namespace CMap
{
	enum CustomTiles
	{ 
		tile_iron = 384,
		tile_iron_d0,
		tile_iron_d1,
		tile_iron_d2,
		tile_iron_d3,
		tile_iron_d4,
		tile_iron_d5,
		tile_iron_d6,
		tile_iron_d7,
		tile_iron_d8,
		tile_glass = 394,
		tile_glass_v0,
		tile_glass_v1,
		tile_glass_v2,
		tile_glass_v3,
		tile_glass_v4,
		tile_glass_v5,
		tile_glass_v6,
		tile_glass_v7,
		tile_glass_v8,
		tile_glass_v9,
		tile_glass_v10,
		tile_glass_v11,
		tile_glass_v12,
		tile_glass_v13,
		tile_glass_v14,
		tile_glass_d0,
		tile_plasteel = 411,
		tile_plasteel_d0,
		tile_plasteel_d1,
		tile_plasteel_d2,
		tile_plasteel_d3,
		tile_plasteel_d4,
		tile_plasteel_d5,
		tile_plasteel_d6,
		tile_plasteel_d7,
		tile_plasteel_d8,
		tile_plasteel_d9,
		tile_plasteel_d10,
		tile_plasteel_d11,
		tile_plasteel_d12,
		tile_plasteel_d13,
		tile_plasteel_d14,
		tile_matter = 427,
		tile_matter_d0,
		tile_matter_d1,
		tile_matter_d2,
		tile_brick_v0 = 431,
		tile_brick_v1,
		tile_brick_v2,
		tile_brick_v3,
		tile_bglass = 435,
		tile_bglass_v0,
		tile_bglass_v1,
		tile_bglass_v2,
		tile_bglass_v3,
		tile_bglass_v4,
		tile_bglass_v5,
		tile_bglass_v6,
		tile_bglass_v7,
		tile_bglass_v8,
		tile_bglass_v9,
		tile_bglass_v10,
		tile_bglass_v11,
		tile_bglass_v12,
		tile_bglass_v13,
		tile_bglass_v14,
		tile_bglass_d0,
		tile_biron = 452,
		tile_biron_u,
		tile_biron_d,
		tile_biron_m,
		tile_biron_d0,
		tile_biron_d1,
		tile_biron_d2,
		tile_biron_d3,
		tile_biron_d4,
		tile_biron_d5,
		tile_biron_d6,
		tile_biron_d7,
		tile_biron_d8,
		tile_bplasteel = 465,
		tile_bplasteel_v0,
		tile_bplasteel_d0,
		tile_bplasteel_d1,
		tile_bplasteel_d2,
		tile_bplasteel_d3,
		tile_bplasteel_d4,
		tile_bplasteel_d5,
		tile_bplasteel_d6,
		tile_bplasteel_d7,
		tile_bplasteel_d8,
		tile_bplasteel_d9,
		tile_bplasteel_d10,
		tile_bplasteel_d11,
		tile_bplasteel_d12,
		tile_bplasteel_d13,
		tile_bplasteel_d14,
		tile_tnt = 482,
		tile_concrete = 483,
		tile_concrete_v0,
		tile_concrete_v1,
		tile_concrete_v2,
		tile_concrete_v3,
		tile_concrete_v4,
		tile_concrete_v5,
		tile_concrete_v6,
		tile_concrete_v7,
		tile_concrete_v8,
		tile_concrete_v9,
		tile_concrete_v10,
		tile_concrete_v11,
		tile_concrete_v12,
		tile_concrete_v13,
		tile_concrete_v14,
		tile_concrete_d0,
		tile_concrete_d1,
		tile_concrete_d2,
		tile_concrete_d3,
		tile_concrete_d4,
		tile_concrete_d5,
		tile_concrete_d6,
		tile_concrete_d7 = 506,
		tile_rail_0 = 507,
		tile_rail_1 = 508,
		tile_rail_0_bg = 509,
		tile_rail_1_bg = 510
	};
};

void onInit(CMap@ this)
{
    this.legacyTileMinimap = false;
    this.MakeMiniMap();
	
	CRules@ rules = getRules();
	rules.addCommandID("add_tile");
	rules.addCommandID("remove_tile");
}