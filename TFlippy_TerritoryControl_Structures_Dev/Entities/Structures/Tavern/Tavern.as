// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "MinableMatsCommon.as";

void onInit(CSprite@ this)
{
	this.SetZ(-60);
}

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 30;
	this.Tag("builder always hit");

	this.server_setTeamNum(-1);

	this.set_string("Owner", "");
	this.addCommandID("sv_setowner");
	this.addCommandID("sv_setspawn");
	this.addCommandID("sv_unsetspawn");
	this.addCommandID("write");
	this.addCommandID("sv_togglelight");

	// CSprite@ sprite = this.getSprite();
	// sprite.SetEmitSound("Tavern_Ambient.ogg");
	// sprite.SetEmitSoundPaused(false);
	// sprite.SetEmitSoundVolume(0.60f);
	// sprite.SetEmitSoundSpeed(0.90f);

	this.set_Vec2f("shop offset", Vec2f(-6.5f, 3));
	this.set_Vec2f("shop menu size", Vec2f(3, 2));
	this.set_string("shop description", "Fun tavern!");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Beer's Bear", "$beer$", "beer", "Homemade fresh bear with foam!", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 29);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Vodka!", "$icon_vodka$", "vodka", "Also homemade fun water, buy this!");
		AddRequirement(s.requirements, "coin", "", "Coins", 91);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Tasty Rat Burger", "$ratburger$", "ratburger", "FLUFFY BURGER");
		AddRequirement(s.requirements, "coin", "", "Coins", 31);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Very Fresh Rat", "$ratfood$", "ratfood", "It doesn't bite because I hit it with a roller");
		AddRequirement(s.requirements, "coin", "", "Coins", 17);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bandit Music", "$musicdisc$", "musicdisc", "Plays a bandit music!");
		AddRequirement(s.requirements, "coin", "", "Coins", 117);
		s.spawnNothing = true;
	}

	this.set_bool("light", true);
	this.SetLight(true);
	this.SetLightRadius(72.0f);
	this.SetLightColor(SColor(255, 255, 150, 50));

	HarvestBlobMat[] mats = {};
	mats.push_back(HarvestBlobMat(100.0f, "mat_stone")); 
	mats.push_back(HarvestBlobMat(150.0f, "mat_wood"));
	this.set("minableMats", mats);	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.inventoryButtonPos = Vec2f(0, 0);

	if (this.getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if (caller.getPlayer() is null) return; 

	if (caller.isOverlapping(this) && this.get_string("Owner") == "")
	{
		CButton@ buttonOwner = caller.CreateGenericButton(11, Vec2f(2, 3), this, this.getCommandID("sv_setowner"), "Claim", params);
	}

	if (caller.getTeamNum() >= 100 && this.get_string("Owner") != "")
	{
		if (caller.getPlayer().get_u16("tavern_netid") != this.getNetworkID())
		{ CButton@ buttonOwner = caller.CreateGenericButton(29, Vec2f(2, 3), this, this.getCommandID("sv_setspawn"), "Set this as your current spawn point.\n(Costs 20 coins per respawn)", params); }
		else
		{ CButton@ buttonOwner = caller.CreateGenericButton(9, Vec2f(2, 3), this, this.getCommandID("sv_unsetspawn"), "Unset this as your current spawn point.", params); }
	}
	//if (!this.isOverlapping(caller)) return;

	//rename the tavern
	CBlob@ carried = caller.getCarriedBlob();
	CPlayer@ player = caller.getPlayer();
	if (carried !is null && player !is null && carried.getName() == "paper" && player.getUsername() == this.get_string("Owner"))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(carried.getNetworkID());

		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, -8), this, this.getCommandID("write"), "Rename", params);
	}

	//toggle tavern light
	if (player !is null && player.getUsername() == this.get_string("Owner"))
	{
		CButton@ buttonLight = caller.CreateGenericButton((this.get_bool("light") ? 27 : 23), Vec2f(12, -3), this, this.getCommandID("sv_togglelight"), "Toggle_Light", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("MigrantHmm");
		this.getSprite().PlaySound("ChaChing");

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
			else if (spl[0] == "musicdisc")
			{
				CBlob@ disc = server_CreateBlobNoInit("musicdisc");
				disc.setPosition(this.getPosition());
				disc.set_u8("trackID", 18);
				disc.server_setTeamNum(-1);
				disc.Init();

				if (disc is null) return;

				if (!disc.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(disc);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(disc);
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
	else if (cmd == this.getCommandID("sv_setowner"))
	{
		if (this.get_string("Owner") != "") return;

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller is null) return;

		CPlayer@ player = caller.getPlayer();
		if (player is null) return;

		this.set_string("Owner", player.getUsername());
		this.setInventoryName((this.get_string("Owner") == "" ? "Nobody" : this.get_string("Owner")) + "'s Shoddy Tavern");

		if (isServer())
		{
			this.server_setTeamNum(player.getTeamNum());
		}
		// this.Sync("Owner", true);

		// print("Set owner to " + this.get_string("Owner") + "; Team: " + this.getTeamNum());
	}
	else if (cmd == this.getCommandID("sv_setspawn"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			CPlayer@ ply = caller.getPlayer();
			if (ply !is null)
			{
				ply.set_u16("tavern_netid", this.getNetworkID());
				ply.set_u8("tavern_team", ply.getTeamNum());

				// print("" + ply.getTeamNum());

				if (isServer())
				{
					ply.Sync("tavern_netid", true);
					ply.Sync("tavern_team", true);
				}

				this.getSprite().PlaySound("party_join.ogg");
			}
		}
	}
	else if (cmd == this.getCommandID("sv_unsetspawn"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			CPlayer@ ply = caller.getPlayer();
			if (ply !is null)
			{
				ply.set_u16("tavern_netid", 0);
				ply.set_u8("tavern_team", 255);

				if (isServer())
				{
					ply.Sync("tavern_netid", true);
					ply.Sync("tavern_team", true);
				}
			}
		}
	}
	else if (cmd == this.getCommandID("write"))
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
	else if (cmd == this.getCommandID("sv_togglelight"))
	{
		this.SetLight(!this.get_bool("light"));
		this.set_bool("light", !this.get_bool("light"));
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob.getPlayer() !is null)
	{
		damage *= (hitterBlob.getPlayer().getUsername() == this.get_string("Owner") ? 4.0f : 1.0f);
	}

	return damage;

	return damage * (hitterBlob.getPlayer() is null ? 1.0f : (hitterBlob.getPlayer().getUsername() == this.get_string("Owner") ? 4.0f : 1.0f));
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if (forBlob.getPlayer() is null) return false;

	return forBlob.getPlayer().getUsername() == this.get_string("Owner");
}
