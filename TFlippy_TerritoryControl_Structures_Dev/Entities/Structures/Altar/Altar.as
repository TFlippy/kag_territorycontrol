#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "DeityCommon.as";

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

	if (!this.exists("deity_id")) this.set_u8("deity_id", Deity::none);
	
	if (this.getName() == "altar")
	{
		this.set_Vec2f("shop menu size", Vec2f(6, 2));
		this.set_string("shop description", "Select a Deity");
		this.set_u8("shop icon", 15);
		// this.Tag(SHOP_AUTOCLOSE);
		
		AddIconToken("$icon_mithrios$", "Altar.png", Vec2f(24, 32), 1);
		AddIconToken("$icon_ivan$", "Altar.png", Vec2f(24, 32), 2);
		AddIconToken("$icon_gregor$", "Altar.png", Vec2f(24, 32), 3);
		
		{
			ShopItem@ s = addShopItem(this, "Mithrios, Deity of Death", "$icon_mithrios$", "altar_mithrios", "A demon known for his cruelty and hunger for blood.\n\nAfter being banished from the mortal realm, he returned as a weapon of destruction.\n\n120% base running speed\n5% damage resistance per follower");
			AddRequirement(s.requirements, "blob", "slaveball", "Slave Ball", 1);
			AddRequirement(s.requirements, "blob", "mat_meat", "Meat", 250);
			AddRequirement(s.requirements, "coin", "", "Coins", 1500);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Ivan, Deity of Ivan", "$icon_ivan$", "altar_ivan", "A squatter worshipped by anarchists, slavs and those who indulge in drinking.\n\nAfter annoying the Illuminati Council and being banished three times, a cult worshipping him formed.\n\nImmunity to enslavement\nAnti-faction field around altar");
			AddRequirement(s.requirements, "blob", "vodka", "Vodka", 4);
			AddRequirement(s.requirements, "coin", "", "Coins", 1000);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Gregor Builder, Deity of Destruction", "$icon_gregor$", "altar_gregor", "A deranged inventor known for his bizarre contraptions - such as the deadly ebola rune.\n\nOne day after being beaten in a wizard duel, he threatened to wipe out the entire world. The Illuminati Council removed him from existence for one month instead.");
			AddRequirement(s.requirements, "blob", "builder", "Virgin Builder Corpse", 1);
			AddRequirement(s.requirements, "blob", "artisancertificate", "Building for Dummies", 1);
			AddRequirement(s.requirements, "coin", "", "Coins", 2000);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
	}
	else
	{
		this.set_f32("deity_power", 100);
	
		this.set_Vec2f("shop menu size", Vec2f(2, 2));
		this.set_string("shop description", "Make an offering");
		this.set_u8("shop icon", 15);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (this.getName() == "altar")
	{
		if (isServer())
		{
			if (cmd == this.getCommandID("shop made item"))
			{
				u16 caller, item;
				if (!params.saferead_netid(caller) || !params.saferead_netid(item)) return;
				string data = params.read_string();
				
				Vec2f pos = this.getPosition();
				u8 team = this.getTeamNum();
			
				this.getSprite().PlaySound("/Construct.ogg");
				this.getSprite().getVars().gibbed = true;
				
				if (isServer())
				{
					CBlob@ newBlob = server_CreateBlob(data, team, pos);
					this.server_Die();
				}
			}
		}
	}
}

void onDie(CBlob@ this)
{
	u8 self_deity_id = this.get_u8("deity_id");

	int count = getPlayerCount();
	for (int i = 0; i < count; i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player !is null)
		{
			if (player.get_u8("deity_id") == self_deity_id)
			{
				player.set_u8("deity_id", 0);
				
				CBlob@ blob = player.getBlob();
				if (blob !is null)
				{
					blob.set_u8("deity_id", 0);
				}
			}
		}
	}
}