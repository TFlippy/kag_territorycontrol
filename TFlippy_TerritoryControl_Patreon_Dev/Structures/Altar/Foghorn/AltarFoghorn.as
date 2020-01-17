#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "DeityCommon.as";
#include "MakeSeed.as";

void onInit(CBlob@ this)
{
	this.set_u8("deity_id", Deity::foghorn);
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("ChickenMarch.ogg");
	sprite.SetEmitSoundVolume(0.40f);
	sprite.SetEmitSoundSpeed(1.00f);
	sprite.SetEmitSoundPaused(false);
	
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 170, 255, 61));
	
	AddIconToken("$icon_foghorn_follower$", "InteractionIcons.png", Vec2f(32, 32), 11);
	{
		ShopItem@ s = addShopItem(this, "UPF Entry Permit", "$icon_foghorn_follower$", "follower", "Gain swag by offering some Protopopov leaves.");
		// AddRequirement(s.requirements, "blob", "dew", "Protopopov Leaves", 150);
		// AddRequirement(s.requirements, "blob", "protopopovbulb", "Protopopov Bulb", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 3999);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_foghorn_offering_0$", "AltarFoghorn_Icons.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Offering of Protopopov", "$icon_foghorn_offering_0$", "offering_protopopov", "Use some mithril and grain to create a Protopopov seed.");
		AddRequirement(s.requirements, "blob", "mat_mithrilenriched", "Enriched Mithril", 10);
		AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_foghorn_offering_1$", "AltarFoghorn_Icons.png", Vec2f(24, 24), 1);
	{
		ShopItem@ s = addShopItem(this, "Offering of MLG", "$icon_foghorn_offering_1$", "offering_mlg", "Sacrifice some Mountain Dew to convert a sniper rifle into an MLG.");
		AddRequirement(s.requirements, "blob", "sniper", "UPF Sniper Rifle", 1);
		AddRequirement(s.requirements, "blob", "dew", "Mountain Dew", 3);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_foghorn_offering_2$", "AltarFoghorn_Icons.png", Vec2f(24, 24), 2);
	{
		ShopItem@ s = addShopItem(this, "Offering of Doritos", "$icon_foghorn_offering_2$", "offering_doritos", "Sacrifice some money to buy Doritos from the built-in vending machine.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	
	if (isServer())
	{
		CBlob@ chicken = server_CreateBlob("ambassadorchicken", 250, this.getPosition());
	}
	
	this.set_f32("deity_power", 0);
}

void onTick(CBlob@ this)
{
	const bool server = isServer();
	const bool client = isClient();

	const f32 reputation = this.get_f32("deity_power");
	this.setInventoryName("Altar of Foghorn\n\nUPF Reputation: " + reputation + "\n");
	
	if (this.getTickSinceCreated() % 30 == 0)
	{
		if (reputation < -5000 && getGameTime() >= this.get_u32("next_shelling"))
		{
			CBlob@ b = server_CreateBlobNoInit("bombardment");
			b.server_setTeamNum(250);
			b.setPosition(this.getPosition() + Vec2f(128 - XORRandom(256), 0));
			
			b.set_u8("max shots fired", 15);
			b.set_u32("delay between shells", 15);
			b.set_string("shell blob", "chickencannonshell");
			
			b.Init();
			
			this.set_u32("next_shelling", getGameTime() + (30 * 120));
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		u16 caller, item;
		if (params.saferead_netid(caller) && params.saferead_netid(item))
		{
			string data = params.read_string();
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob !is null)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer !is null)
				{
					if (data == "follower")
					{
						this.add_f32("deity_power", 1500);
						if (isServer()) this.Sync("deity_power", false);
						
						if (isClient())
						{
							// if (callerBlob.get_u8("deity_id") != Deity::foghorn)
							// {
								// client_AddToChat(callerPlayer.getCharacterName() + " has become a follower of Foghorn.", SColor(255, 255, 0, 0));
							// }
							
							// CBlob@ localBlob = getLocalPlayerBlob();
							// if (localBlob !is null)
							// {
								// if (this.getDistanceTo(localBlob) < 128)
								// {
									// this.getSprite().PlaySound("MLG_Hit", 2.00f, 1.00f);
									// this.getSprite().PlaySound("MLG_Airhorn", 2.00f, 1.00f);
									// SetScreenFlash(255, 255, 255, 255, 3.00f);
								// }
							// }
							
							
						}
						
						callerPlayer.set_u8("deity_id", Deity::foghorn);
						callerBlob.set_u8("deity_id", Deity::foghorn);
						
						if (isServer())
						{
							callerPlayer.Sync("deity_id", false);
							callerBlob.Sync("deity_id", false);
						}
					}
					else
					{
						if (data == "offering_protopopov")
						{
							this.add_f32("deity_power", 150);
							if (isServer()) this.Sync("deity_power", false);
							
							if (isServer())
							{
								CBlob@ item = server_MakeSeed(this.getPosition(), "protopopov_plant");
								callerBlob.server_Pickup(item);
							}
							
							if (isClient())
							{
								this.getSprite().PlaySound("MLG_Hit", 2.00f, 1.00f);
							}
						}
						else if (data == "offering_mlg")
						{
							this.add_f32("deity_power", 200);
							if (isServer()) this.Sync("deity_power", false);
							
							if (isServer())
							{
								CBlob@ item = server_CreateBlob("mlg", this.getTeamNum(), this.getPosition());
								callerBlob.server_Pickup(item);
							}
							
							if (isClient())
							{
								this.getSprite().PlaySound("MLG_Hit", 2.00f, 1.00f);
							}
						}
						else if (data == "offering_doritos")
						{
							this.add_f32("deity_power", 1);
							if (isServer()) this.Sync("deity_power", false);
							
							if (isServer())
							{
								CBlob@ item = server_CreateBlob("doritos", this.getTeamNum(), this.getPosition());
								callerBlob.server_Pickup(item);
							}
							
							if (isClient())
							{
								this.getSprite().PlaySound("MLG_Hit", 2.00f, 1.00f);
							}
						}
					}
				}				
			}
		}
	}
}