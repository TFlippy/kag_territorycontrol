#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "DeityCommon.as";

void onInit(CBlob@ this)
{
	this.set_u8("deity_id", Deity::mason);
	this.set_Vec2f("shop menu size", Vec2f(2, 2));

	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 180, 0));
	
	AddIconToken("$icon_mason_follower$", "InteractionIcons.png", Vec2f(32, 32), 11);
	{
		ShopItem@ s = addShopItem(this, "Rite of Grand Mason", "$icon_mason_follower$", "follower", "Gain Grand Mason's respect by offering him a huge pile of rocks.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 1000);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
	
	// AddIconToken("$icon_mason_offering_0$", "AltarMason_Icons.png", Vec2f(24, 24), 0);
	// {
		// ShopItem@ s = addShopItem(this, "Offering of Flesh", "$icon_mason_offering_0$", "offering_flesh", "Sacrifice an unidentifiable carcass for a Demonic Artifact.");
		// AddRequirement(s.requirements, "blob", "mat_meat", "Meat", 50);
		// s.customButton = true;
		// s.buttonwidth = 1;	
		// s.buttonheight = 1;
		
		// s.spawnNothing = true;
	// }
	
	// AddIconToken("$icon_mason_offering_0$", "AltarMason_Icons.png", Vec2f(24, 24), 0);
	// {
		// ShopItem@ s = addShopItem(this, "Offering of Death", "$icon_mason_offering_0$", "offering_death", "Sacrifice a slave to kill a random person in this region.");
		// AddRequirement(s.requirements, "blob", "slave", "Slave's Corpse", 1);
		// s.customButton = true;
		// s.buttonwidth = 1;	
		// s.buttonheight = 1;
		
		// s.spawnNothing = true;
	// }
	
	// AddIconToken("$icon_mason_offering_1$", "AltarMason_Icons.png", Vec2f(24, 24), 1);
	// {
		// ShopItem@ s = addShopItem(this, "Offering of Might", "$icon_mason_offering_1$", "offering_might", "Sacrifice Juggernaut's Hammer in exchange for he Mason Device.");
		// AddRequirement(s.requirements, "blob", "juggernauthammer", "Juggernaut Hammer", 1);
		// s.customButton = true;
		// s.buttonwidth = 1;	
		// s.buttonheight = 1;
		
		// s.spawnNothing = true;
	// }
}

void onTick(CBlob@ this)
{
	const bool server = isServer();
	const bool client = isClient();

	const f32 power = this.get_f32("deity_power");
	this.setInventoryName("Altar of Grand Mason\n\nMasonic Power: " + power + "\nFree block chance: " + (power * 0.01f) + "%");
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
						this.add_f32("deity_power", 50);
						
						if (isClient())
						{
							// if (callerBlob.get_u8("deity_id") != Deity::mason)
							// {
								// client_AddToChat(callerPlayer.getCharacterName() + " has become a follower of Mason.", SColor(255, 255, 0, 0));
							// }
							
							CBlob@ localBlob = getLocalPlayerBlob();
							if (localBlob !is null)
							{
								if (this.getDistanceTo(localBlob) < 128)
								{
									this.getSprite().PlaySound("ConstructShort", 2.00f, 1.00f);
								}
							}
						}
						
						if (isServer())
						{
							callerPlayer.set_u8("deity_id", Deity::mason);
							callerPlayer.Sync("deity_id", false);
							
							callerBlob.set_u8("deity_id", Deity::mason);
							callerBlob.Sync("deity_id", false);
						}
					}
					else
					{

					}
				}				
			}
		}
	}
}