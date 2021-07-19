// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "BirdCommon.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "MakeSeed.as";
#include "MakeCrate.as";

void onInit(CBlob@ this)
{
	//this.Tag("upkeep building");
	//this.set_u8("upkeep cap increase", 0);
	//this.set_u8("upkeep cost", 50);

	this.Tag("big shop");
	this.Tag("invincible");

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("change team on fort capture");

	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 0.0f));

	getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);

	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 6, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);

	this.getCurrentScript().tickFrequency = 30 * 3;

	this.SetLight(true);
	this.SetLightRadius(160.0f);
	this.SetLightColor(SColor(255, 255, 200, 110));

	addTokens(this); //colored shop icons

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 4));
	this.set_Vec2f("shop menu size", Vec2f(4, 6));
	this.set_string("shop description", "United Poultry Federation Department Store");
	this.set_u8("shop icon", 25);

	// {
		// ShopItem@ s = addShopItem(this, "Sell Grain (1)", "$COIN$", "coin-40", "Sell 1 Grain for 40 coins.");
		// AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
		// s.spawnNothing = true;
	// }

	this.set_string("shop_owner", "");
	this.addCommandID("buyout");
	this.addCommandID("write");

	{
		ShopItem@ s = addShopItem(this, "UPF Department Store Partnership Card", "$buyshop$", "buyshop", "Become an UPF Department Store Partner and receive 20% of its sales.", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 999);

		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 4;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Bobomax Funny Pills 200mg", "$bobomax$", "bobomax-200", "Orthocarbonic acid (methanetetrol), also known as Bobomax, is a psychedelic drug known for its psychological effects.");
		AddRequirement(s.requirements, "coin", "", "Coins", 799);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Fluffy Badger Plushie (1)", "$badgerplushie$", "badgerplushie-30", "Everyone's favourite pet now as a toy!");
		AddRequirement(s.requirements, "coin", "", "Coins", 149);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Ice Cream (1)", "$icecream$", "icecream-8", "Cotton candy-flavoured ice cream. Ideal snack for hot summers!");
		AddRequirement(s.requirements, "coin", "", "Coins", 39);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "'Fuger' Pocket Pistol", "$fuger$", "fuger-110", "Tired of humans harrasing you at night? Shoot them in face!");
		AddRequirement(s.requirements, "coin", "", "Coins", 549);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "IPL Lottery Ticket", "$lotteryticket$", "lotteryticket-50", "Have you ever dreamed of becoming a hero like Foghorn? Buy yourself an IPL Lottery Ticket and make your dreams come true!");
		AddRequirement(s.requirements, "coin", "", "Coins", 249);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Egg (1)", "$COIN$", "coin-90", "Sell 1 rescued Egg for 90 coins.");
		AddRequirement(s.requirements, "blob", "egg", "Rescued Egg", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Zapper", "$icon_zapper$", "zapper-260", "Place this small device in your garden and watch the intruders get fried to crisp!\nRequires Batteries to operate.");
		AddRequirement(s.requirements, "coin", "", "Coins", 1299);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Taser", "$taser$", "taser-100", "Zapper's smaller handheld brother.\nRequires Batteries to operate.");
		AddRequirement(s.requirements, "coin", "", "Coins", 499);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Voltron Battery Plus", "$mat_battery$", "mat_battery-50-50", "Energize yourself with our electricity in a can!");
		AddRequirement(s.requirements, "coin", "", "Coins", 249);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Portable SAM System", "$icon_sam$", "sam-500", "A portable surface-to-air missile system used to shoot down aerial targets. Automatically operated.");
		AddRequirement(s.requirements, "coin", "", "Coins", 2499);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "SAM Missile (1)", "$icon_sammissile$", "mat_sammissile-1-56", "Guided missiles for the Portable SAM System.");
		AddRequirement(s.requirements, "coin", "", "Coins", 279);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Armored Car (1)", "$icon_armoredcar$", "armoredcar-500", "A light armored vehicle equipped with a tank cannon.");
		AddRequirement(s.requirements, "coin", "", "Coins", 3000);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Portable LWS", "$icon_lws$", "lws-400", "A portable laser weapon system capable of shooting down airborne projectiles. Automatically operated.");
		AddRequirement(s.requirements, "coin", "", "Coins", 1999);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Peacekeeper", "$icon_sentry$", "sentry-400", "A small sentry gun that uses Machine Gun ammo. Automatically operated.");
		AddRequirement(s.requirements, "coin", "", "Coins", 1999);
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

	AddIconToken("$icon_zapper$", "Zapper.png", Vec2f(24, 24), 0, teamnum);
	AddIconToken("$icon_sam$", "SAM_Icon.png", Vec2f(32, 24), 0, teamnum);
	AddIconToken("$icon_sammissile$", "SAM_Missile.png", Vec2f(8, 16), 0, teamnum);
	AddIconToken("$icon_lws$", "LWS_Icon.png", Vec2f(32, 24), 0, teamnum);
	AddIconToken("$icon_sentry$", "Sentry_Icon.png", Vec2f(32, 24), 0, teamnum);
	AddIconToken("$icon_armoredcar$", "ArmoredCar_Icon.png", Vec2f(48, 32), 0, teamnum);
}

void onTick(CBlob@ this)
{
	// CBlob@[] players;
	// getBlobsByTag("player", @players);

	// u8 myTeam = this.getTeamNum();

	// for (uint i = 0; i < players.length; i++)
	// {
		// if (players[i].getTeamNum() == myTeam)
		// {
			// CPlayer@ ply = players[i].getPlayer();

			// if (ply !is null) ply.server_setCoins(ply.getCoins() + 10);
		// }
	// }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

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
			else if (spl[0] == "lotteryticket")
			{
				CBlob@ blob = server_CreateBlobNoInit("lotteryticket");
				blob.set_u16("value", XORRandom(50000));
				blob.setPosition(this.getPosition());
				blob.server_setTeamNum(-1);
				blob.Init();

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
			else if (spl[0] == "buyshop")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				if (isServer())
				{
					this.server_setTeamNum(callerPlayer.getTeamNum());
					this.set_string("shop_owner", callerPlayer.getUsername());
				}

				Sound::Play("ChickenMarket_Purchase.ogg");

				client_AddToChat("" + callerPlayer.getCharacterName() + " has has purchased an UPF Department Store Partnership Card and from now on will receive 20 percent of its sales!", SColor(255, 255, 100, 0));
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

					if (this.get_string("shop_owner") != "")
					{
						CPlayer@ owner = getPlayerByUsername(this.get_string("shop_owner"));

						if (owner !is null)
						{
							owner.server_setCoins(owner.getCoins() + parseInt(spl[2]));
						}
					}
				}
			}
			else
			{
				if (this.get_string("shop_owner") != "")
				{
					CPlayer@ owner = getPlayerByUsername(this.get_string("shop_owner"));

					if (owner !is null)
					{
						owner.server_setCoins(owner.getCoins() + parseInt(spl[1]));
					}
				}

				if (spl[0] == "armoredcar")
				{
					CBlob@ crate = server_MakeCrate("armoredcar", "Armored Car", 0, callerBlob.getTeamNum(), this.getPosition(), false);
					crate.Init();
					callerBlob.server_Pickup(crate);
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
	else if (cmd == this.getCommandID("buyout"))
	{
		if (isClient())
		{
			u16 id;
			string name;

			if (params.saferead_netid(id) && params.saferead_string(name))
			{
				CPlayer@ player = getLocalPlayer();
				if (player.getNetworkID() == id && player.getUsername() == name) onInit();
				return; // WIP
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));

	if (caller is null) return;
	if (!this.isOverlapping(caller)) return;

	//rename the market
	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null && carried.getName() == "paper" && caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(carried.getNetworkID());

		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, -8), this, this.getCommandID("write"), "Rename the market.", params);
	}
}
