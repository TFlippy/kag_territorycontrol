// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

const string[] resources = 
{
	"mat_coal",
	"mat_iron",
	"mat_copper",
	"mat_stone",
	"mat_gold",
	"mat_sulphur",
	"mat_dirt"
};

const u8[] resourceYields = 
{
	10,
	27,
	8,
	45,
	20,
	7,
	15
};

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("teamlocked tunnel");
	this.Tag("change team on fort capture");

	this.Tag("upkeep building");
	this.set_u8("upkeep cap increase", 0);
	this.set_u8("upkeep cost", 1);

	this.addCommandID("write");
	//this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
	this.set_Vec2f("travel button pos", Vec2f(3.5f, 4));
	this.inventoryButtonPos = Vec2f(-16, 8);
	this.getCurrentScript().tickFrequency = 30*5; //With 12 players its the same rate as before 1x, with 1 player its 0.35x

	getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);

	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 6, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 8));
	this.set_Vec2f("shop menu size", Vec2f(3, 2));
	this.set_string("shop description", "Coalville Mining Company");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Buy Dirt (100)", "$mat_dirt$", "mat_dirt-100", "Buy 100 Dirt for 50 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Stone (250)", "$mat_stone$", "mat_stone-250", "Buy 250 Stone for 125 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Coal (25)", "$mat_coal$", "mat_coal-25", "Buy 25 Coal for 250 coins.");
		AddRequirement(s.requirements,"coin","","Coins", 250); //made it cost a lot, so it's better to just conquer the building
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Copper Ore (25)", "$mat_copper$", "mat_copper-25", "Buy 25 copper for 25 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Iron Ore (100)", "$mat_iron$", "mat_iron-100", "Buy 100 Iron Ore for 100 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Sulphur (50)", "$mat_sulphur$", "mat_sulphur-50", "Buy 50 Sulphur for 150 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.spawnNothing = true;
	}
}

/*void onTick(CBlob@ this)
{
	if (isServer())
	{
		u8 index = XORRandom(resources.length - 1);
		MakeMat(this, this.getPosition(), resources[index], XORRandom(resourceYields[index]));
	}
}*/

void onTick(CBlob@ this)
{
	if(isServer())
	{
		// if (this.getInventory().isFull()) return;

		// u8 index = XORRandom(resources.length - 1);
		// MakeMat(this, this.getPosition(), resources[index], XORRandom(resourceYields[index]));

		CBlob@ storage = FindStorage(this.getTeamNum());
		int count = getPlayerCount();
		double mod = ((6 + count) + Maths::Max(0, count - 10)) * 0.05f; 
		//Previous rate at 12 players, players after 10 increase the rate by twice as much
		//0.35x Previous rate at 1 player
		//0.5x at 4 players
		//1x at 12 players
		//2x at 22 players
		
		u8 index = XORRandom(resources.length);
		u32 amount = Maths::Max(1, Maths::Floor(XORRandom(resourceYields[index]) * mod));
		//print(mod +  " " +amount);
		
		if (storage !is null)
		{
			MakeMat(storage, this.getPosition(), resources[index], amount);
		}
		else if (!this.getInventory().isFull())
		{
			MakeMat(this, this.getPosition(), resources[index], amount);
		}
	}
}

CBlob@ FindStorage(u8 team)
{
	if (team >= 100) return null;

	CBlob@[] blobs;
	getBlobsByName("stonepile", @blobs);

	CBlob@[] validBlobs;

	for (u32 i = 0; i < blobs.length; i++)
	{
		if (blobs[i].getTeamNum() == team && !blobs[i].getInventory().isFull())
		{
			validBlobs.push_back(blobs[i]);
		}
	}

	if (validBlobs.length == 0) return null;

	return validBlobs[XORRandom(validBlobs.length)];
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(3, -2));
	this.set_bool("shop available", this.isOverlapping(caller));

	if (caller is null) return;
	if (!this.isOverlapping(caller)) return;

	//rename the coal mine
	CBlob@ carried = caller.getCarriedBlob();
	if(carried !is null && carried.getName() == "paper" && caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(carried.getNetworkID());

		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, -8), this, this.getCommandID("write"), "Rename the mine.", params);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return true;

	// return false;
	// return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
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
	if (cmd == this.getCommandID("write"))
	{
		if (isServer())
		{
			CBlob @caller = getBlobByNetworkID(params.read_u16());
			CBlob @carried = getBlobByNetworkID(params.read_u16());

			if (caller !is null && carried !is null)
			{
				this.set_string("text", carried.get_string("text"));
				this.Sync("text", true);
				this.set_string("shop description", this.get_string("text"));
				this.Sync("shop description", true);
				carried.server_Die();
			}
		}
		if (isClient())
		{
			this.setInventoryName(this.get_string("text"));
		}
	}
}
