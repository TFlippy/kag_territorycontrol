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
	AddIconToken("$ss_guns$", "SS_Icons.png", Vec2f(32, 16), 3);
	AddIconToken("$ss_ammo$", "SS_Icons.png", Vec2f(32, 16), 4);
	AddIconToken("$ss_sam$", "SS_Icons.png", Vec2f(32, 24), 4);
	AddIconToken("$ss_lws$", "SS_Icons.png", Vec2f(32, 24), 5);
	AddIconToken("$ss_machinegun$", "SS_Icons.png", Vec2f(32, 24), 6);

	this.getCurrentScript().tickFrequency = 1;
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", "SpaceStar Ordering!");
	this.set_u8("shop icon", 11);
	
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem(this, "Wonderful Fluffy UPF Badger!", "$ss_badger$", "badger-parachute", "Every child's dream! Don't hesitate and get your own Wonderful Fluffy Badger!");
		AddRequirement(s.requirements, "coin", "", "Coins", 199);
		
		s.spawnNothing = true;
	}

	// {
		// ShopItem@ s = addShopItem(this, "UPF Artillery Barrage! (10x)", "$ss_shelling$", "barrage-10", "When things go awry, there's still an option to shell it to oblivion.");
		// AddRequirement(s.requirements, "coin", "", "Coins", 3499);
		
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "UPF Artillery Barrage! (25x)", "$ss_shelling$", "barrage-25", "When things go really awry, there's still an option to shell it to oblivion even harder! (with a small discount)");
		// AddRequirement(s.requirements, "coin", "", "Coins", 5999);
		
		// s.spawnNothing = true;
	// }
	{
		ShopItem@ s = addShopItem(this, "UPF Recon Squad!", "$ss_scout_raid$", "scout_raid", "Have you lost something? Order our willing recon squad, and you will sure find what you're looking for!");
		AddRequirement(s.requirements, "coin", "", "Coins", 1299);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Assault Squad!", "$ss_soldier_raid$", "soldier_raid", "Get your own soldier... TODAY!");
		AddRequirement(s.requirements, "coin", "", "Coins", 1799);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Weapon Package!", "$ss_guns$", "gun_package", "Assorted gun collection! Become a proud owner of UPF's best-selling armaments, now with a huge discount!");
		AddRequirement(s.requirements, "coin", "", "Coins", 3499);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Ammunition Package!", "$ss_ammo$", "ammo_package", "Surrounded by enemies? Dump some ammunition in them!");
		AddRequirement(s.requirements, "coin", "", "Coins", 899);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Portable SAM System!", "$ss_sam$", "sam-parachute_no_unpack", "A portable surface-to-air missile system used to shoot down aerial targets. Automatically operated!");
		AddRequirement(s.requirements, "coin", "", "Coins", 4499);
		
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Portable LWS!", "$ss_lws$", "lws-parachute_no_unpack", "A portable laser weapon system capable of shooting down airborne projectiles. Automatically operated!");
		AddRequirement(s.requirements, "coin", "", "Coins", 3999);
		
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Portable Minefield!", "$ss_minefield$", "minefield", "A brave flock of landmines! No more trespassers!");
		AddRequirement(s.requirements, "coin", "", "Coins", 799);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Frag Grenades!", "$fraggrenade$", "frag_package", "Angry at humans? Throw a pack of frag grenades at them!");
		AddRequirement(s.requirements, "coin", "", "Coins", 499);
		
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Portable Machine Gun!", "$ss_machinegun$", "machinegun-parachute_no_unpack", "Humans disturbing your precious sleep? Mow them down with our Portable Machine Gun!");
		AddRequirement(s.requirements, "coin", "", "Coins", 1299);
		
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
		
		if (isServer())
		{
			string[] spl = name.split("-");

			if (spl.length > 1)
			{
				if (spl[1] == "parachute")
				{
					CBlob@ blob = server_MakeCrateOnParachute(spl[0], "SpaceStar Ordering Goods", 0, 250, Vec2f(callerBlob.getPosition().x, 0));
					blob.Tag("unpack on land");
				}
				else if (spl[1] == "parachute_no_unpack")
				{
					CBlob@ blob = server_MakeCrateOnParachute(spl[0], "SpaceStar Ordering Goods", 0, 250, Vec2f(callerBlob.getPosition().x, 0));
				}
				else if (spl[0] == "barrage")
				{
				
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
				string name = spl[0];
				if (name == "scout_raid")
				{
					for (int i = 0; i < 4; i++)
					{
						CBlob@ blob = server_MakeCrateOnParachute("scoutchicken", "SpaceStar Ordering Recon Squad", 0, 250, Vec2f(callerBlob.getPosition().x + (64 - XORRandom(128)), XORRandom(32)));
						blob.Tag("unpack on land");
						blob.Tag("destroy on touch");
					}
				}
				else if (name == "soldier_raid")
				{
					for (int i = 0; i < 4; i++)
					{
						CBlob@ blob = server_MakeCrateOnParachute("soldierchicken", "SpaceStar Ordering Assault Squad", 0, 250, Vec2f(callerBlob.getPosition().x + (64 - XORRandom(128)), XORRandom(32)));
						blob.Tag("unpack on land");
						blob.Tag("destroy on touch");
					}
				}
				else if (name == "minefield")
				{
					for (int i = 0; i < 10; i++)
					{
						CBlob@ blob = server_MakeCrateOnParachute("mine", "SpaceStar Ordering Mines", 0, 250, Vec2f(callerBlob.getPosition().x + (256 - XORRandom(512)), XORRandom(64)));
						blob.Tag("unpack on land");
						blob.Tag("destroy on touch");
					}
				}
				else if (name == "frag_package")
				{
						CBlob@ frag = server_MakeCrateOnParachute("mat_fraggrenade", "SpaceStar Ordering Weapon Package", 0, 250, Vec2f(callerBlob.getPosition().x + (64 - XORRandom(128)), XORRandom(32)));
						frag.Tag("unpack on land");
						frag.Tag("destroy on touch");
						frag.set_u8("count", 8);
				}
				else if (name == "gun_package")
				{
					for (int i = 0; i < 3; i++)
					{
						string gun_config;
					
						switch (XORRandom(15))
						{
							case 0:
							{
								gun_config = "beagle";
							}
							break;
							
							case 1:
							{
								gun_config = "carbine";
							}
							break;
							
							case 2:
							{
								gun_config = "assaultrifle";
							}
							break;
							
							case 3:
							{
								gun_config = "silencedrifle";
							}
							break;
							
							case 4:
							{
								gun_config = "napalmer";
							}
							break;
							
							case 5:
							{
								gun_config = "autoshotgun";
							}
							break;
							
							case 6:
							{
								gun_config = "fuger";
							}
							break;
							
							case 7:
							{
								gun_config = "pdw";
							}
							break;
							
							case 8:
							{
								gun_config = "sar";
							}
							break;
							
							case 9:
							{
								gun_config = "sniper";
							}
							break;
							
							case 10:
							{
								gun_config = "uzi";
							}
							break;
							
							case 11:
							{
								gun_config = "amr";
							}
							break;
							
							case 12:
							{
								gun_config = "minigun";
							}
							break;
							
							case 13:
							{
								gun_config = "sgl";
							}
							break;
							
							case 14:
							{
								gun_config = "rpg";
							}
							break;
						}
						
						CBlob@ gun = server_MakeCrateOnParachute(gun_config, "SpaceStar Ordering Weapon Package", 0, 250, Vec2f(callerBlob.getPosition().x + (64 - XORRandom(128)), XORRandom(32)));
						gun.Tag("unpack on land");
						gun.Tag("destroy on touch");
					}
				}
				else if (name == "ammo_package")
				{
					for (int i = 0; i < 4; i++)
					{
						string ammo_config;
						u32 ammo_count;
					
						switch (i)
						{
							case 0:							
							{
								ammo_config = "mat_gatlingammo";
								ammo_count = 250;
							}
							break;
							
							case 1:
							{
								ammo_config = "mat_rifleammo";
								ammo_count = 100;
							}
							break;
							
							case 2:
							{
								ammo_config = "mat_pistolammo";
								ammo_count = 200;
							}
							break;
							
							case 3:
							{
								ammo_config = "mat_shotgunammo";
								ammo_count = 50;
							}
							break;

						}
						
						CBlob@ ammo = server_MakeCrateOnParachute(ammo_config, "SpaceStar Ordering Weapon Package", 0, 250, Vec2f(callerBlob.getPosition().x + (64 - XORRandom(128)), XORRandom(32)));
						ammo.Tag("unpack on land");
						ammo.Tag("destroy on touch");
						ammo.set_u8("count", ammo_count);
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