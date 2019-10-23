#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";

// A script by TFlippy

// Mithrios
	// Bonuses: Mithrios head for followers, +5% running speed with each follower, 20% damage resistance
	// Offering: Meat
	
// Ivan
	// Bonuses: Drunken speech for followers, shrine plays old tavern music, slaving immunity, ???
	// Offering: Vodka
	
// Gregor Builder
	// Bonuses: 
	// Offering: 

// Barsuk
	// Bonuses: 
	// Offering: 
	
// Barlth
	// Bonuses: 
	// Offering: 

void onInit(CSprite@ this)
{
	
}

void onInit(CBlob@ this)
{
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6, 2));
	this.set_string("shop description", "Select a Deity");
	this.set_u8("shop icon", 15);
	// this.Tag(SHOP_AUTOCLOSE);
	
	AddIconToken("$icon_mithrios$", "InteractionIcons.png", Vec2f(32, 32), 0);
	AddIconToken("$icon_ivan$", "InteractionIcons.png", Vec2f(32, 32), 1);
	
	{
		ShopItem@ s = addShopItem(this, "Mithrios, Deity of Death", "$icon_mithrios$", "altar_mithrios", "A demon known for his cruelty and hunger for power. After being banished from the mortal realm, he returned as a weapon of destruction.\n\n120% base running speed\n5% damage resistance per follower");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 500);
		AddRequirement(s.requirements, "blob", "mat_meat", "Meat", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Ivan, Deity of Ivan", "$icon_ivan$", "altar_ivan", "A squatter worshipped by anarchists, slavs and those who indulge in drinking. After annoying the higher beings, he has been banished thrice, which gained him a cult following.\n\nImmunity to enslavement\nAnti-faction field around altar");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 500);
		AddRequirement(s.requirements, "blob", "vodka", "Vodka", 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gregor Builder, Deity of Madness", "$icon_gregor$", "altar_gregor", "An ancient inventor known for his insane contraptions, such as the formidable ebola rune. After threatening to destroy the world, he has been banished from existence by the Creators themselves.\n\n");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 500);
		AddRequirement(s.requirements, "blob", "vodka", "Vodka", 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	
}

// void GetButtonsFor(CBlob@ this, CBlob@ caller)
// {
	// if (this.getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
	
	// CBitStream params;
	// params.write_u16(caller.getNetworkID());

	// CInventory @inv = caller.getInventory();
	// if(inv is null) return;

	// if(inv.getItemsCount() > 0)
	// {
		// params.write_u16(caller.getNetworkID());
		// CButton@ buttonOwner = caller.CreateGenericButton(28, Vec2f(0, 8), this, this.getCommandID("sv_store"), "Store", params);
	// }
// }

// void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
// {
	// if (getNet().isServer())
	// {
		// if (cmd == this.getCommandID("sv_store"))
		// {
			// CBlob@ caller = getBlobByNetworkID(params.read_u16());
			// if (caller !is null)
			// {
				// CInventory @inv = caller.getInventory();
				// if (caller.getName() == "builder")
				// {
					// CBlob@ carried = caller.getCarriedBlob();
					// if (carried !is null)
					// {
						// if (carried.hasTag("temp blob"))
						// {
							// carried.server_Die();
						// }
					// }
				// }
				// if (inv !is null)
				// {
					// while (inv.getItemsCount() > 0)
					// {
						// CBlob @item = inv.getItem(0);
						// caller.server_PutOutInventory(item);
						// this.server_PutInInventory(item);
					// }
				// }
			// }
		// }
	// }
// }

// bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
// {
	// return forBlob.isOverlapping(this);
// }