#include "Requirements.as";
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.Tag("builder always hit");
	this.Tag("upf_base");
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	this.getCurrentScript().tickFrequency = 1800;
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("ChickenMarch.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(0.3f);
	
	this.Tag("minimap_small");
	this.set_u8("minimap_index", 27);
	
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Chicken Coop");
	this.set_u8("shop icon", 15);
	// this.set_Vec2f("class offset", Vec2f(-6, 0));
	// this.set_string("required class", "builder");

	{
		ShopItem@ s = addShopItem(this, "Low Caliber Ammunition (20)", "$icon_pistolammo$", "mat_pistolammo-20", "Bullets for pistols and SMGs.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "High Caliber Ammunition (10)", "$icon_rifleammo$", "mat_rifleammo-10", "Bullets for rifles. Effective against armored targets.");
		AddRequirement(s.requirements, "coin", "", "Coins", 75);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun Shells (4)", "$icon_shotgunammo$", "mat_shotgunammo-4", "Shotgun Shells for... Shotguns.");
		AddRequirement(s.requirements, "coin", "", "Coins", 70);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Machine Gun Ammunition (50)", "$icon_gatlingammo$", "mat_gatlingammo-50", "Ammunition used by the machine gun.");
		AddRequirement(s.requirements, "coin", "", "Coins", 85);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Machine Gun Ammunition (50)", "$icon_gatlingammo$", "mat_gatlingammo-50", "Ammunition used by the machine gun.");
		AddRequirement(s.requirements, "coin", "", "Coins", 85);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Fragmentation Grenade (1)", "$icon_fraggrenade$", "mat_fraggrenade-1", "A small hand grenade. Especially useful against infantry.");
		AddRequirement(s.requirements, "coin", "", "Coins", 75);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Scrub's Chow (1)", "$foodcan$", "foodcan-1", "Scrub's Chow. Foodcans used to satisfy your hunger.");
		AddRequirement(s.requirements, "coin", "", "Coins", 150);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Assault Rifle", "$assaultrifle$", "assaultrifle", "Assault Rifle. Used to assault humans.");
		AddRequirement(s.requirements, "coin", "", "Coins", 1999);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Suppressed Rifle", "$silencedrifle$", "silencedrifle", "A rifle with a suppressor. Used for assassination of humans.");
		AddRequirement(s.requirements, "coin", "", "Coins", 1999);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF PDW", "$pdw$", "pdw", "UPF PDW. Used for shooting holes into humans.");
		AddRequirement(s.requirements, "coin", "", "Coins", 1199);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Assault Shotgun", "$autoshotgun$", "autoshotgun", "Automatic Shotgun. Used to destroy humans.");
		AddRequirement(s.requirements, "coin", "", "Coins", 2499);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Carbine", "$carbine$", "carbine", "UPF Carbine. Used to penetrate humans from afar.");
		AddRequirement(s.requirements, "coin", "", "Coins", 899);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Sniper Rifle", "$sniper$", "sniper", "Sniper Rifle. Used for sniping humans.");
		AddRequirement(s.requirements, "coin", "", "Coins", 1999);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF AMR-127", "$amr$", "amr", "UPF Anti-Material Rifle. Used to obliterate humans.");
		AddRequirement(s.requirements, "coin", "", "Coins", 3499);

		s.spawnNothing = true;
	}

	if (isServer())
	{	
		this.server_setTeamNum(250);
	
		for (int i = 0; i < (1 + XORRandom(2)); i++)
		{
			server_CreateBlob("commanderchicken", -1, this.getPosition() + Vec2f(64 - XORRandom(32), 0));
		}
		
		CBlob@[] blobs;
		getMap().getBlobsInRadius(this.getPosition(), 256.0f, @blobs);
		u8 myTeam = this.getTeamNum();
		
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			
			if (b.hasTag("door"))
			{
				b.server_setTeamNum(250);
			}
		}
	}
}

void onTick(CBlob@ this)
{
	SetMinimap(this);
	
	if (isServer())
	{
		if(getGameTime() % 10 == 0)
		{
			CBlob@[] chickens;
			getBlobsByTag("combat chicken", @chickens);
			
			if (chickens.length < 16)
			{
				CBlob@ blob = server_CreateBlob((XORRandom(100) < 20 ? "soldierchicken" : "scoutchicken"), -1, this.getPosition() + Vec2f(16 - XORRandom(32), 0));
			}
		}
	}
}

void SetMinimap(CBlob@ this)
{
	this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
		
	if (this.hasTag("minimap_large")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(16, 8));
	else if (this.hasTag("minimap_small")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(8, 8));

	this.SetMinimapRenderAlways(true);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() == this.getTeamNum())
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

void onDie(CBlob@ this)
{
	if (isServer())
	{
		server_DropCoins(this.getPosition(), 1000 + XORRandom(1500));
	}
}