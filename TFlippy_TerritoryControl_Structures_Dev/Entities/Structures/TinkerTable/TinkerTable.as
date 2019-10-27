// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

#include "MakeMat.as";
#include "TCTechs.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("upkeep building");
	this.set_u8("upkeep cap increase", 0);
	this.set_u8("upkeep cost", 5);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 150;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(5, 8));
	this.set_string("shop description", "Mechanist's Workshop");
	this.set_u8("shop icon", 15);

	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", descriptions[43], false);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gramophone", "$gramophone$", "gramophone", "A device used to play music from Gramophone Records purchased at the Merchant.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 1);
		s.spawnNothing = false;
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", descriptions[12], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);

		s.spawnNothing = true;
	}
	// {
		// ShopItem@ s = addShopItem(this, "Giga Drill Breaker", "$powerdrill$", "powerdrill", "A huge overpowered drill with a durable mithril head.");
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 2);
		// AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 2);

		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Contrabass", "$contrabass$", "contrabass", "A musical instrument for the finest bards.");
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 60);
		// AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 1);
		// s.spawnNothing = false;
	// }
	{
		ShopItem@ s = addShopItem(this, "Copper Wire (2)", "$mat_copperwire$", "mat_copperwire-2", "A copper wire. Kids' favourite toy.");
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Clown's Funny Klaxon", "$icon_klaxon$", "klaxon", "An infernal device housing thousands of lamenting souls.");
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 666);
		s.spawnNothing = true;
	}
	/*{
		ShopItem@ s = addShopItem(this, "Autonomous Activator", "$icon_automat$", "automat", "A fish-operated contraption that uses anything in its tiny hands. May be only carried around when not holding anything.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 3);
		AddRequirement(s.requirements, "blob", "fishy", "Fishy", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 350);
		s.spawnNothing = true;
	}*/
	{
		ShopItem@ s = addShopItem(this, "Zapthrottle Gas Extractor", "$icon_gasextractor$", "gasextractor", "A handheld air pump commonly used for cleaning, martial arts and gas cloud extraction.\n\nLeft mouse: Pull\nRight mouse: Push");
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 2);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Mustard Gas", "$icon_mustard$", "mat_mustard-50", "A bottle of a highly poisonous gas. Causes blisters, blindness and lung damage.");
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Scuba Gear", "$icon_scubagear$", "scubagear", "Special equipment used for scuba diving.");
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 1);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Mithril-B-Gone", "$icon_radpill$", "radpill", "A piece of medicine that gives you a partial immunity to the adverse effects of Mithril.\nIt's a suppository!");
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril", 25);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Handheld Irradiator", "$icon_raygun$", "raygun", "A rather dangerous mithril-powered device used for cancer research.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 3);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Rocket Pack", "$icon_jetpack$", "jetpack", "A small rocket-propelled backpack.\nOccupies the Torso slot.\nPress Space to jump!");
		AddRequirement(s.requirements, "blob", "mat_smallrocket", "Small Rocket", 2);
		AddRequirement(s.requirements, "blob", "mat_oil", "Oil", 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Flippers", "$icon_flippers$", "flippers", "Cool flippers made of a fishy.");
		AddRequirement(s.requirements, "blob", "fishy", "Fishy", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Miner's Helmet", "$icon_minershelmet$", "minershelmet", "Turns you into an illuminati miner.");
		AddRequirement(s.requirements, "blob", "lantern", "Lantern", 1);
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Flashlight", "$icon_flashlight$", "flashlight", "Miraculous light in a tube! Illuminates the area it's pointing at.");
		AddRequirement(s.requirements, "blob", "lantern", "Lantern", 1);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Backpack", "$icon_backpack$", "backpack", "A large leather backpack that can be equipped and used as an inventory.\nOccupies the Torso slot");
		AddRequirement(s.requirements, "coin", "", "Coins", 150);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Binoculars", "$icon_binoculars$", "binoculars", "Two telescopes glued together used for spying neighbours.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		// AddRequirement(s.requirements, "tech", "tech_metallurgy", "Metallurgy", 1);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Hazmat Suit", "$icon_hazmat$", "hazmatitem", "A hazardous materials suit giving the wearer protection against fire, toxic gases, radiation and drowning.");
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril", 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Mouse Trap", "$icon_mousetrap$", "mousetrap", "An intricate device used for capturing of oversized mice.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 400);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Musical Contrabass", "$icon_contrabass$", "contrabass", "An advanced contrabass capable of emitting sounds of multiple instruments.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		
		// AddRequirement(s.requirements, "tech", "tech_test", "Test", 1);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Dart Gun", "$icon_dartgun$", "dartgun", "Dart Gun that can be used to remotely deliver drugs.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 6);
		AddRequirement(s.requirements, "blob", "mat_methane", "Methane", 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gauss Rifle", "$icon_gaussrifle$", "gaussrifle", "A modified toy used to kill people.\n\nUses Steel Ingots.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 10);
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril", 50);
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 10);
		AddRequirement(s.requirements, "coin", "", "Coins", 850);


		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Scorcher", "$icon_flamethrower$", "flamethrower", "A tool used for incinerating plants, buildings and people.\n\nUses Oil.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Blazethrower", "$icon_blazethrower$", "blazethrower", "A Scorcher modification providing support for gaseous fuels.\n\nUses Fuel.");
		AddRequirement(s.requirements, "blob", "flamethrower", "Scorcher", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 1000);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Accelerated Gyromat Core Replacement", "$icon_gyromat$", "gyromat", "Replace this Accelerated Gyromat's core in hope to improve it.");
		AddRequirement(s.requirements, "blob", "gyromat", "Gyromat", 1);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 20);
		AddRequirement(s.requirements, "coin", "", "Coins", 400);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Acidthrower", "$icon_acidthrower$", "acidthrower", "A tool used for dissolving plants, buildings and people.\n\nUses Acid.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 10);
		AddRequirement(s.requirements, "coin", "", "Coins", 1250);


		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	// {
		// ShopItem@ s = addShopItem(this, "Firework (1)", "$icon_firework$", "firework", "Celebrate the new year with this colorful rocket!");
		// AddRequirement(s.requirements, "coin", "", "Coins", 50);

		// s.spawnNothing = true;
	// }

	// {
		// ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", descriptions[12], false);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		// AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);

		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", descriptions[9], false);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);

		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", descriptions[36], false);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);

		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", descriptions[53], false);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);

		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", descriptions[30], false);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);

		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Arrows (30)", "$mat_arrows$", "mat_arrows-30", descriptions[2], true);
		// AddRequirement(s.requirements, "coin", "", "Coins", 15);

		// s.spawnNothing = true;
	// }
}

void onTick(CBlob@ this)
{
	CBlob@[] blobs;
	// if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 128.0f, @blobs))
	if (getMap().getBlobsInBox(this.getPosition() + Vec2f(96, 64), this.getPosition() + Vec2f(-96, 0), @blobs))
	{
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];

			// print(blob.getName() + "; " + blob.hasTag("vehicle"));

			if (blob.hasTag("vehicle"))
			{
				if (blob.getHealth() < blob.getInitialHealth()) blob.server_Heal(4);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

	this.set_Vec2f("shop offset", Vec2f(2,0));

	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ConstructShort");

		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		if (callerBlob is null) return;

		if (isServer())
		{
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				MakeMat(callerBlob, this.getPosition(), spl[0], parseInt(spl[1]));

				// CBlob@ mat = server_CreateBlob(spl[0]);

				// if (mat !is null)
				// {
					// mat.Tag("do not set materials");
					// mat.server_SetQuantity(parseInt(spl[1]));
					// if (!callerBlob.server_PutInInventory(mat))
					// {
						// mat.setPosition(callerBlob.getPosition());
					// }
				// }
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (blob is null) return;

				if (callerBlob.getPlayer() !is null ) blob.SetDamageOwnerPlayer(callerBlob.getPlayer());
				
				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
}
