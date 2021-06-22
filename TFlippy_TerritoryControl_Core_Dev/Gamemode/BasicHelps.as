#include "Help.as"

#define CLIENT_ONLY

void onInit(CRules@ this)
{
	// knight
	AddIconToken("$Bomb$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16, 32), 0);
	AddIconToken("$WaterBomb$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16, 32), 2);
	AddIconToken("$Satchel$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16, 32), 3);
	AddIconToken("$Keg$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16, 32), 4);
	AddIconToken("$Help_Bomb1$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8, 16), 30);
	AddIconToken("$Help_Bomb2$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8, 16), 31);
	AddIconToken("$Swap$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 7);
	AddIconToken("$Jab$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 20);
	AddIconToken("$Slash$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 21);
	AddIconToken("$Shield$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 22);
	// archer
	AddIconToken("$Arrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16, 32), 0);
	AddIconToken("$WaterArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16, 32), 1);
	AddIconToken("$FireArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16, 32), 2);
	AddIconToken("$BombArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16, 32), 3);
	AddIconToken("$Daggar$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 10);
	AddIconToken("$Help_Arrow1$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8, 16), 28);
	AddIconToken("$Help_Arrow2$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8, 16), 29);
	AddIconToken("$Swap$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 7);
	AddIconToken("$Grapple$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 16);
	// builder
	AddIconToken("$Build$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 11);
	AddIconToken("$Pick$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 12);
	AddIconToken("$Rotate$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 5);
	AddIconToken("$Help_Block1$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8, 16), 12);
	AddIconToken("$Help_Block2$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8, 16), 13);
	AddIconToken("$Swap$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 7);
	AddIconToken("$BlockStone$", "Sprites/world.png", Vec2f(8, 8), 96);

	AddIconToken("$workshop$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16, 16), 2);

	// Materials
	AddIconToken("$mat_copperingot$", "Material_CopperIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_ironingot$", "Material_IronIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_steelingot$", "Material_SteelIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_mithrilingot$", "Material_MithrilIngot.png", Vec2f(16, 16), 1);
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	if (!u_showtutorial)
		return;

	const string name = blob.getName();

	if (name == "ruins")
	{
		SetHelp(blob, "help ruins peasants", "", "Ruins serve as respawn points for peasants.\nIf a Faction Base is built nearby, spawning for this Ruin will be disabled.", "", 5);
	}
	else if (name == "peasant")
	{
		SetHelp(blob, "help peasant faction", "", "Peasants can create factions by pressing $KEY_F$ \nand selecting Found a Faction.", "", 3);
		SetHelp(blob, "help peasant tc", "", "Territory Control's world is a cruel place. You may end up getting shot, slaved, stabbed,\nblown up, turned into a monster and such.\n\nIf you're a beginner, consider joining an existing faction by asking one of its members to join.", "", 3);
	}
	else if (name == "coalmine")
	{
		SetHelp(blob, "help coalmine", "", "Coal Mines can be used to quickly move across the map \n and produce extra resources for factions.", "", 3);
	}
	else if (name == "pumpjack")
	{
		SetHelp(blob, "help pumpjack", "", "Pumpjacks produce valuable Oil\nthat can be sold to Merchants, thrown or used as fuel.", "", 3);
	}
	else if (name == "merchant")
	{
		SetHelp(blob, "help merchant", "", "Merchants are eager to buy your stuff.\nAs a Peasant, you can also purchase \"Building for Dummies\",\nwhich enables you to build more advanced structures.\nFactions gain passive income by capturing a Merchant.", "", 3);
	}
	else if (name == "witchshack")
	{
		SetHelp(blob, "help witch", "", "Witches sell various trinkets and are capable of processing mithril.\nFactions gain passive health regeneration by capturing a Witch Shack.", "", 3);
	}
	else if (name == "mat_mithril" || name == "mat_mithrilenriched")
	{
		SetHelp(blob, "help mithril", "", "$mat_mithril$ Mithril is a dangerous radioactive mutagen.\n         Stay away from it unless you have adequate protection!", "", 3);
	}
	else if (name == "grinder")
	{
		SetHelp(blob, "help grinder", "", "Grinders can be used to process stone\ninto valuable ores and concrete.", "", 3);
	}
	else if (name == "banditshack")
	{
		SetHelp(blob, "help banditshack", "", "Bandit Shacks allow you to turn\ninto a more dangerous bandit.", "", 3);
	}
	else if (name == "slave")
	{
		SetHelp(blob, "help slave", "", "Slaves can be used for forced labor or imprisonment.\n\nIn case you are the slave, you have those options:\n1. Work for your captors and possibly earn freedom\n2. Try to kill your captors\n3. Break your slave ball and run away\n5. Get your hands on \"Building for Dummies\"\n5. Ask to be let free", "", 3);
	}

	if (blob.hasTag("seats"))
	{
		SetHelp(blob, "help hop", "", "$KEY_S$ Hop inside", "", 5);
		if (name == "triplane" || name == "helichopper") SetHelp(blob, "help hop out triplane", "", "$KEY_C$ Get out", "", 4);
		else SetHelp(blob, "help hop out bomber", "", "$KEY_C$ Get out$", "", 4);
	}

	if (blob.hasTag("faction_base"))
	{
		SetHelp(blob, "help faction base", "", "Factions offer you and your teammates\nextra protection and technology.\nRemember to build Quarters to raise your upkeep limit!", "", 3);
	}

	if (blob.hasTag("weapon"))
	{
		SetHelp(blob, "help gun", "", "Most guns require ammunition that\ncan be purchased at Gunsmith's Workshop.", "", 3);
	}

	// else if (name == "rain")
	// {
		// SetHelp(blob, "help rain", "", "Rain will moderately slow down your movement\nand promote verdancy and growth.", "", 3);
	// }

	// if (blob.hasTag("door"))
	// {
		// SetHelp(blob, "help rotate", "", "$" + blob.getName() + "$" + " $Rotate$ Rotate    $KEY_SPACE$", "", 3);
	// }

	// if (name == "hall")
	// {
		// SetHelp(blob, "help use", "", "$CLASSCHANGE$ Change class    $KEY_E$", "", 5);
	// }
	// else if (name == "trap_block")
	// {
		// SetHelp(blob, "help show", "builder", "$trap_block$ Opens on enemy", "", 15);
	// }
	// else if (name == "spikes")
	// {
		// SetHelp(blob, "help show", "builder", "$spikes$ Retracts on enemy if on stone $STONE$", "", 20);
	// }
	// else if (name == "lantern")
	// {
		// SetHelp(blob, "help activate", "", "$lantern$ On/Off     $KEY_SPACE$", "");
		// SetHelp(blob, "help pickup", "", "$lantern$ Pick up    $KEY_C$");
	// }
	// else if (name == "catapult" || name == "ballista")
	// {
		// SetHelp(blob, "help DRIVER movement", "", "$" + blob.getName() + "$" + "Drive     $KEY_A$ $KEY_S$ $KEY_D$", "", 3);
		// SetHelp(blob, "help GUNNER action", "", "$" + blob.getName() + "$" + "FIRE     $KEY_HOLD$$LMB$", "", 3);
	// }
	// else if (name == "mounted_bow")
	// {
		// SetHelp(blob, "help GUNNER action", "", "$" + blob.getName() + "$" + "FIRE     $LMB$", "", 3);
	// }
	// else if (name == "food")
	// {
		// SetHelp(blob, "help switch", "", "$food$Take out food  $KEY_HOLD$$KEY_F$", "", 3);
	// }
	// else if (name == "boulder")
	// {
		// SetHelp(blob, "help pickup", "", "$boulder$ Pick up    $KEY_C$");
	// }
	// else if (name == "building")
	// {
		// SetHelp(blob, "help use", "", "$building$Construct    $KEY_E$", "", 3);
	// }
	// else if (name == "archershop" || name == "boatshop" || name == "knightshop" || name == "buildershop" || name == "vehicleshop")
	// {
		// SetHelp(blob, "help use", "", "$building$Use    $KEY_E$", "", 3);
	// }
	//else if (name == "ctf_flag")
	//{
	//	SetHelp( blob, "help use", "", "$$ctf_flag$ Bring enemy flag to capture", "", 3 );
	//}
}
