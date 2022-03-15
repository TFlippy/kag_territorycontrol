// A script by TFlippy

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

	//this.Tag("upkeep building");
	//this.set_u8("upkeep cap increase", 0);
	//this.set_u8("upkeep cost", 5);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("remote_storage");
	this.Tag("builder always hit");
	this.Tag("change team on fort capture");

	this.getCurrentScript().tickFrequency = 300;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	this.inventoryButtonPos = Vec2f(-8, 0);
	this.addCommandID("sv_store");

	addTokens(this); //colored shop icons

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(3, 5));
	this.set_string("shop description", "Armory");
	this.set_u8("shop icon", 15);

	{
		ShopItem@ s = addShopItem(this, "Royal Guard Armor", "$icon_royalarmor$", "royalarmor", "A heavy armor that offers high damage resistance at cost of low mobility. Has a shield which is tough enough to block bullets.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 8);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Truncheon", "$icon_nightstick$", "nightstick", "A traditional tool used by seal clubbing clubs.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Parachute Pack", "$icon_parachute$", "parachutepack", "A piece of fabric to let you fall slowly.\nPress [E] while falling to activate.\n\nOccupies the Torso slot.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb (1)", "$waterbomb$", "mat_waterbombs-1", descriptions[52], true);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Water Arrow (2)", "$mat_waterarrows$", "mat_waterarrows-2", descriptions[50], true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Fire Arrow (2)", "$mat_firearrows$", "mat_firearrows-2", descriptions[32], true);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Combat Helmet", "$icon_militaryhelmet$", "militaryhelmet", "A heavy combat helmet.\nCan absorb up to 20 points of damage.\n\nOccupies the Head slot");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Ballistic Vest", "$icon_bulletproofvest$", "bulletproofvest", "A resilient ballistic armor.\nCan absorb up to 25 points of damage.\n\nOccupies the Torso slot");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Combat Boots", "$icon_combatboots$", "combatboots", "A pair of sturdy boots.\nCan absorb up to 10 points of damage.\nIncreases running speed.\nIncreases stomp damage.\n\nOccupies the Boots slot");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Repair Helmet", "$icon_militaryhelmet$", "militaryhelmet", "Repair combat helmet.");
		AddRequirement(s.requirements, "blob", "militaryhelmet", "Combat Helmet", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 35);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Repair Vest", "$icon_bulletproofvest$", "bulletproofvest", "Repair ballistic vest.");
		AddRequirement(s.requirements, "blob", "bulletproofvest", "Ballistic Vest", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Repair Boots", "$icon_combatboots$", "combatboots", "Repair combat boots.");
		AddRequirement(s.requirements, "blob", "combatboots", "Combat Boots", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 35);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Slavemaster's Kit", "$icon_shackles$", "shackles", "A kit containing shackles, shiny iron ball, elegant striped pants, noisy chains and a slice of cheese.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bushy Helm", "$bush$", "bushyhelm", "Add bush camo to helm.");
		AddRequirement(s.requirements, "blob", "militaryhelmet", "Combat Helmet", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);

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

	AddIconToken("$icon_parachute$", "Parachutepack.png", Vec2f(16, 16), 0, teamnum);
	AddIconToken("$icon_royalarmor$", "RoyalArmor.png", Vec2f(16, 8), 0, teamnum);
}

bool canPickup(CBlob@ blob)
{
	return blob.hasTag("weapon") || blob.hasTag("ammo") || blob.hasTag("armor");
}

void onTick(CBlob@ this)
{
	if (this.getInventory().isFull()) return;

	CBlob@[] blobs;
	if (getMap().getBlobsInBox(this.getPosition() + Vec2f(128, 96), this.getPosition() + Vec2f(-128, -96), @blobs))
	{
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];

			if ((canPickup(blob)) && !blob.isAttached())
			{
				if (isClient() && this.getInventory().canPutItem(blob)) blob.getSprite().PlaySound("/PutInInventory.ogg");
				if (isServer()) this.server_PutInInventory(blob);
			}
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	CBlob@ carried = forBlob.getCarriedBlob();
	return forBlob.isOverlapping(this) && (carried is null ? true : canPickup(carried));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ carried = caller.getCarriedBlob();

	if (isInventoryAccessible(this, caller))
	{
		this.set_Vec2f("shop offset", Vec2f(4, 0));
		this.set_bool("shop available", this.isOverlapping(caller));

		CBitStream params;
		params.write_u16(caller.getNetworkID());

		CInventory @inv = caller.getInventory();
		if (inv is null) return;

		if (inv.getItemsCount() > 0)
		{
			for (int i = 0; i < inv.getItemsCount(); i++)
			{
				CBlob @item = inv.getItem(i);
				if (canPickup(item))
				{
					params.write_u16(caller.getNetworkID());
					CButton@ buttonOwner = caller.CreateGenericButton(28, Vec2f(-10, 0), this, this.getCommandID("sv_store"), "Store", params);
					break;
				}
			}
		}
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(0, 0));
		this.set_bool("shop available", this.isOverlapping(caller));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ConstructShort");

		u16 caller, item;

		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
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
			else if (name.findFirst("mat_") != -1 || name.findFirst("ammo_") != -1)
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
				string blobName = spl[0];
				if (blobName == "bushyhelm") blobName = "militaryhelmet";

				CBlob@ blob = server_CreateBlob(blobName, callerBlob.getTeamNum(), this.getPosition());
				if (spl[0] == "bushyhelm") blob.Tag("bushy");

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
	if (cmd == this.getCommandID("sv_store"))
	{
		if (isServer())
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{
				CInventory @inv = caller.getInventory();
				if (caller.getName() == "builder")
				{
					CBlob@ carried = caller.getCarriedBlob();
					if (carried !is null)
					{
						if (carried.hasTag("temp blob"))
						{
							carried.server_Die();
						}
					}
				}
				if (inv !is null)
				{
					for (int i = 0; i < inv.getItemsCount(); i++)
					{
						CBlob @item = inv.getItem(i);
						if (canPickup(item))
						{
							caller.server_PutOutInventory(item);
							this.server_PutInInventory(item);
							i--;
						}
					}
				}
			}
		}
	}
}
