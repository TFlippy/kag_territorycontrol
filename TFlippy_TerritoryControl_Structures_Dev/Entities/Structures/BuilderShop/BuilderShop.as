﻿// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	// this.Tag("upkeep building");
	// this.set_u8("upkeep cap increase", 0);
	// this.set_u8("upkeep cost", 5);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	AddIconToken("$filled_bucket$", "bucket.png", Vec2f(16, 16), 1);

	addTokens(this); //colored shop icons

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(5, 3));
	this.set_string("shop description", "Builder's Workshop");
	this.set_u8("shop icon", 15);
	// this.set_Vec2f("class offset", Vec2f(-6, 0));
	// this.set_string("required class", "builder");

	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", descriptions[9], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 25);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Filled Bucket", "$filled_bucket$", "filled_bucket", Descriptions::filled_bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 25);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", descriptions[53], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$icon_trampoline$", "trampoline", descriptions[30], false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);

		s.spawnNothing = true;
	}
	// {
		// ShopItem@ s = addShopItem(this, "Arrows (30)", "$mat_arrows$", "mat_arrows-30", descriptions[2], true);
		// AddRequirement(s.requirements, "coin", "", "Coins", 15);

		// s.spawnNothing = true;
	// }
	{
		ShopItem@ s = addShopItem(this, "Crate", "$crate$", "crate", "A wooden crate used for storage.\nBreaks upon impact.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", "Boulder used for crushing people.", true);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", "Highly explosive keg used by knight only.\nCan be worn.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
		AddRequirement(s.requirements, "coin", "", "Coins", 70);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Chair", "$chair$", "chair", "Quite comfortable.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Table", "$table$", "table", "A portable surface with 4 legs.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Jack o' Lantern", "$jackolantern$", "jackolantern", "A spooky pumpkin.", true);
		AddRequirement(s.requirements, "blob", "lantern", "Lantern", 1);
		AddRequirement(s.requirements, "blob", "pumpkin", "Pumpkin", 1);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Building for Dummies", "$artisancertificate$", "artisancertificate", "Simplified Builder manuscript for those dumb peasants.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Engineer's Tools", "$icon_engineertools$", "engineertools", "Engineer's Tools for real engineers.", true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 750);

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

	AddIconToken("$icon_trampoline$", "Trampoline.png", Vec2f(32, 16), 3, teamnum);
	AddIconToken("$icon_engineertools$", "EngineerTools.png", Vec2f(16, 16), 0, teamnum);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getName() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(0, 0));
	}
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
			else if (name == "filled_bucket")
			{
				CBlob@ b = server_CreateBlobNoInit("bucket");
				b.setPosition(callerBlob.getPosition());
				b.server_setTeamNum(callerBlob.getTeamNum());
				b.Tag("_start_filled");
				b.Init();
				callerBlob.server_Pickup(b);
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
