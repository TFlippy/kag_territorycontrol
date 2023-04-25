#include "BuildBlock.as";
#include "Requirements.as";
#include "Descriptions.as";
#include "CustomBlocks.as";
#include "CommonBuilderBlocks.as";

void addCommonEngineerBlocks(BuildBlock[][]@ blocks, int teamnum = 7)
{
	addCommonBuilderBlocks(blocks, teamnum);

	
	BuildBlock[] automation;
	{
		AddIconToken("$icon_conveyor$", "Conveyor.png", Vec2f(8, 8), 0, teamnum);
		BuildBlock b(0, "conveyor", "$icon_conveyor$", "Conveyor Belt:\n\nUsed to transport items.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 4);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 6);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_filter$", "Filter.png", Vec2f(8, 8), 0, teamnum);
		BuildBlock b(0, "filter", "$icon_filter$", "Filter:\n\n$blue$Filtered$blue$ items will be ejected downwards.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_climber$", "Climber.png", Vec2f(8, 8), 5, teamnum);
		BuildBlock b(0, "climber", "$icon_climber$", "Climber:\n\nPulls items upwards.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 4);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 6);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_separator$", "Seperator.png", Vec2f(8, 8), 5, teamnum);
		BuildBlock b(0, "seperator", "$icon_separator$", "Separator:\n\n$blue$Filtered$blue$ items are pulled upward.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_jumper$", "Jumper.png", Vec2f(8, 16), 0, teamnum);
		BuildBlock b(0, "jumper", "$icon_jumper$", "Jumper:\n\n$blue$Filtered$blue$ items will be launched straight up.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_launcher$", "Launcher.png", Vec2f(8, 8), 0, teamnum);
		BuildBlock b(0, "launcher", "$icon_launcher$", "Launcher:\n\nLaunches items to the eternity and beyond.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_extractor$", "AutomationIcons.png", Vec2f(24, 48), 0);
		BuildBlock b(0, "extractor", "$icon_extractor$", "Extractor:\n\nGrabs $blue$filtered$blue$ items from nearby inventories.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_fetcher$", "AutomationIcons.png", Vec2f(24, 48), 1, teamnum);
		BuildBlock b(0, "fetcher", "$icon_fetcher$", "Fetcher:\n\nFetches $blue$specified$blue$ item from remote storages.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_stonepile$", "StonePile.png", Vec2f(24, 40), 3, teamnum);
		BuildBlock b(0, "stonepile", "$icon_stonepile$", "Mining Silo:\n\nAutomatically collects ores from all of your team's mines.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 300);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_compactor$", "Compactor.png", Vec2f(24, 32), 0, teamnum);
		BuildBlock b(0, "compactor", "$icon_compactor$", "Compactor:\n\nCan store enormous amounts of single resource.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 300);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_gastank$","GasTank.png",Vec2f(16, 40), 0, teamnum);
		BuildBlock b(0, "gastank", "$icon_gastank$", "Gas Tank:\n\nAutomatically collects methane from all of your team's methane collectors");
		AddRequirement(b.reqs, "blob", "mat_ironingot","Iron Ingot", 15);
		b.buildOnGround = true;
		b.size.Set(16, 40);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_oiltank$","OilTank.png",Vec2f(24, 40), 0, teamnum);
		BuildBlock b(0, "oiltank", "$icon_oiltank$", "Oil Tank:\n\nAutomatically collects oil from all of your team's pumpjacks.");
		AddRequirement(b.reqs, "blob", "mat_wood","Wood", 250);
		AddRequirement(b.reqs, "blob", "mat_ironingot","Iron Ingot", 2);
		b.buildOnGround = true;
		b.size.Set(24, 40);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_industrialsmelter$", "IndustrialSmelterIcon.png", Vec2f(19, 30), 0, teamnum);
		BuildBlock b(0, "industrialsmelter", "$icon_industrialsmelter$", "Industrial Smelter:\n\nA large quantity smelter that produces 4x the amount of ingots.\n\n$orange$Requires$mat_coal$and$mat_ironingot$to produce steel$mat_steelingot$.$orange$\n");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 400);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
        AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 40);
		b.buildOnGround = true;
		b.size.Set(40, 40);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_inductionfurnace$", "InductionFurnace.png", Vec2f(40, 32), 0, teamnum);
		BuildBlock b(0, "inductionfurnace", "$icon_inductionfurnace$", "Induction Furnace:\n\nA heavy-duty furnace that produces 5x more ingots at cost of lower speed.\n\n$orange$Requires$mat_oil$and$mat_ironingot$to produce steel$mat_steelingot$.$orange$\n");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 60);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 20);
		AddRequirement(b.reqs, "tech", "bp_induction", "Induction", 1);
		b.buildOnGround = true;
		b.size.Set(40, 32);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_assembler$", "Assembler.png", Vec2f(32, 24), 0, teamnum);
		BuildBlock b(0, "assembler", "$icon_assembler$", "Assembler:\n\nAn elaborate piece of machinery that manufactures items.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		b.buildOnGround = true;
		b.size.Set(32, 24);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_mini_assembler$", "MiniAssembler.png", Vec2f(24, 18), 0, teamnum);
		BuildBlock b(0, "miniassembler", "$icon_mini_assembler$", "Mini-Assembler:\n\nAn elaborate piece of machinery that manufactures items.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		b.buildOnGround = true;
		b.size.Set(24, 16);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_grinder$", "OldGrinder.png", Vec2f(40, 24), 0, teamnum);
		BuildBlock b(0, "grinder_old", "$icon_grinder$", "Grinder:\n\nA dangerous machine capable of destroying almost everything.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 5);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_mini_grinder$", "AutomationIcons.png", Vec2f(24, 24), 2, teamnum);
		BuildBlock b(0, "grinder", "$icon_mini_grinder$", "Mini-Grinder:\n\nA dangerous machine capable of destroying almost everything.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 5);
		b.buildOnGround = true;
		b.size.Set(32, 16);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_grabber$", "Grabber.png", Vec2f(24, 24), 1, teamnum);
		BuildBlock b(0, "grabber", "$icon_grabber$", "Grabber:\n\nGrabs $blue$specified$blue$ item from the floor or nearby storages.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_hoppacker$", "Hoppacker.png", Vec2f(24, 24), 0, teamnum);
		BuildBlock b(0, "hoppacker", "$icon_hoppacker$", "Hoppacker:\n\nA safe machine capable of storing and packing items into a crate.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		b.buildOnGround = true;
		b.size.Set(24, 16);
		automation.push_back(b);
	}
	
	/*{
		AddIconToken("$icon_filterextractor$", "FilterExtractor.png", Vec2f(24, 24), 0, teamnum);
		BuildBlock b(0, "filterextractor", "$icon_filterextractor$", "Filtered Extractor:\n\nGrabs specific items from nearby inventories. Slightly slower than the regular extractor.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		automation.push_back(b);
	}*/
	/*
	{
		AddIconToken("$icon_hopper$", "Hopper.png", Vec2f(24, 24), 0, teamnum);
		BuildBlock b(0, "hopper", "$icon_hopper$", "Hopper:\n\nPicks up items lying on the ground.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_packer$", "Packer.png", Vec2f(24, 16), 0, teamnum);
		BuildBlock b(0, "packer", "$icon_packer$", "Packer:\n\nA safe machine capable of packing almost everything.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		b.buildOnGround = true;
		b.size.Set(24, 16);
		automation.push_back(b);
	}
	*/
	{
		AddIconToken("$icon_inserter$", "Inserter.png", Vec2f(16, 16), 0);
		BuildBlock b(0, "inserter", "$icon_inserter$", "Inserter:\n\nTransfers items between inventories next to it.\nLarge funnel acts as input, small funnel as output.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_chickenassembler$", "ChickenAssembler.png", Vec2f(56, 24), 0, teamnum);
		BuildBlock b(0, "chickenassembler", "$icon_chickenassembler$", "UPF Assembly Line:\n\nA reverse-engineered assembly line used to manufacture some of the UPF products.");
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 20);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 10);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 10);
		// AddRequirement(b.reqs, "tech", "tech_automation_advanced", "Technology (Advanced Automation)", 1);
		AddRequirement(b.reqs, "tech", "bp_automation", "Advanced Automation", 1);
		b.buildOnGround = true;
		b.size.Set(56, 24);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_chemlab$","ChemLab.png",Vec2f(48, 24), 0, teamnum);
		BuildBlock b(0, "chemlab", "$icon_chemlab$", "Chemical Production Machine:\n\nA machine capable of manufacturing basic drugs and chemicals.");
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 20);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 10);
		AddRequirement(b.reqs, "blob", "mat_copperingot", "Copper Ingot", 40);
		AddRequirement(b.reqs, "tech", "bp_chemistry", "Chemistry", 1);
		b.buildOnGround = true;
		b.size.Set(48, 24);
		automation.push_back(b);
	}
    {
		BuildBlock b(0, "drillrig", "$icon_drillrig$", "Driller Mole:\n\nAn automatic drilling machine that mines resources underneath.");
		AddRequirement(b.reqs, "blob", "drill", "Drill", 1);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		automation.push_back(b);
	}
	{
		AddIconToken("$icon_treecapitator$", "Treecapitator.png", Vec2f(24, 8), 0);
		BuildBlock b(0, "treecapitator", "$icon_treecapitator$", "Treecapitator:\n\nMurders trees and stores their logs.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 70);
		automation.push_back(b);
	}
	{
		BuildBlock b(0, "mithrilreactor", "$icon_mithrilreactor$", "Mithril Reactor:\n\nA small reactor used for mithril enrichment and synthesis using gold.\nBecomes more stable when submerged in deep water.\n$mat_gold$$DEFEND_RIGHT$$mat_mithril_10x$$DEFEND_RIGHT$$mat_mithrilenriched_10x$\n\n$RED$Careless usage may result in\nan irradiated crater.$RED$\n");
		AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 20);
		AddRequirement(b.reqs, "blob", "mat_mithril", "Mithril", 100);
		AddRequirement(b.reqs, "blob", "mat_mithrilingot", "Mithril Ingot", 5);
		AddRequirement(b.reqs, "tech", "bp_enrichment", "Enrichment", 1);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		automation.push_back(b);
	}
	blocks.push_back(automation);
	
	print('got here?'+blocks.length());
}