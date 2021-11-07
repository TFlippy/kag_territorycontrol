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

	// this.Tag("upkeep building");
	// this.set_u8("upkeep cap increase", 0);
	// this.set_u8("upkeep cost", 5);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	AddIconToken("$filled_bucket$", "bucket.png", Vec2f(16, 16), 1);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(3, 4));
	this.set_string("shop description", "Bookworm's Lair");
	this.set_u8("shop icon", 15);
	// this.set_Vec2f("class offset", Vec2f(-6, 0));
	// this.set_string("required class", "builder");

	{
		ShopItem@ s = addShopItem(this, "Chemistry Blueprint", "$bp_chemistry$", "bp_chemistry", "The blueprint for the automated druglab.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 7500);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Adv Automation Blueprint", "$bp_automation_advanced$", "bp_automation_advanced", "The blueprint for the automated chicken assembler.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 6750);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Energetics Blueprint", "$bp_energetics$", "bp_energetics", "The blueprint for the beam tower.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5000);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Chemistry", "$COIN$", "coin-1500", "Sell blueprint for 1500 coins.");
		AddRequirement(s.requirements, "blob", "bp_chemistry", "Chemistry Blueprint", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Adv Automation", "$COIN$", "coin-1000", "Sell blueprint for 1000 coins.");
		AddRequirement(s.requirements, "blob", "bp_automation_advanced", "Adv Automation Blueprint", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Energetics", "$COIN$", "coin-750", "Sell blueprint for 750 coins.");
		AddRequirement(s.requirements, "blob", "bp_energetics", "Energetics Blueprint", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Upgrading", "$paper$", "paper-upgrade", "Learn an interesting fact about upgrading laboratories");
		AddRequirement(s.requirements, "coin", "", "Coins", 10000);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Armor", "$paper$", "paper-armor", "Learn an interesting fact about armor and equipment.");
		AddRequirement(s.requirements, "coin", "", "Coins", 1000);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Drug Information", "$paper$", "paper-drug", "Learn an interesting fact about creating drugs.");
		AddRequirement(s.requirements, "coin", "", "Coins", 2000);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Random Facts", "$paper$", "paper-random", "Want to learn a random fact eh?");
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
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
			else if (spl[0] == "paper")
			{
				string text = "Nothing";
				if (spl[1] == "upgrade")
				{
					switch (XORRandom(4))
					{
						case 0:
							text = "You can upgrade lab with copper ingots.";
							break;
						case 1:
							text = "You can upgrade lab with steel ingots.";
							break;
						case 2:
							text = "You can upgrade reactor with mithril ingots.";
							break;
						case 3:
							text = "You can upgrade reactor with steel ingots.";
							break;
					}
				}
				else if (spl[1] == "armor")
				{
					switch (XORRandom(5))
					{
						case 0:
							text = "Armor has durability! Repair armor in armories if badly damaged.";
							break;
						case 1:
							text = "Helmets can absorb up to 25 hearts.";
							break;
						case 2:
							text = "Bulletproof Vests can absorb up to 30 hearts.";
							break;
						case 3:
							text = "Armor from armories aren't the only equipment that offers protection.";
							break;
						case 4:
							text = "The more damaged your armor, the less effective it is.";
							break;
					}
				}
				else if (spl[1] == "drug")
				{
					switch (XORRandom(5))
					{
						case 0:
							text = "You can make acid and methane by adding meat to druglab, and when the heat is greater than 300, press react!";
							break;
						case 1:
							text = "Druglabs explode when the pressure goes over its limit.";
							break;
						case 2:
							text = "Stim Recipe: 25,000 pressure, 400 heat; 50 acid, 50 sulphur.";
							break;
						case 3:
							text = "Gooby Recipe: 25,000 pressure, 1000 heat; 45 High Grade Meat(HG meat).";
							break;
						case 4:
							text = "Explodium Recipe: Less than 300 heat; 15 High Grade Meat(HG meat).";
							break;
					}
				}
				else if (spl[1] == "random")
				switch (XORRandom(21))
				{
					case 0:
						text = "You could get enriched mithril while making domino in older versions of tc!";
						break;
					case 1:
						text = "`The only cure is death.` - TFlippy";
						break;
					case 2:
						text = "`Vamist finally caught participating in illegal activities` - TFlippy";
						break;
					case 3:
						text = "TFlippy left TC to make TC2 :kag_cry:";
						break;
					case 4:
						text = "You can make pumpkin/grain farms and sell your crops for coins at the Merchant.";
						break;
					case 5:
						text = "South Africa is a country and not a region mind blowing";
						break;
					case 6:
						text = "Vamist once carried crates for a living. L moment";
						break;
					case 7:
						text = "Firework Kungfu will one day return";
						break;
					case 8:
						text = "JimTheSmith paid $50 for a blue role on discord... bruh";
						break;
					case 9:
						text = "Dark will one day make TC CTF... prob 2050";
						break;
					case 10:
						text = "TC2 will one day replace the current TC";
						break;
					case 11:
						text = "In TC, there was a Great Clan War back in 2018, involving the clans: DARK and USSR";
						break;
					case 12:
						text = "Mithrios may one day return...";
						break;
					case 13:
						text = "Mithrios, DarkSlayer, and Gingerbeard once formed a pact prior to USSR";
						break;
					case 14:
						text = "You can get TC2 right now, go to: www.patreon.com/tflippy";
						break;
					case 15:
						text = "Rajang has a history of spawning 50+ firewaves in TC...";
						break;
					case 16:
						text = "gog is the best player in TC";
						break;
					case 17:
						text = "There once existed a man named advan who created a clan named Ivan, and now has an altar called Ivan Altar.";
						break;
					case 18:
						text = "There once was a man/devil named Mithrios who brought havoc to TC, so he was nerfed, as his power was too great, which had brought unbalance to TC.";
						break;
					case 19:
						text = "Magic was banned in TC due to the great wizard wars back then";
						break;
					case 20:
						text = "Back then, guns did not exist in TC, so nor did UPF";
						break;
				}

				CBlob@ paper = server_CreateBlobNoInit("paper");
				paper.setPosition(this.getPosition());
				paper.server_setTeamNum(this.getTeamNum());
				paper.set_string("text", text);
				paper.Init();
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
