// A script by TFlippy

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
	this.set_TileType("background tile", CMap::tile_castle_back);

	// this.Tag("upkeep building");
	// this.set_u8("upkeep cap increase", 10);
	// this.set_u8("upkeep cost", 0);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");
	
	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);
	
	AddIconToken("$grainplant$", "NurseryIcons.png", Vec2f(16, 30), 0);
	AddIconToken("$ganjaplant$", "NurseryIcons.png", Vec2f(20, 30), 1);
	AddIconToken("$flowerplant$", "NurseryIcons.png", Vec2f(16, 16), 3);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(5, 3));
	this.set_string("shop description", "Plant Nursery");
	this.set_u8("shop icon", 15);
	
	{
		ShopItem@ s = addShopItem(this, "Grain Seed", "$grainplant$", "grain_seed", "A common food source which can be used for various tasks.\nConvert grain into seeds.");
		AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Ganja Seed", "$ganjaplant$", "ganja_seed", "A plant which is known for its drug properties.\nConvert a ganja pod into a seed.", true);
		AddRequirement(s.requirements, "blob", "ganjapod", "Ganja Pod", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 70);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Pumpkin Seed", "$pumpkin$", "pumpkin_seed", "A large squash fun for festivities.\nAttempt to convert a pumpkin into a seed.", true);
		AddRequirement(s.requirements, "blob", "pumpkin", "Pumpkin", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 80);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Pine Tree", "$tree_pine$", "pine_seed", "Create a pine tree seed.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 70);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Oak Tree", "$tree_bushy$", "bushy_seed", "Create an oak tree seed.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 70);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bush Seed", "$bush$", "bush_seed", "Create bush seeds.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Flower Seed", "$flowerplant$", "flower_seed", "Create flower seeds.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Kudzu Core", "$kudzucore$", "kudzucore", "Creates a kudzu core a quickly spreading plant which slowy damages other things, Cannot be stored", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 500);
		AddRequirement(s.requirements, "blob", "mat_dirt", "Dirt", 200);
		AddRequirement(s.requirements, "blob", "grain", "Grain", 1); 
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 1);
		//Requiring grain and a mithrilg ingot means its a lot harder to spawm since both of these ressources are harder to get on mass (instead of dirt wood and coins alone)
		s.spawnNothing = true;
	}
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
			else if(spl[0] == "grain_seed")
			{
				Random rand(getGameTime());
				server_MakeSeedsFor(@callerBlob, "grain_plant", XORRandom(3)+1);
			}
			else if(spl[0] == "bush_seed")
			{
				Random rand(getGameTime());
				server_MakeSeedsFor(@callerBlob, "bush", XORRandom(2)+1);
			}
			else if(spl[0] == "pine_seed")
			{
				Random rand(getGameTime());
				server_MakeSeedsFor(@callerBlob, "tree_pine", 1);
			}
			else if(spl[0] == "bushy_seed")
			{
				Random rand(getGameTime());
				server_MakeSeedsFor(@callerBlob, "tree_bushy", 1);
			}
			else if(spl[0] == "ganja_seed")
			{
				Random rand(getGameTime());
				server_MakeSeedsFor(@callerBlob, "ganja_plant", 1);
			}
			else if(spl[0] == "pumpkin_seed")
			{
				Random rand(getGameTime());
				server_MakeSeedsFor(@callerBlob, "pumpkin_plant", 1);
			}
			else if (spl[0] == "flower_seed")
			{
				Random rand(getGameTime());
				server_MakeSeedsFor(@callerBlob, "flowers", XORRandom(2)+1);
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