// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

Random traderRandom(Time());

const SColor[] colors = 
{
	SColor(255, 255, 50, 50),
	SColor(255, 50, 255, 50),
	SColor(255, 50, 50, 255)
};

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("upkeep building");
	this.set_u8("upkeep cap increase", 0);
	this.set_u8("upkeep cost", 5);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 5;
	
	this.SetLight(true);
	this.SetLightRadius(64.00f);
	this.SetLightColor(SColor(255, 255, 50, 255));
	
	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	this.set_Vec2f("shop offset", Vec2f(0, 4));
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", "Gift Shop");
	this.set_u8("shop icon", 15);
	
	{
		ShopItem@ s = addShopItem(this, "Comfy Sofa", "$icon_sofa$", "sofa", "An extremely comfortable sofa made of genuine badger leather.");
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Emperor's Crown", "$icon_crown$", "crown", "A Emperor's Crown fit for a true emperor.");
		AddRequirement(s.requirements, "coin", "", "Coins", 15000);
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 50);
		
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Emperor's Throne", "$icon_throne$", "throne", "An Emperor's Throne fit for true emperor's bottom.");
		AddRequirement(s.requirements, "coin", "", "Coins", 5000);
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 500);
		
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Noisemaker 9000", "$icon_noisemaker$", "noisemaker", "A terrible device invented by some lunatic.");
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		AddRequirement(s.requirements, "blob", "klaxon", "Klaxon", 2);
		
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Badger Statue", "$icon_badgerstatue$", "badgerstatue", "A masterwork sculpture depicting a badger.\n\n...or a bear.");
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Pigeon Statue", "$icon_pigeonstatue$", "pigeonstatue", "A masterwork sculpture depicting a pigeon\n\n...or an eagle.");
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
	
	
	// {
		// ShopItem@ s = addShopItem(this, "Truncheon", "$icon_nightstick$", "nightstick", "A traditional tool used by seal clubbing clubs.");
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		// AddRequirement(s.requirements, "coin", "", "Coins", 75);
		
		// s.customButton = true;
		// s.buttonwidth = 1;
		// s.buttonheight = 1;
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Slavemaster's Kit", "$icon_shackles$", "shackles", "A kit containing shackles, shiny iron ball, elegant striped pants, noisy chains and a slice of cheese.");
		// AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4);
		// AddRequirement(s.requirements, "coin", "", "Coins", 100);
		
		// s.customButton = true;
		// s.buttonwidth = 1;
		// s.buttonheight = 1;
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Water Bomb (1)", "$waterbomb$", "mat_waterbombs-1", descriptions[52], true);
		// AddRequirement(s.requirements, "coin", "", "Coins", 30);
		
		// s.spawnNothing = true;
	// }	
	// {
		// ShopItem@ s = addShopItem(this, "Water Arrow (2)", "$mat_waterarrows$", "mat_waterarrows-2", descriptions[50], true);
		// AddRequirement(s.requirements, "coin", "", "Coins", 20);
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Fire Arrow (2)", "$mat_firearrows$", "mat_firearrows-2", descriptions[32], true);
		// AddRequirement(s.requirements, "coin", "", "Coins", 30);
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Combat Helmet", "$icon_militaryhelmet$", "militaryhelmet", "A heavy combat helmet.\nCan absorb up to 20 points of damage.\n\nOccupies the Head slot");
		// AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 1);
		// AddRequirement(s.requirements, "coin", "", "Coins", 50);
		
		// s.customButton = true;
		// s.buttonwidth = 1;
		// s.buttonheight = 1;
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Ballistic Vest", "$icon_bulletproofvest$", "bulletproofvest", "A resilient ballistic armor.\nCan absorb up to 25 points of damage.\n\nOccupies the Torso slot");
		// AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 2);
		// AddRequirement(s.requirements, "coin", "", "Coins", 100);
		
		// s.customButton = true;
		// s.buttonwidth = 1;
		// s.buttonheight = 1;
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Combat Boots", "$icon_combatboots$", "combatboots", "A pair of sturdy boots.\nCan absorb up to 10 points of damage.\nIncreases running speed.\nIncreases stomp damage.\n\nOccupies the Boots slot");
		// AddRequirement(s.requirements, "coin", "", "Coins", 50);
		
		// s.customButton = true;
		// s.buttonwidth = 1;
		// s.buttonheight = 1;
		
		// s.spawnNothing = true;
	// }
}

void onTick(CBlob@ this)
{
	// SColor color = colors[XORRandom(colors.length)];	
	// this.SetLight(true);
	// this.SetLightRadius(64.00f);
	// this.SetLightColor(color);
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
				
				if (blob is null && callerBlob is null) return;
			   
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