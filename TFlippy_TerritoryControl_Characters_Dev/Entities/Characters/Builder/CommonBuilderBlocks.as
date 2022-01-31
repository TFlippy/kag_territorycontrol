// CommonBuilderBlocks.as

//////////////////////////////////////
// Builder menu documentation
//////////////////////////////////////

// To add a new page;

// 1) initialize a new BuildBlock array, 
// example:
// BuildBlock[] my_page;
// blocks.push_back(my_page);

// 2) 
// Add a new string to PAGE_NAME in 
// BuilderInventory.as
// this will be what you see in the caption
// box below the menu

// 3)
// Extend BuilderPageIcons.png with your new
// page icon, do note, frame index is the same
// as array index

// To add new blocks to a page, push_back
// in the desired order to the desired page
// example:
// BuildBlock b(0, "name", "icon", "description");
// blocks[3].push_back(b);


//#include "LoaderUtilities.as";
#include "BuildBlock.as";
#include "Requirements.as";
#include "Descriptions.as";
#include "CustomBlocks.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks, int teamnum = 7)
{
	//Basic
	AddIconToken("$glass_block$", "World.png", Vec2f(8, 8), CMap::tile_glass);
	AddIconToken("$bglass_block$", "World.png", Vec2f(8, 8), CMap::tile_bglass);
	AddIconToken("$concrete_block$", "World.png", Vec2f(8, 8), CMap::tile_concrete);
	AddIconToken("$bconcrete_block$", "World.png", Vec2f(8, 8), CMap::tile_bconcrete);
	AddIconToken("$iron_block$", "World.png", Vec2f(8, 8), CMap::tile_iron);
	AddIconToken("$biron_block$", "World.png", Vec2f(8, 8), CMap::tile_biron);
	AddIconToken("$reinforcedconcrete_block$", "World.png", Vec2f(8, 8), CMap::tile_reinforcedconcrete);
	AddIconToken("$ground_block$", "World.png", Vec2f(8, 8), 16);
	AddIconToken("$plasteel_block$", "World.png", Vec2f(8, 8), CMap::tile_plasteel);
	AddIconToken("$bplasteel_block$", "World.png", Vec2f(8, 8), CMap::tile_bplasteel);
	AddIconToken("$icon_stone_door$", "1x1StoneDoor.png", Vec2f(16, 8), 0, teamnum);
	AddIconToken("$icon_wooden_door$", "1x1WoodDoor.png", Vec2f(16, 8), 0, teamnum);
	AddIconToken("$icon_trapblock$", "TrapBlock.png", Vec2f(8, 8), 0, teamnum);
	AddIconToken("$icon_iron_door$", "1x1IronDoor.png", Vec2f(16, 8), 0, teamnum);
	AddIconToken("$icon_plasteel_door$", "1x1PlasteelDoor.png", Vec2f(16, 8), 0, teamnum);
	AddIconToken("$wood_triangle$", "WoodTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$stone_triangle$", "StoneTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$concrete_triangle$", "ConcreteTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$iron_triangle$", "IronTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$stone_halfblock$", "StoneHalfBlock.png", Vec2f(8, 8), 0);
	AddIconToken("$iron_halfblock$", "IronHalfBlock.png", Vec2f(8, 8), 0);
	AddIconToken("$icon_ironplatform$", "IronPlatform.png", Vec2f(8, 8), 0);
	AddIconToken("$icon_ironladder$", "IronLadder_Icon.png", Vec2f(16, 16), 0, teamnum);
	AddIconToken("$tnt_block$", "World.png", Vec2f(8, 8), CMap::tile_tnt);
	AddIconToken("$brick_block$", "World.png", Vec2f(8, 8), 412);
	AddIconToken("$sand_block$", "World.png", Vec2f(8, 8), 220);
	AddIconToken("$kudzu_block$", "World.png", Vec2f(8, 8), CMap::tile_kudzu);
	AddIconToken("$goldingot_block$", "World.png", Vec2f(8, 8), CMap::tile_goldingot);
	AddIconToken("$mithrilingot_block$", "World.png", Vec2f(8, 8), CMap::tile_mithrilingot);
	AddIconToken("$copperingot_block$", "World.png", Vec2f(8, 8), CMap::tile_copperingot);
	AddIconToken("$steelingot_block$", "World.png", Vec2f(8, 8), CMap::tile_steelingot);
	AddIconToken("$ironingot_block$", "World.png", Vec2f(8, 8), CMap::tile_ironingot);

	//Buildings
	AddIconToken("$icon_buildershop$", "BuilderShop.png", Vec2f(40, 24), 0, teamnum);
	AddIconToken("$icon_quarters$", "Quarters.png", Vec2f(40, 24), 2, teamnum);
	AddIconToken("$icon_tinkertable$", "TinkerTable.png", Vec2f(40, 24), 0, teamnum);
	AddIconToken("$icon_armory$", "Armory.png", Vec2f(40, 24), 0, teamnum);
	AddIconToken("$icon_gunsmith$", "Gunsmith.png", Vec2f(40, 24), 0, teamnum);
	AddIconToken("$icon_bombshop$", "BombShop.png", Vec2f(40, 24), 0, teamnum);
	AddIconToken("$icon_storage$", "Storage.png", Vec2f(40, 24), 3, teamnum);
	AddIconToken("$icon_forge$", "Forge.png", Vec2f(24, 24), 0, teamnum);
	AddIconToken("$constructionyard$", "ConstructionYardIcon.png", Vec2f(16, 16), 0, teamnum);
	AddIconToken("$icon_camp$", "Camp.png", Vec2f(80, 24), 0, teamnum);
	AddIconToken("$icon_patreonshop$", "PatreonShop.png", Vec2f(40, 40), 0, teamnum);
	AddIconToken("$icon_nursery$","Nursery.png",Vec2f(40, 32), 5, teamnum);
	AddIconToken("$icon_library$", "Library.png", Vec2f(40, 24), 0, teamnum);
	AddIconToken("$icon_workshop$", "Building.png", Vec2f(40, 24), 0);

	//Automation
	AddIconToken("$icon_conveyor$", "Conveyor.png", Vec2f(8, 8), 0, teamnum);
	AddIconToken("$icon_separator$", "Seperator.png", Vec2f(8, 8), 0, teamnum);
	AddIconToken("$icon_filter$", "Filter.png", Vec2f(24, 8), 0, teamnum);
	AddIconToken("$icon_launcher$", "Launcher.png", Vec2f(8, 8), 0, teamnum);
	AddIconToken("$icon_jumper$", "Jumper.png", Vec2f(8, 8), 0, teamnum);
	AddIconToken("$icon_autoforge$", "AutoForge.png", Vec2f(24, 32), 0, teamnum);
	AddIconToken("$icon_inductionfurnace$", "InductionFurnace.png", Vec2f(40, 32), 0, teamnum);
	AddIconToken("$icon_assembler$", "Assembler.png", Vec2f(40, 24), 0, teamnum);
	AddIconToken("$icon_hopper$", "Hopper.png", Vec2f(24, 24), 0, teamnum);
	AddIconToken("$icon_fetcher$", "Fetcher.png", Vec2f(24, 24), 0, teamnum);
	AddIconToken("$icon_extractor$", "Extractor.png", Vec2f(16, 24), 0);
	AddIconToken("$icon_filterextractor$", "FilterExtractor.png", Vec2f(24, 24), 0, teamnum);
	AddIconToken("$icon_grinder$", "Grinder.png", Vec2f(40, 24), 0, teamnum);
	AddIconToken("$icon_stonepile$", "StonePile.png", Vec2f(24, 40), 3, teamnum);
	AddIconToken("$icon_packer$", "Packer.png", Vec2f(24, 16), 0, teamnum);
	AddIconToken("$icon_compactor$", "Compactor.png", Vec2f(24, 32), 0, teamnum);
	AddIconToken("$icon_smartstorage$", "SmartStorage.png", Vec2f(24, 24), 0);
	AddIconToken("$icon_inserter$", "Inserter.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_treecapitator$", "Treecapitator.png", Vec2f(24, 8), 0);
	AddIconToken("$icon_chickenassembler$", "ChickenAssembler.png", Vec2f(56, 24), 0, teamnum);
	AddIconToken("$icon_oiltank$","OilTank.png",Vec2f(32, 16), 0, teamnum);
	AddIconToken("$icon_gastank$","GasTank.png",Vec2f(16, 24), 0, teamnum);
	AddIconToken("$icon_chemlab$","ChemLab.png",Vec2f(48, 24), 0, teamnum);

	//Miscellaneous
	AddIconToken("$icon_lamppost$", "LampPost.png", Vec2f(8, 24), 0);
	AddIconToken("$icon_ironlocker$", "IronLocker.png", Vec2f(16, 24), 0, teamnum);
	AddIconToken("$icon_woodchest$", "WoodChest.png", Vec2f(16, 16), 0, teamnum);
	AddIconToken("$barbedwire$", "BarbedWire.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_teamlamp$", "TeamLamp.png", Vec2f(8, 8), 0, teamnum);
	AddIconToken("$icon_industriallamp$", "IndustrialLamp.png", Vec2f(8, 8), 0, teamnum);
	AddIconToken("$icon_drillrig$", "DrillRig.png", Vec2f(24, 24), 0, teamnum);
	AddIconToken("$icon_siren$", "Siren.png", Vec2f(24, 32), 0, teamnum);
	AddIconToken("$icon_textsign$", "TextSign_Large.png", Vec2f(64, 16), 0, teamnum);
	AddIconToken("$icon_smallsign$","sign.png",Vec2f(16, 16), 0);
	AddIconToken("$icon_securitystation$", "SecurityStation.png", Vec2f(24, 24), 0, teamnum);
	AddIconToken("$icon_ceilinglamp$", "CeilingLamp.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_1x5blastdoor$", "1x5BlastDoor.png", Vec2f(8, 40), 0, teamnum);
	AddIconToken("$icon_beamtower$", "BeamTower.png", Vec2f(32, 96), 0, teamnum);
	AddIconToken("$icon_beamtowermirror$", "BeamTowerMirror.png", Vec2f(16, 24), 0);
	AddIconToken("$icon_metaldetector$", "MetalDetector.png", Vec2f(24, 24), 0, teamnum);
	AddIconToken("$icon_mithrilreactor$", "MithrilReactor.png", Vec2f(24, 24), 0);
	AddIconToken("$icon_banner$","ClanBanner.png",Vec2f(16, 32), 0, teamnum);
	AddIconToken("$icon_druglab$","DrugLab.png",Vec2f(32, 40), 0);
	AddIconToken("$icon_altar$", "Altar.png", Vec2f(24, 32), 0, teamnum);
	AddIconToken("$icon_tavern$", "Vodka.png", Vec2f(8, 16), 0, teamnum);

	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_glass, "glass_block", "$glass_block$", "Glass\nFancy and fragile.");
		AddRequirement(b.reqs, "coin", "", "Coins", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_bglass, "bglass_block", "$bglass_block$", "Background Glass\nFancy and fragile.");
		AddRequirement(b.reqs, "coin", "", "Coins", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_concrete, "concrete_block", "$concrete_block$", "Concrete Block\nSlightly more durable than stone.");
		AddRequirement(b.reqs, "blob", "mat_concrete", "Concrete", 8);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_bconcrete, "bconcrete_block", "$bconcrete_block$", "Background Concrete Block\nSlightly more durable than stone.");
		AddRequirement(b.reqs, "blob", "mat_concrete", "Concrete", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_iron, "iron_block", "$iron_block$", "Iron Plating\nA durable metal block. Unbreakable by peasants.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_biron, "biron_block", "$biron_block$", "Background Iron Plating\nA durable background support. Unbreakable by peasants.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_reinforcedconcrete, "reinforcedconcrete_block", "$reinforcedconcrete_block$", "Reinforced Concrete Block\nMore durable than concrete.");
		AddRequirement(b.reqs, "blob", "mat_concrete", "Concrete", 8);
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_ground, "ground_block", "$ground_block$", "Dirt\nFairly resistant to explosions.\nMay be only placed on dirt backgrounds or damaged dirt.");
		AddRequirement(b.reqs, "blob", "mat_dirt", "Dirt", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_plasteel, "plasteel_block", "$plasteel_block$", "Plasteel Panel\nAn advanced composite material. Nearly indestructible.");
		AddRequirement(b.reqs, "blob", "mat_plasteel", "Plasteel Sheet", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_bplasteel, "bplasteel_block", "$bplasteel_block$", "Background Plasteel Panel\nAn advanced composite material. Nearly indestructible.");
		AddRequirement(b.reqs, "blob", "mat_plasteel", "Plasteel Sheet", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", "$icon_stone_door$", "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", "$icon_wooden_door$", "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 30);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ironladder", "$icon_ironladder$", "Iron Ladder\nAnyone can climb it like the regular ladder, but it's more durable.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", "$icon_trapblock$", "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "iron_door", "$icon_iron_door$", "Iron Door\nDoesn't have to be placed next to walls!");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 4);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "plasteel_door", "$icon_plasteel_door$", "Plasteel Door\nAn extremely durable plasteel door.\nDoesn't have to be placed next to walls!");
		AddRequirement(b.reqs, "blob", "mat_plasteel", "Plasteel Sheet", 8);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wood_triangle", "$wood_triangle$", "Wooden Triangle");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_triangle", "$stone_triangle$", "Stone Triangle");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "concrete_triangle", "$concrete_triangle$", "Concrete Triangle");
		AddRequirement(b.reqs, "blob", "mat_concrete", "Concrete", 4);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "iron_triangle", "$iron_triangle$", "Iron Triangle");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_halfblock", "$stone_halfblock$", "Stone Half Block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "iron_halfblock", "$iron_halfblock$", "Iron Half Block\nUnbreakable by peasants.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "iron_platform", "$icon_ironplatform$", "Iron Platform\nReinforced one-way platform. Unbreakable by peasants.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 3);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_kudzu, "kudzu", "$kudzu_block$", "Mostly decorative kudzu leaves \n ");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_goldingot, "goldingot", "$goldingot_block$", "Mostly decorative block made from gold ingots \n ");
		AddRequirement(b.reqs, "blob", "mat_goldingot", "Gold Ingots", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_mithrilingot, "mithrilingot", "$mithrilingot_block$", "Mostly decorative block made from mithril ingots \n ");
		AddRequirement(b.reqs, "blob", "mat_mithrilingot", "Mithril Ingots", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_copperingot, "copperingot", "$copperingot_block$", "Mostly decorative block made from copper ingots \n ");
		AddRequirement(b.reqs, "blob", "mat_copperingot", "Copper Ingots", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_steelingot, "steelingot", "$steelingot_block$", "Mostly decorative block made from steel ingots \n ");
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingots", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_ironingot, "ironingot", "$ironingot_block$", "Mostly decorative block made from iron ingots \n ");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 15);
		blocks[0].push_back(b);
	}
	// {
		// BuildBlock b(CMap::tile_tnt, "tnt_block", "$tnt_block$", "Explosives\nSet off by other explosions and fire.");
		// AddRequirement(b.reqs, "blob", "mat_dirt", "Dirt", 0);
		// blocks[0].push_back(b);
	// }
	// {
		// BuildBlock b(CMap::tile_brick_v0, "brick_block", "$brick_block$", "Bricks\nA cheap but durable wall.");
		// AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		// AddRequirement(b.reqs, "blob", "mat_dirt", "Dirt", 5);
		// blocks[0].push_back(b);
	// }
	// {
		// BuildBlock b(CMap::tile_sand, "sand_block", "$sand_block$", "dafuq");
		// // AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 2);
		// blocks[0].push_back(b);
	// }

	BuildBlock[] page_1;
	blocks.push_back(page_1);
	{
		BuildBlock b(0, "quarters", "$icon_quarters$", "Quarters\n" + descriptions[59]);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		// BuildBlock b(0, "buildershop", "$icon_buildershop$", "Builder Workshop\n" + descriptions[54] + "Slowly repairs surrounding tiles. \n\nCosts 5 Upkeep.");
		BuildBlock b(0, "buildershop", "$icon_buildershop$", "Builder Workshop\nConstruct several building utilities.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "tinkertable", "$icon_tinkertable$", "Mechanist's Workshop\nA place where you can construct various trinkets and advanced machinery.\n$GREEN$Repairs adjacent vehicles.$GREEN$\n");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 70);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		// AddRequirement(b.reqs, "blob", "bp_mechanist", "Blueprint (Mechanist's Workshop)", 1);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "armory", "$icon_armory$", "Armory\nA workshop where you can craft cheap equipment.\n$GREEN$Automatically stores nearby dropped weapons and armor.$GREEN$\n");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		// AddRequirement(b.reqs, "blob", "bp_mechanist", "Blueprint (Mechanist's Workshop)", 1);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "gunsmith", "$icon_gunsmith$", "Gunsmith's Workshop\nA workshop for those who enjoy making holes.\n$GREEN$Slowly produces ammunition.$GREEN$\n");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 250);
		// AddRequirement(b.reqs, "coin", "", "Coins", 75);
		// AddRequirement(b.reqs, "blob", "bp_mechanist", "Blueprint (Mechanist's Workshop)", 1);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "bombshop", "$icon_bombshop$", "Demolitionist's Workshop\nFor those with an explosive personality.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 250);
		// AddRequirement(b.reqs, "coin", "", "Coins", 50);
		// AddRequirement(b.reqs, "blob", "bp_mechanist", "Blueprint (Mechanist's Workshop)", 1);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "forge", "$icon_forge$", "Forge\nEnables you to process raw metals into pure ingots and alloys.\nThis is very wasteful of materials!");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 70);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "construction_yard", "$constructionyard$", "Construction Yard\nUsed to construct various vehicles.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		b.buildOnGround = true;
		b.size.Set(64, 56);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "storage", "$icon_storage$", "Storage\nA storage than can hold materials and items.\nCan be only accessed by the owner team.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "patreonshop", "$icon_patreonshop$", "Gift Shop\nA special souvenir shop for\nVamistorio's Patreon supporters.\n\nUsable by anyone once built.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		AddRequirement(b.reqs, "coin", "", "Coins", 500);
		AddRequirement(b.reqs, "seclev feature", "patreon", "Patreon", 1);
		b.buildOnGround = true;
		b.size.Set(40, 40);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "camp", "$icon_camp$", "Camp\nA basic faction base. Can be upgraded to gain\nspecial functions and more durability.\n\n$GREEN$Increases Upkeep cap by 1.$GREEN$\n");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 325);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 175);
		AddRequirement(b.reqs, "coin", "", "Coins", 100);
		b.buildOnGround = true;
		b.size.Set(80, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "nursery", "$icon_nursery$", "Nursery\nRaise plants and crops for various purposes.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		AddRequirement(b.reqs, "blob", "mat_dirt", "Dirt", 50);
		b.buildOnGround = true;
		b.size.Set(40, 32);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "library", "$icon_library$", "Library\nBuy and sell various blueprints, as well as info.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 125);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 250);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}

	BuildBlock[] page_2;
	blocks.push_back(page_2);
	{
		BuildBlock b(0, "conveyor", "$icon_conveyor$", "Conveyor Belt\nUsed to transport items.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 4);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 6);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "seperator", "$icon_separator$", "Separator\nItems matching the filter will be launched away.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "launcher", "$icon_launcher$", "Launcher\nLaunches items to the eternity and beyond.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "filter", "$icon_filter$", "Filter\nItems matching the filter won't collide with this.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "jumper", "$icon_jumper$", "Jumper\nItems that collide will be launched up.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "autoforge", "$icon_autoforge$", "Auto-Forge\nProcesses raw materials and alloys just for you. Has a chance for a double yield.\n$RED$Requires coal to produce steel.$RED$$mat_coal$\n");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "assembler", "$icon_assembler$", "Assembler\nAn elaborate piece of machinery that manufactures items.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		// AddRequirement(b.reqs, "blob", "bp_mechanist", "Blueprint (Mechanist's Workshop)", 1);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "drillrig", "$icon_drillrig$", "Driller Mole\nAn automatic drilling machine that mines resources underneath.");
		AddRequirement(b.reqs, "blob", "drill", "Drill", 1);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 5);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "hopper", "$icon_hopper$", "Hopper\nPicks up items lying on the ground.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 70);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "extractor", "$icon_extractor$", "Extractor\nGrabs items from nearby inventories.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		b.buildOnGround = true;
		b.size.Set(16, 32);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "filterextractor", "$icon_filterextractor$", "Filtered Extractor\nGrabs specific items from nearby inventories. Slightly slower than the regular extractor.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "grinder", "$icon_grinder$", "Grinder\nA dangerous machine capable of destroying almost everything.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 5);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "packer", "$icon_packer$", "Packer\nA safe machine capable of packing almost everything.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		b.buildOnGround = true;
		b.size.Set(24, 16);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "inserter", "$icon_inserter$", "Inserter\nTransfers items between inventories next to it.\nLarge funnel acts as input, small funnel as output.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "chickenassembler", "$icon_chickenassembler$", "UPF Assembly Line\nA reverse-engineered assembly line used to manufacture some of the UPF products.");
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 20);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 10);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 10);
		// AddRequirement(b.reqs, "tech", "tech_automation_advanced", "Technology (Advanced Automation)", 1);
		AddRequirement(b.reqs, "blob", "bp_automation_advanced", "Blueprint (Advanced Automation)", 1);
		b.buildOnGround = true;
		b.size.Set(56, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "chemlab", "$icon_chemlab$", "Chemical Production Machine\nA machine capable of manufacturing basic drugs and chemicals.");
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 20);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 10);
		AddRequirement(b.reqs, "blob", "mat_copperingot", "Copper Ingot", 40);
		AddRequirement(b.reqs, "blob", "bp_chemistry", "Blueprint (Chemistry)", 1);
		b.buildOnGround = true;
		b.size.Set(48, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "treecapitator", "$icon_treecapitator$", "Treecapitator\nMurders trees and stores their logs.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 70);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "inductionfurnace", "$icon_inductionfurnace$", "Industrial Furnace\nA heavy-duty furnace that produces up to 4x more ingots at cost of lower speed.\n$RED$Requires coal to smelt metal.$RED$$mat_coal$\n");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 60);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 20);
		// AddRequirement(b.reqs, "blob", "mat_battery", "Voltron Battery Plus", 50);
		b.buildOnGround = true;
		b.size.Set(40, 32);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "oiltank", "$icon_oiltank$", "Oil Tank\nAutomatically collects oil from all of your team's pumpjacks.");
		AddRequirement(b.reqs, "blob", "mat_wood","Wood", 250);
		AddRequirement(b.reqs, "blob", "mat_ironingot","Iron Ingot", 2);
		b.buildOnGround = true;
		b.size.Set(32, 16);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "stonepile", "$icon_stonepile$", "Stone Silo\nAutomatically collects ores from all of your team's mines.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 300);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		b.buildOnGround = true;
		b.size.Set(24, 40);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "compactor", "$icon_compactor$", "Compactor\nCan store enormous amounts of single resource.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 300);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "fetcher", "$icon_fetcher$", "Fetcher\nFetches specified item from inventories and ground.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "gastank", "$icon_gastank$", "Gas Tank\nAutomatically collects methane from all of your team's methane collectors");
		AddRequirement(b.reqs, "blob", "mat_ironingot","Iron Ingot", 15);
		b.buildOnGround = true;
		b.size.Set(16, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "smartstorage", "$icon_smartstorage$", "Smart Storage\nStores a lot of resources that are accessible via remote storage.");
		AddRequirement(b.reqs, "blob", "mat_copperingot", "Copper Ingot", 10);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 10);
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 5);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[2].push_back(b);
	}

	BuildBlock[] page_3;
	blocks.push_back(page_3);
	{
		BuildBlock b(0, "woodchest", "$icon_woodchest$", "Wooden Chest\nA regular wooden chest used for storage.\nCan be accessed by anyone.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "ironlocker", "$icon_ironlocker$", "Personal Locker\nA more secure way to store your items.\nCan be only accessed by the first person to claim it.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 5);
		// AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 1);
		b.buildOnGround = true;
		b.size.Set(16, 24);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "siren", "$icon_siren$", "Air Raid Siren\nWarns of incoming enemy aerial vehicles within 75 block radius.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		AddRequirement(b.reqs, "blob", "mat_goldingot", "Gold Ingot", 2);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "banner", "$icon_banner$", "Banner\nBanner to show off your team's color.");
		AddRequirement(b.reqs, "coin", "", "Coins", 150);
		b.size.Set(16, 32);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "beamtower", "$icon_beamtower$", " Solar Death Ray Tower\nSolar energy has never been so much fun!\n\nRequires Solar Death Ray Mirrors in order to function properly.");
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 20);
		AddRequirement(b.reqs, "blob", "mat_mithril", "Mithril", 100);
		AddRequirement(b.reqs, "blob", "mat_battery", "Battery", 100);
		AddRequirement(b.reqs, "coin", "", "Coins", 1000);
		AddRequirement(b.reqs, "blob", "bp_energetics", "Blueprint (Energetics)", 1);
		b.buildOnGround = true;
		b.size.Set(24, 96);
		blocks[3].push_back(b);
	}
	// {
		// BuildBlock b(0, "hedgehog", "$hedgehog$", "Hedgehog Barricade");
		// // AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		// // AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		// // b.buildOnGround = true;
		// // b.size.Set(16, 16);
		// blocks[3].push_back(b);
	// }
	{
		BuildBlock b(0, "shifter", "$shifter$", "Shifter\n Moves things in a set direction, has a cooldown.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "barbedwire", "$barbedwire$", "Barbed Wire\nHurts anyone who passes through it. Good at preventing people from climbing over walls.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		blocks[3].push_back(b);
	}

	
	// {
		// BuildBlock b(CMap::tile_tnt, "tnt_block", "$tnt_block$", "Explosives\nSet off by other explosions and fire.");
		// AddRequirement(b.reqs, "coin", "", "Coins", 50);
		// AddRequirement(b.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		// blocks[3].push_back(b);
	// }
	{
		BuildBlock b(0, "textsign", "$icon_textsign$", "Sign\nType '!write -text-' in chat and then use it on the sign. Writing on a piece of paper costs 50 coins.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		b.buildOnGround = true;
		b.size.Set(64, 16);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "smallsign", "$icon_smallsign$", "Sign\nType '!write -text-' in chat and then use it on the sign. Writing on a piece of paper costs 50 coins.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 60);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "teamlamp", "$icon_teamlamp$", "Team Lamp\nGlows with your team's spirit.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "industriallamp", "$icon_industriallamp$", "Industrial Lamp\nA sturdy lamp to ligthen up the mood in your factory.\nActs as a support block.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "lamppost", "$icon_lamppost$", "Lamp Post\nA fancy light.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 40);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		b.buildOnGround = true;
		b.size.Set(8, 24);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "ceilinglamp", "$icon_ceilinglamp$", "Ceiling Lamp\nIt's quite bright.\n\nCan be toggled by a Security Station.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 2);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "druglab", "$icon_druglab$", "Chemical Laboratory\nA laboratory used for production of chemicals, ranging from methane to various kinds of drugs.");
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 10);
		AddRequirement(b.reqs, "blob", "mat_copperingot", "Copper Ingot", 30);
		b.buildOnGround = true;
		b.size.Set(32, 40);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "altar", "$icon_altar$", "Altar\nWorship your idols here. Needs to be carved first.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 2000);
		AddRequirement(b.reqs, "coin", "", "Coins", 250);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "1x5blastdoor", "$icon_1x5blastdoor$", "Blast Door\nA large heavy blast door.\n\nCan be only opened by a Security Station.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 35);
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 20);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 5);
		// b.buildOnGround = true;
		b.size.Set(8, 40);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "beamtowermirror", "$icon_beamtowermirror$", "Solar Death Ray Mirror\nAim this at the Solar Death Ray Tower.");
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 5);
		AddRequirement(b.reqs, "coin", "", "Coins", 250);
		b.buildOnGround = true;
		b.size.Set(16, 24);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "mithrilreactor", "$icon_mithrilreactor$", "Mithril Reactor\nA small reactor used for mithril enrichment and synthesis using gold.\nBecomes more stable when submerged in deep water.\n$mat_gold$$DEFEND_RIGHT$$mat_mithril_10x$$DEFEND_RIGHT$$mat_mithrilenriched_10x$\n\n$RED$Careless usage may result in\nan irradiated crater.$RED$\n");
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 20);
		AddRequirement(b.reqs, "blob", "mat_mithril", "Mithril", 100);
		AddRequirement(b.reqs, "blob", "mat_mithrilingot", "Mithril Ingot", 5);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "securitystation", "$icon_securitystation$", "Security Station\nProvides remote control and linking of various security devices, such as blast doors and turrets.\n\nCreates a unique Security Card upon construction, which can be used to limit  control of devices exclusively to this machine.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 20);
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 10);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 20);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "metaldetector", "$icon_metaldetector$", "Danger Detector\nScans people passing through it for dangerous items, such as weapons, explosives or ill-tempered animals.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 8);
		AddRequirement(b.reqs, "blob", "mat_mithrilingot", "Mithril Ingot", 1);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[3].push_back(b);
	}
	{	
		BuildBlock b(0, "fireplace", "$fireplace$", "Campfire\nCan be used to cook various foods.");
		AddRequirement(b.reqs, "blob", "lantern", "Lantern", 1);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200); //This is more expensive than for peasants as the fireplace is an amazing lightsource better than most other lightsources
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[3].push_back(b);
    }
	{
		BuildBlock b(0, "tavern", "$icon_tavern$", "Tavern\nA poorly built cozy tavern.\nNeutrals may set their team here, paying you 20 coins for each spawn.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 350);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		b.buildOnGround = true;
		b.size.Set(56, 32);
		blocks[3].push_back(b);
	}

	// {
		// BuildBlock b(0, "barricade", "$icon_barricade$", "Barricade\neee");
		// AddRequirement(b.reqs, "blob", "mat_concrete", "Concrete", 100);
		// AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 10);
		// b.size.Set(8, 24);
		// blocks[3].push_back(b);
	// }
	// {
		// BuildBlock b(0, "floater", "$icon_floater$", "Floater\nActs as a supporting structure - useful for sky islands and bridges.");
		// // AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		// // AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		// blocks[2].push_back(b);
	// }

	// BuildBlock[] page_4;
	// blocks.push_back(page_4);
	// {
		// BuildBlock b(0, "wire", "$wire$", "Wire");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "elbow", "$elbow$", "Elbow");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 2);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "tee", "$tee$", "Tee");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 3);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "junction", "$junction$", "Junction");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 4);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "diode", "$diode$", "Diode");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 2);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "resistor", "$resistor$", "Resistor");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 2);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "inverter", "$inverter$", "Inverter");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 2);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 4);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "transistor", "$transistor$", "Transistor");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 4);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "toggle", "$toggle$", "Toggle");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 4);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 4);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "lever", "$lever$", "Lever");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		// AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		// AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "push_button", "$pushbutton$", "Button");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		// AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		// AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		// AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 4);
		// AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "lamp", "$lamp$", "Lamp");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 2);
		// AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "emitter", "$emitter$", "Emitter");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 8);
		// AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		// blocks[4].push_back(b);
	// }
	// {
		// BuildBlock b(0, "receiver", "$receiver$", "Receiver");
		// AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 8);
		// AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		// blocks[4].push_back(b);
	// }
}
