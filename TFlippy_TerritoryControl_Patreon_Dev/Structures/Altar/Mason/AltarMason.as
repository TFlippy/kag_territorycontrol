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
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Disc_MountainKing.ogg");
	sprite.SetEmitSoundVolume(0.40f);
	sprite.SetEmitSoundSpeed(1.00f);
	sprite.SetEmitSoundPaused(false);
	
	AddIconToken("$icon_mason_follower$", "InteractionIcons.png", Vec2f(32, 32), 11);
	{
		ShopItem@ s = addShopItem(this, "Rite of Grand Mason", "$icon_mason_follower$", "follower", "Gain Grand Mason's respect by offering him a huge pile of rocks.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 1000);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	const f32 power = blob.get_f32("deity_power");
	blob.setInventoryName("Altar of Grand Mason\n\nMasonic Power: " + power + "\nFree block chance: " + (power * 0.01f) + "%");
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
						if (isServer()) this.Sync("deity_power", false);
						
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