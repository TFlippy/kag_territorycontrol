// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	//this.Tag("upkeep building");
	//this.set_u8("upkeep cap increase", 0);
	//this.set_u8("upkeep cost", 5);

	// this.set_string("required class", "sapper");
	// this.set_Vec2f("class offset", Vec2f(0, 8));

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");

	// getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);

	addTokens(this); //colored shop icons

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6, 6));
	this.set_string("shop description", "Demolitionist's Workshop");
	this.set_u8("shop icon", 15);
	
	//Rockets
	
	{
		ShopItem@ s = addShopItem(this, "Bazooka", "$icon_bazooka$", "bazooka", "A long tube capable of shooting rockets. Make sure nobody is standing behind it.\n\nUses Small Rockets.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);


		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Rendezook", "$icon_rendezook$", "rendezook", "A replica of a rocket launcher found behind the UPF shop in a trash can.\nDoes not seem to hurt anybody.");
		AddRequirement(s.requirements, "coin", "", "Coins", 350);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Small Rocket (1)", "$icon_smallrocket$", "mat_smallrocket-1", "Self-propelled ammunition for rocket launchers.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	///LOL
	
	{
		ShopItem@ s = addShopItem(this, "L.O.L. Warhead Launcher", "$icon_mininukelauncher$", "mininukelauncher", "Are people bullying you again? Remember, there still is the nuclear option.\n\nUses L.O.L. Warheads.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 10);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 300);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "L.O.L. Warhead (1)", "$icon_mininuke$", "mat_mininuke-1", "A miniature nuclear warhead. Can be used as L.O.L. Warhead Launcher ammunition. Detonates upon impact.");
		AddRequirement(s.requirements, "coin", "", "Coins", 350);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 4);
		AddRequirement(s.requirements, "blob", "mat_mithrilenriched", "Enriched Mithril", 10);

		s.spawnNothing = true;
	}
	
	
	{
		ShopItem@ s = addShopItem(this, "Small Bomb (4)", "$icon_smallbomb$", "mat_smallbomb-4", "A small iron bomb. Detonates upon strong impact.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Incendiary Bomb (2)", "$icon_incendiarybomb$", "mat_incendiarybomb-2", "Sets the peasants on fire. Detonates upon strong impact.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_oil", "Oil", 20);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Shockwave Bomb (2)", "$icon_stunbomb$", "mat_stunbomb-2", "Creates a shockwave with strong knockback. Detonates upon strong impact.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "mat_methane", "Methane", 20);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bunker Buster (1)", "$icon_bunkerbuster$", "mat_bunkerbuster-1", "Perfect for making holes in heavily fortified bases. Detonates upon strong impact.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Big Bomb (1)", "$icon_bigbomb$", "mat_bigbomb-1", "A really big bomb. Handle with care. It's indeed a large bomb.");
		AddRequirement(s.requirements, "coin", "", "Coins", 700);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 150);
		AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 50);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Rocket of Doom", "$icon_rocket$", "rocket", "Let's fly to the Moon. (Not really)");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 2);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Dirty Bomb (1)", "$icon_dirtybomb$", "mat_dirtybomb-1", "Scatters toxic mithril dust upon detonation.");
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril", 200);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Cluster Bomb (1)", "$icon_clusterbomb$", "mat_clusterbomb-1", "A cluster bomb that splits into smaller bomblets upon detonation.");
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		AddRequirement(s.requirements, "blob", "mat_methane", "Methane", 25);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 25);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Guided Missile", "$icon_guidedrocket$", "guidedrocket", "A self-guided missile used to down bombers. Due to poorly designed navigation systems, it may display unpredictable behaviour.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_methane", "Methane", 20);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Firework (1)", "$icon_firework$", "firework", "Celebrate the new year with this colorful rocket!");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Howitzer Shell (2)", "$icon_howitzershell$", "mat_howitzershell-2", "A large howitzer shell capable of annihilating a cottage.");
		AddRequirement(s.requirements, "coin", "", "Coins", 75);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Fragmentation Mine", "$icon_fragmine$", "fragmine", "A fragmentation mine that fills the surroundings with shards of metal upon detonation.");
		AddRequirement(s.requirements, "coin", "", "Coins", 125);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Shock Mine", "$icon_shockmine$", "shockmine", "A concussive mine. Launches nearby objects upon detonation.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$icon_mine$", "mine", descriptions[20], false);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gregor (1)", "$icon_claymore$", "claymore-1", "A remotely triggered explosive device covered in some sort of slime. Sticks to surfaces.");
		AddRequirement(s.requirements, "coin", "", "Coins", 70);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gregor Remote Detonator", "$icon_claymoreremote$", "claymoreremote-1", "A device used to remotely detonate Gregors.");
		AddRequirement(s.requirements, "coin", "", "Coins", 150);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "R.O.F.L.", "$icon_nuke$", "nuke", "A dangerous warhead stuffed in a cart. Since it's heavy, it can be only pushed around or picked up by balloons.");
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 10);
		AddRequirement(s.requirements, "blob", "mat_mithrilenriched", "Enriched Mithril", 50);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100); // Cart!
		AddRequirement(s.requirements, "coin", "", "Coins", 750);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Artillery Shell (4)", "$icon_tankshell$", "mat_tankshell-4", "A highly explosive shell used by the artillery.");
		AddRequirement(s.requirements, "coin", "", "Coins", 40);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Smoke Grenade (1)", "$icon_smokegrenade$", "mat_smokegrenade-1", "A small hand grenade used to quickly fill a room with smoke. It helps you keep out of sight.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 25);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Flash Grenade (1)", "$icon_flashgrenade$", "mat_flashgrenade-1", "A flash grenade used to temporarily blind your enemies.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 10);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Dynamite (1)", "$icon_dynamite$", "mat_dynamite-1", "A bundle of dynamite sticks. Good for mining, as it yields resources.");
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 25);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Suicide Vest", "$icon_suicidevest$", "suicidevest", "An ugly christmas sweater strapped with explosives.\n\nOccupies the Torso slot\nPress [E] to blow yourself up.");
		AddRequirement(s.requirements, "coin", "", "Coins", 200);

		s.spawnNothing = true;
	}
	
	
	{
		ShopItem@ s = addShopItem(this, "Fragmentation Grenade (1)", "$icon_fraggrenade$", "mat_fraggrenade-1", "A small hand grenade. Especially useful against infantry.");
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 15);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Grenade Launcher", "$icon_grenadelauncher$", "grenadelauncher", "A short-ranged weapon that launches grenades.\n\nUses Grenades.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);


		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Grenade (2)", "$icon_grenade$", "mat_grenade-2", "A small, timed explosive device used by grenade launchers.");
		AddRequirement(s.requirements, "coin", "", "Coins", 75);

		s.spawnNothing = true;
	}
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	// reset shop colors
	addTokens(this);
}

void addTokens(CBlob@ this)
{
	int teamnum = this.getTeamNum();
	if (teamnum > 6) teamnum = 7;

	AddIconToken("$icon_rocket$", "Rocket.png", Vec2f(24, 40), 0, teamnum);
	AddIconToken("$icon_mine$", "Mine.png", Vec2f(16, 16), 1, teamnum);
	AddIconToken("$icon_shockmine$", "shockmine.png", Vec2f(8, 8), 0, teamnum);
	AddIconToken("$icon_fragmine$", "FragMine.png", Vec2f(16, 16), 1, teamnum);
	AddIconToken("$icon_guidedrocket$", "GuidedRocket.png", Vec2f(16, 24), 0, teamnum);
	AddIconToken("$icon_firework$", "Firework.png", Vec2f(16, 24), 0, teamnum);
	AddIconToken("$icon_smallrocket$", "Materialcon_SmallRocket.png", Vec2f(24, 24), 0, teamnum);
	AddIconToken("$icon_claymore$", "Claymore.png", Vec2f(16, 16), 1, teamnum);
	AddIconToken("$icon_stunbomb$", "Material_StunBomb.png", Vec2f(16, 16), 0, teamnum);
	AddIconToken("$icon_nuke$", "Nuke.png", Vec2f(40, 32), 0, teamnum);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}


// void GetButtonsFor(CBlob@ this, CBlob@ caller)
// {
	// bool canChangeClass = caller.getName() != "sapper";

	// if(canChangeClass)
	// {
		// this.Untag("class button disabled");
		// this.set_Vec2f("shop offset", Vec2f(4, 0));
		// this.set_bool("shop available", this.isOverlapping(caller));
	// }
	// else
	// {
		// this.Tag("class button disabled");
		// this.set_Vec2f("shop offset", Vec2f(0, 0));
		// this.set_bool("shop available", this.isOverlapping(caller));
	// }
// }

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
			CPlayer@ ply = callerBlob.getPlayer();
			if (ply !is null)
			{
				tcpr("[PBI] " + ply.getUsername() + " has purchased " + name);
			}
		
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1 || name.findFirst("ammo_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				CBlob@ mat = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

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
				if (callerBlob.getPlayer() !is null && name == "nuke")
				{
					blob.SetDamageOwnerPlayer(callerBlob.getPlayer());
				}

				if (!blob.hasTag("vehicle"))
				{
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
}
