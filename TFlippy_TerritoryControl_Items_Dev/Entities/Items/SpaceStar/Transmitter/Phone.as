// ArcherShop.as

#include "MakeCrate.as";
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
	AddIconToken("$ss_badger$", "SS_Icons.png", Vec2f(32, 16), 0);
	AddIconToken("$ss_scout_raid$", "SS_Icons.png", Vec2f(16, 16), 2);
	AddIconToken("$ss_soldier_raid$", "SS_Icons.png", Vec2f(16, 16), 4);
	AddIconToken("$ss_minefield$", "SS_Icons.png", Vec2f(16, 16), 3);
	AddIconToken("$ss_shelling$", "SS_Icons.png", Vec2f(16, 32), 4);

	this.getCurrentScript().tickFrequency = 1;
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 3));
	this.set_string("shop description", "SpaceStar Ordering!");
	this.set_u8("shop icon", 11);
	
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem(this, "Wonderful Fluffy UPF Badger!", "$ss_badger$", "badger-parachute", "Every child's dream! Don't hesitate and get your own Wonderful Fluffy Badger!");
		AddRequirement(s.requirements, "coin", "", "Coins", 199);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Portable Minefield!", "$ss_minefield$", "minefield", "A brave flock of landmines! No more trespassers!");
		AddRequirement(s.requirements, "coin", "", "Coins", 799);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Artillery Barrage! (10x)", "$ss_shelling$", "barrage-10", "When things go awry, there's still an option to shell it to oblivion.");
		AddRequirement(s.requirements, "coin", "", "Coins", 3499);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Artillery Barrage! (25x)", "$ss_shelling$", "barrage-25", "When things go really awry, there's still an option to shell it to oblivion even harder! (with a small discount)");
		AddRequirement(s.requirements, "coin", "", "Coins", 5999);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Recon Squad!", "$ss_scout_raid$", "scout_raid", "Have you lost something? Order our willing recon squad, and you will sure find what you're looking for!");
		AddRequirement(s.requirements, "coin", "", "Coins", 799);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Assault Squad!", "$ss_soldier_raid$", "soldier_raid", "Get your own soldier... TODAY!");
		AddRequirement(s.requirements, "coin", "", "Coins", 1499);
		
		s.spawnNothing = true;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound(XORRandom(100) > 50 ? "/ss_order.ogg" : "/ss_shipment.ogg");
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		
		if (callerBlob is null) return;
		
		if (getNet().isServer())
		{
			string[] spl = name.split("-");

			if (spl.length > 1)
			{
				if (spl[1] == "parachute")
				{
					CBlob@ blob = server_MakeCrateOnParachute(spl[0], "SpaceStar Ordering Goods", 0, 250, Vec2f(callerBlob.getPosition().x, 0));
					blob.Tag("unpack on land");
				}
				else if (spl[0] == "barrage")
				{
					print("barrage");
				
					CBlob@ b = server_CreateBlobNoInit("bombardment");
					b.server_setTeamNum(250);
					b.setPosition(this.getPosition());
					
					b.set_u8("max shots fired", parseInt(spl[1]));
					b.set_u32("delay between shells", 15);
					b.set_string("shell blob", "chickencannonshell");
					
					b.Init();
				}
			}
			else
			{
				if (spl[0] == "scout_raid")
				{
					for (int i = 0; i < 4; i++)
					{
						CBlob@ blob = server_MakeCrateOnParachute("scoutchicken", "SpaceStar Ordering Recon Squad", 0, 250, Vec2f(callerBlob.getPosition().x + (64 - XORRandom(128)), XORRandom(32)));
						blob.Tag("unpack on land");
						blob.Tag("destroy on touch");
					}
				}
				else if (spl[0] == "soldier_raid")
				{
					for (int i = 0; i < 4; i++)
					{
						CBlob@ blob = server_MakeCrateOnParachute("soldierchicken", "SpaceStar Ordering Assault Squad", 0, 250, Vec2f(callerBlob.getPosition().x + (64 - XORRandom(128)), XORRandom(32)));
						blob.Tag("unpack on land");
						blob.Tag("destroy on touch");
					}
				}
				else if (spl[0] == "minefield")
				{
					for (int i = 0; i < 10; i++)
					{
						CBlob@ blob = server_MakeCrateOnParachute("mine", "SpaceStar Ordering Mines", 0, 250, Vec2f(callerBlob.getPosition().x + (256 - XORRandom(512)), XORRandom(64)));
						blob.Tag("unpack on land");
						blob.Tag("destroy on touch");
					}
				}
				else
				{
					print("rip " + spl[0]);
				}
			}
		}

		this.set_bool("shop available", false);
		this.set_u32("next use", getGameTime() + 300);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.getSprite().PlaySound("/ss_hello.ogg");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_bool("shop available", getGameTime() >= this.get_u32("next use"));
}