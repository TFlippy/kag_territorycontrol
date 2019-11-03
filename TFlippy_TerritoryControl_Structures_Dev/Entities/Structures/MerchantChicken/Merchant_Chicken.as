// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "MakeSeed.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.Tag("upkeep building");
	this.set_u8("upkeep cap increase", 30);
	this.set_u8("upkeep cost", 0);

	this.Tag("invincible");
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	this.Tag("change team on fort capture");
	
	getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);

	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 6, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);
	
	AddIconToken("$bp_mechanist$", "Blueprints.png", Vec2f(16, 16), 2);
	AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$musicdisc$", "MusicDisc.png", Vec2f(8, 8), 0);
	AddIconToken("$seed$", "Seed.png",Vec2f(8,8),0);
	AddIconToken("$icon_cake$", "Cake.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_car$", "Icon_Car.png", Vec2f(16, 8), 0);
	AddIconToken("$foodcan$", "FoodCan.png", Vec2f(16, 16), 0);
	
	this.getCurrentScript().tickFrequency = 30 * 3;
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 8));
	this.set_Vec2f("shop menu size", Vec2f(4,4));
	this.set_string("shop description", "Chicken Store");
	this.set_u8("shop icon", 25);
	
	// {
		// ShopItem@ s = addShopItem(this, "Sell Grain (1)", "$COIN$", "coin-40", "Sell 1 Grain for 40 coins.");
		// AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
		// s.spawnNothing = true;
	// }
	
	

	{
		ShopItem@ s = addShopItem(this, "Buy Gold Ingot (1)", "$mat_goldingot$", "mat_goldingot-1", "Buy 1 Gold Ingot for 100 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Gold Ingot (1)", "$COIN$", "coin-100", "Sell 1 Gold Ingot for 100 coins.");
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 1);
		s.spawnNothing = true;
	}



	{
		ShopItem@ s = addShopItem(this, "Buy Stone (250)", "$mat_stone$", "mat_stone-250", "Buy 250 stone for 125 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Wood (250)", "$mat_wood$", "mat_wood-250", "Buy 250 wood for 90 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 90);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Stone (250)", "$COIN$", "coin-100", "Sell 250 stone for 100 coins.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Wood (250)", "$COIN$", "coin-75", "Sell 250 wood for 75 coins.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
		s.spawnNothing = true;
	}



	{
		ShopItem@ s = addShopItem(this, "Gramophone Record", "$musicdisc$", "musicdisc", "A random gramophone record!");
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
		s.spawnNothing = true;
	}	
	{
		ShopItem@ s = addShopItem(this, "Voltron Battery Plus", "$mat_battery$", "mat_battery-50-50", "Energize yourself with our electricity in a can!");
		AddRequirement(s.requirements, "coin", "", "Coins", 249);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Fluffy Badger Plushie (1)", "$badgerplushie$", "badgerplushie-30", "Everyone's favourite pet now as a toy!");
		AddRequirement(s.requirements, "coin", "", "Coins", 149);
		s.spawnNothing = true;
	}



	{
		ShopItem@ s = addShopItem(this, "Buy Scrub's Chow (1)", "$foodcan$", "foodcan", "Buy 1 Scrub's Chow for 100 coins. Cheap food commonly eaten by lowlife.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Stone (250)", "$COIN$", "coin-100", "Sell 1 Scrub's Chow for 75 coins.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 75);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Cinnamon Bun", "$icon_cake$", "cake", "A tasty cinnamon-flavoured stack.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Ice Cream (1)", "$icecream$", "icecream-8", "Cotton candy-flavoured ice cream. Ideal snack for hot summers!");
		AddRequirement(s.requirements, "coin", "", "Coins", 39);
		s.spawnNothing = true;
	}

	
	// Random@ rand = Random(this.getNetworkID());
	
	// // Gold Trader
	// if (rand.NextRanged(100) < 75)
	// {
		// {
			// ShopItem@ s = addShopItem(this, "Buy Gold Ingot (1)", "$mat_goldingot$", "mat_goldingot-1", "Buy 1 Gold Ingot for 100 coins.");
			// AddRequirement(s.requirements, "coin", "", "Coins", 100);
			// s.spawnNothing = true;
		// }
		// {
			// ShopItem@ s = addShopItem(this, "Sell Gold Ingot (1)", "$COIN$", "coin-100", "Sell 1 Gold Ingot for 100 coins.");
			// AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 1);
			// s.spawnNothing = true;
		// }
	// }
	
	// // Materials Trader
	// if (rand.NextRanged(100) < 40)
	// {
		// {
			// ShopItem@ s = addShopItem(this, "Buy Stone (250)", "$mat_stone$", "mat_stone-250", "Buy 250 stone for 125 coins.");
			// AddRequirement(s.requirements, "coin", "", "Coins", 125);
			// s.spawnNothing = true;
		// }
		// {
			// ShopItem@ s = addShopItem(this, "Buy Wood (250)", "$mat_wood$", "mat_wood-250", "Buy 250 wood for 90 coins.");
			// AddRequirement(s.requirements, "coin", "", "Coins", 90);
			// s.spawnNothing = true;
		// }
		// {
			// ShopItem@ s = addShopItem(this, "Sell Stone (250)", "$COIN$", "coin-100", "Sell 250 stone for 100 coins.");
			// AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
			// s.spawnNothing = true;
		// }
		// {
			// ShopItem@ s = addShopItem(this, "Sell Wood (250)", "$COIN$", "coin-75", "Sell 250 wood for 75 coins.");
			// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
			// s.spawnNothing = true;
		// }
	// }
	
	// // Misc Trader
	// if (rand.NextRanged(100) < 40)
	// {
		// {
			// ShopItem@ s = addShopItem(this, "Gramophone Record", "$musicdisc$", "musicdisc", "A random gramophone record!");
			// AddRequirement(s.requirements, "coin", "", "Coins", 30);
			// s.spawnNothing = true;
		// }	
		// {
			// ShopItem@ s = addShopItem(this, "Voltron Battery Plus", "$mat_battery$", "mat_battery-50-50", "Energize yourself with our electricity in a can!");
			// AddRequirement(s.requirements, "coin", "", "Coins", 249);
			// s.spawnNothing = true;
		// }
		// {
			// ShopItem@ s = addShopItem(this, "Fluffy Badger Plushie (1)", "$badgerplushie$", "badgerplushie-30", "Everyone's favourite pet now as a toy!");
			// AddRequirement(s.requirements, "coin", "", "Coins", 149);
			// s.spawnNothing = true;
		// }
	// }
	
	// // Food Trader
	// if (rand.NextRanged(100) < 60)
	// {
		// {
			// ShopItem@ s = addShopItem(this, "Buy Scrub's Chow (1)", "$foodcan$", "foodcan", "Buy 1 Scrub's Chow for 100 coins. Cheap food commonly eaten by lowlife.");
			// AddRequirement(s.requirements, "coin", "", "Coins", 100);
			// s.spawnNothing = true;
		// }
		// {
			// ShopItem@ s = addShopItem(this, "Sell Stone (250)", "$COIN$", "coin-100", "Sell 1 Scrub's Chow for 75 coins.");
			// AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 75);
			// s.spawnNothing = true;
		// }
		// {
			// ShopItem@ s = addShopItem(this, "Cinnamon Bun", "$icon_cake$", "cake", "A tasty cinnamon-flavoured stack.");
			// AddRequirement(s.requirements, "coin", "", "Coins", 50);
			// s.spawnNothing = true;
		// }
		// {
			// ShopItem@ s = addShopItem(this, "Ice Cream (1)", "$icecream$", "icecream-8", "Cotton candy-flavoured ice cream. Ideal snack for hot summers!");
			// AddRequirement(s.requirements, "coin", "", "Coins", 39);
			// s.spawnNothing = true;
		// }
	// }
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		const u8 myTeam = this.getTeamNum();
		if (myTeam >= 100) return;

		CBlob@[] players;
		getBlobsByTag("player", @players);
		
		for (uint i = 0; i < players.length; i++)
		{
			if (players[i].getTeamNum() == myTeam)
			{
				CPlayer@ ply = players[i].getPlayer();
			
				if (ply !is null) ply.server_setCoins(ply.getCoins() + 2);
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		
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
			else if(spl[0] == "seed")
			{
				CBlob@ blob = server_MakeSeed(this.getPosition(),XORRandom(2)==1 ? "tree_pine" : "tree_bushy");
				
				if (blob is null) return;
			   
				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				CBlob@ mat = server_CreateBlob(spl[0]);
							
				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());
				
				if (blob is null) return;
			   
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

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_bool("shop available", this.isOverlapping(caller));
}