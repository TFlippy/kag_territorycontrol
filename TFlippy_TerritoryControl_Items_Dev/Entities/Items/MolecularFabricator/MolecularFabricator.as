// #include "MakeMat.as";
#include "MakeCrate.as";
#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-25); //background

	AddIconToken("$icon_scythergib$", "ScytherGib.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_chargerifle$", "ChargeRifle.png", Vec2f(26, 8), 0);
	AddIconToken("$icon_chargelance$", "ChargeLance.png", Vec2f(32, 16), 0);
	AddIconToken("$icon_molecularfabricator$", "MolecularFabricator.png", Vec2f(32, 16), 0);
	AddIconToken("$icon_matter_0$", "Material_Matter.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_matter_1$", "Material_Matter.png", Vec2f(16, 16), 1);
	AddIconToken("$icon_matter_2$", "Material_Matter.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_matter_3$", "Material_Matter.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_plasteel$", "Material_Plasteel.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_coilgun$", "Coilgun_Icon.png", Vec2f(48, 16), 0);
	AddIconToken("$icon_scyther$", "Scyther.png", Vec2f(24, 24), 0);

	addTokens(this); //colored shop icons

	this.set_f32("pickup_priority", 8.00f); // The lower, the higher priority

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(5, 7));
	this.set_string("shop description", "Molecular Fabricator");
	this.set_u8("shop icon", 15);

	{
		ShopItem@ s = addShopItem(this, "Deconstruct 10 Plasteel Sheets", "$icon_matter_0$", "mat_matter-10", "Deconstruct 10 Plasteel Sheets into 10 units of Amazing Technicolor Dust.");
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 10);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Deconstruct a Busted Scyther Component", "$icon_matter_1$", "mat_matter-25", "Deconstruct 1 Busted Scyther Component into 25 units of Amazing Technicolor Dust.");
		AddRequirement(s.requirements, "blob", "scythergib", "Busted Scyther Component", 1);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 5);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Deconstruct a Charge Rifle", "$icon_matter_1$", "mat_matter-150", "Deconstruct 1 Charge Rifle into 150 units of Amazing Technicolor Dust.");
		AddRequirement(s.requirements, "blob", "chargerifle", "Charge Rifle", 1);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 20);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Deconstruct a Charge Lance", "$icon_matter_2$", "mat_matter-500", "Deconstruct 1 Charge Lance into 500 units of Amazing Technicolor Dust.");
		AddRequirement(s.requirements, "blob", "chargelance", "Charge Lance", 1);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 20);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Deconstruct an Exosuit", "$icon_matter_3$", "mat_matter-250", "Deconstruct 1 Exosuit into 250 units of Amazing Technicolor Dust.");
		AddRequirement(s.requirements, "blob", "exosuititem", "Exosuit", 1);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 25);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Transmute Stone to Copper", "$mat_iron$", "mat_iron-250", "Transmute 250 Stone into 250 Iron Ore.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 35);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Transmute Iron to Copper", "$mat_copper$", "mat_copper-250", "Transmute 250 Iron Ore into 250 Copper Ore.");
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron Ore", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Transmute Copper to Gold", "$mat_gold$", "mat_gold-250", "Transmute 250 Copper Ore into 250 Gold Ore.");
		AddRequirement(s.requirements, "blob", "mat_copper", "Copper Ore", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 135);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Transmute Gold to Mithril", "$mat_mithril$", "mat_mithril-250", "Transmute 250 Gold Ore into 250 Mithril Ore.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold Ore", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Refine Mithril", "$mat_mithrilingot$", "mat_mithrilingot-2", "Refine 10 Mithril Ore into 2 Mithril Ingots.");
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril Ore", 10);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Portable Molecular Fabricator", "$icon_molecularfabricator$", "molecularfabricator", "A highly advanced machine capable of restructuring molecules and atoms.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 25);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 10);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 2);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Force Field Generator", "$icon_fieldgenerator$", "fieldgenerator", "A high-tech force field generator. Strikes anything that is made of flesh and doesn't match its internal filter.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 50);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 25);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 5);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct 10 Metal Rods", "$mat_lancerod$", "mat_lancerod-10", "A bundle of 10 charge lance rods.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct 10 Plasteel Sheets", "$icon_plasteel$", "mat_plasteel-10", "A durable yet lightweight material.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 10);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 1);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Charge Rifle", "$icon_chargerifle$", "chargerifle", "A burst-fire energy weapon.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 50);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 25);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Charge Lance", "$icon_chargelance$", "chargelance", "An extremely powerful rail-assisted handheld cannon.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 150);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 250);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Charge Pistol", "$chargepistol$", "chargepistol", "A handheld energy pistol");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 25);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 10);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 2);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Charge Blaster", "$chargeblaster$", "chargeblaster", "A rapid-fire energy minigun.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 50);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 20);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct an Inferno Cannon", "$infernocannon$", "infernocannon", "An energy cannon that shoots out an incendiary projectile.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 200);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 75);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 20);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Partical Cannon", "$forceray$", "forceray", "A partical cannon that uses mithril.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 200);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 75);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 50);
		s.spawnNothing = true;
	}
	/*
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Callahan", "$callahan$", "callahan", "Callahan Full-bore Auto Lock. Aim assist assault rifle.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 75);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct an Oof-007", "$icon_oof$", "oof", "Destroyer of worlds.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 150);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 150);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 10);
		s.spawnNothing = true;
	}
	*/
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Coilgun", "$icon_coilgun$", "coilgun", "A rapid firing mounted gun. Uses Mithril as ammunition.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 50);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 200);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Translocator (2)", "$icon_teleporter$", "teleporter", "A pair of matter exchange-based teleportation devices.\n\nRadius scales with amount of mithril inside.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 50);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Scyther", "$icon_scyther$", "scyther", "A light combat mechanoid equipped with a Charge Lance.");
		AddRequirement(s.requirements, "blob", "scythergib", "Busted Scyther Component", 1);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 25);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 20);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 5);
		AddRequirement(s.requirements, "blob", "chargelance", "Charge Lance", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Hoverbike", "$icon_hoverbike$", "hoverbike", "An extremely fast hoverbike utilizing levitators.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 40);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 20);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 2);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct an Exosuit", "$icon_exosuit$", "exosuititem", "A Model II Exosuit with a shield module.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 100);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 8);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Busted Scyther Component", "$icon_scythergib$", "scythergib", "A completely useless garbage, brand new.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 25);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 2);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 1);
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

	AddIconToken("$icon_fieldgenerator$", "FieldGenerator.png", Vec2f(24, 24), 0, teamnum);
	AddIconToken("$icon_exosuit$", "ExosuitItem.png", Vec2f(16, 10), 0, teamnum);
	AddIconToken("$icon_hoverbike$", "Hoverbike.png", Vec2f(24, 16), 2, teamnum);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", (caller.getPosition() - this.getPosition()).Length() < 64.0f);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/MolecularFabricator_Create.ogg");

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
			else if(spl[0] == "scyther")
			{
				CBlob@ crate = server_MakeCrate("scyther", "Scyther Construction Kit", 0, callerBlob.getTeamNum(), this.getPosition(), false);
				crate.Tag("plasteel");
				crate.Init();

				callerBlob.server_Pickup(crate);
			}
			else if (spl[0] == "molecularfabricator")
			{
				CBlob@ crate = server_MakeCrate("molecularfabricator", "Molecular Fabricator Construction Kit", 0, callerBlob.getTeamNum(), this.getPosition(), false);
				crate.Tag("plasteel");
				crate.Init();

				callerBlob.server_Pickup(crate);
			}
			else if (spl[0] == "coilgun")
			{
				CBlob@ crate = server_MakeCrate("coilgun", "Coilgun Construction Kit", 0, callerBlob.getTeamNum(), this.getPosition(), false);
				crate.Tag("plasteel");
				crate.Init();

				callerBlob.server_Pickup(crate);
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
