#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "DeityCommon.as";
#include "MakeSeed.as";

void onInit(CBlob@ this)
{
	this.set_u8("deity_id", Deity::swaglag);
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("AltarSwagLag_Music.ogg");
	sprite.SetEmitSoundVolume(0.40f);
	sprite.SetEmitSoundSpeed(1.00f);
	sprite.SetEmitSoundPaused(false);
	
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 170, 255, 61));
	
	AddIconToken("$icon_swaglag_follower$", "InteractionIcons.png", Vec2f(32, 32), 11);
	{
		ShopItem@ s = addShopItem(this, "Rite of Swag", "$icon_swaglag_follower$", "follower", "Gain swag by offering some Protopopov leaves.");
		// AddRequirement(s.requirements, "blob", "dew", "Protopopov Leaves", 150);
		// AddRequirement(s.requirements, "blob", "protopopovbulb", "Protopopov Bulb", 1);
		AddRequirement(s.requirements, "blob", "dew", "Mountain Dew", 1);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_swaglag_offering_0$", "AltarSwagLag_Icons.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Offering of Protopopov", "$icon_swaglag_offering_0$", "offering_protopopov", "Use some mithril and grain to create a Protopopov seed.");
		AddRequirement(s.requirements, "blob", "mat_mithrilenriched", "Enriched Mithril", 10);
		AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_swaglag_offering_1$", "AltarSwagLag_Icons.png", Vec2f(24, 24), 1);
	{
		ShopItem@ s = addShopItem(this, "Offering of MLG", "$icon_swaglag_offering_1$", "offering_mlg", "Sacrifice some Mountain Dew to convert a sniper rifle into an MLG.");
		AddRequirement(s.requirements, "blob", "sniper", "UPF Sniper Rifle", 1);
		AddRequirement(s.requirements, "blob", "dew", "Mountain Dew", 3);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_swaglag_offering_2$", "AltarSwagLag_Icons.png", Vec2f(24, 24), 2);
	{
		ShopItem@ s = addShopItem(this, "Offering of Doritos", "$icon_swaglag_offering_2$", "offering_doritos", "Sacrifice some money to buy Doritos from the built-in vending machine.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller))
	{
		if (this.hasTag("colourful"))
			caller.CreateGenericButton(27, Vec2f(0, -12), this, ToggleButton, "Sound OFF");
		else
				caller.CreateGenericButton(23, Vec2f(0, -12), this, ToggleButton, "Sound ON");
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void ToggleButton(CBlob@ this, CBlob@ caller)
{
	if (this.hasTag("colourful"))
	{
		this.Untag("colourful");
		this.getSprite().SetEmitSoundPaused(true);
	}
	else
	{
		this.Tag("colourful");
		this.getSprite().SetEmitSoundPaused(false);
	}
}

void onTick(CBlob@ this)
{
	const bool server = isServer();
	const bool client = isClient();

	const f32 power = this.get_f32("deity_power");
	this.setInventoryName("Altar of SwagLag\n\nMLG Power: " + power + "\nGun damage bonus: +" + Maths::Min(power * 0.010f, 200.00f) + "%");
	
	const f32 radius = 64.00f + ((power / 100.00f) * 8.00f);
	this.SetLightRadius(radius);
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
						this.add_f32("deity_power", 250);
						if (isServer()) this.Sync("deity_power", false);
						
						if (isClient())
						{
							// if (callerBlob.get_u8("deity_id") != Deity::swaglag)
							// {
								// client_AddToChat(callerPlayer.getCharacterName() + " has become a follower of SwagLag.", SColor(255, 255, 0, 0));
							// }
							
							CBlob@ localBlob = getLocalPlayerBlob();
							if (localBlob !is null)
							{
								if (this.getDistanceTo(localBlob) < 128)
								{
									this.getSprite().PlaySound("MLG_Hit", 2.00f, 1.00f);
									this.getSprite().PlaySound("MLG_Airhorn", 2.00f, 1.00f);
									SetScreenFlash(255, 255, 255, 255, 3.00f);
								}
							}
						}
						
						if (isServer())
						{
							callerPlayer.set_u8("deity_id", Deity::swaglag);
							callerPlayer.Sync("deity_id", false);
							
							callerBlob.set_u8("deity_id", Deity::swaglag);
							callerBlob.Sync("deity_id", false);
						}
					}
					else
					{
						if (data == "offering_protopopov")
						{
							this.add_f32("deity_power", 500);
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
							this.add_f32("deity_power", 1000);
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
							this.add_f32("deity_power", 10);
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