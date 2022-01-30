#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "DeityCommon.as";

void onInit(CBlob@ this)
{
	this.set_u8("deity_id", Deity::cocok);
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_Vec2f("shop offset", Vec2f(-10,0));

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("AltarCocok_Music.ogg");
	sprite.SetEmitSoundVolume(0.50f);
	sprite.SetEmitSoundSpeed(1.00f);
	sprite.SetEmitSoundPaused(false);

	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 0, 0));

	AddIconToken("$icon_cocok_follower$", "InteractionIcons.png", Vec2f(32, 32), 11);
	{
		ShopItem@ s = addShopItem(this, "Rite of Cocok", "$icon_cocok_follower$", "follower", "Gain Cocok's ushanka by offering a weapon of destruction.");
		AddRequirement(s.requirements, "blob", "mat_mininuke", "L.O.L. Warhead", 1);
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril", 50);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;

		s.spawnNothing = true;
	}

	AddIconToken("$icon_cocok_offering_0$", "AltarCocok_Icons.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Offering of Molotov", "$icon_cocok_offering_0$", "offering_molotov", "Sacrifice some lunch money to craft a Molotov Cocktail under Cocok's guidance.");
		AddRequirement(s.requirements, "blob", "vodka", "Vodka", 1);
		// AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 25);
		AddRequirement(s.requirements, "coins", "coins", "Coins", 150);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}

	AddIconToken("$icon_cocok_offering_1$", "AltarCocok_Icons.png", Vec2f(24, 24), 1);
	{
		ShopItem@ s = addShopItem(this, "Offering of Molothrower", "$icon_cocok_offering_1$", "offering_molothrower", "Sacrifice a heap of mithril to upgrade a Scorcher into a Molothrower.");
		AddRequirement(s.requirements, "blob", "flamethrower", "Scorcher", 1);
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril", 500);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}

	AddIconToken("$icon_cocok_offering_2$", "AltarCocok_Icons.png", Vec2f(24, 24), 2);
	{
		ShopItem@ s = addShopItem(this, "Offering of Bomba", "$icon_cocok_offering_2$", "offering_bomb", "Sacrifice your dignity to weld a L.O.L. and a big bomb together.");
		AddRequirement(s.requirements, "blob", "mat_mininuke", "L.O.L.", 1);
		AddRequirement(s.requirements, "blob", "mat_bigbomb", "Big Bomb", 1);
		AddRequirement(s.requirements, "blob", "mat_mithrilenriched", "Enriched Mithril", 20);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}

	// AddIconToken("$icon_cocok_offering_0$", "AltarCocok_Icons.png", Vec2f(24, 24), 0);
	// {
		// ShopItem@ s = addShopItem(this, "Offering of Death", "$icon_cocok_offering_0$", "offering_death", "Sacrifice a slave to kill a random person in this region.");
		// AddRequirement(s.requirements, "blob", "slave", "Slave's Corpse", 1);
		// s.customButton = true;
		// s.buttonwidth = 1;
		// s.buttonheight = 1;

		// s.spawnNothing = true;
	// }

	// AddIconToken("$icon_cocok_offering_1$", "AltarCocok_Icons.png", Vec2f(24, 24), 1);
	// {
		// ShopItem@ s = addShopItem(this, "Offering of Might", "$icon_cocok_offering_1$", "offering_might", "Sacrifice Juggernaut's Hammer in exchange for he Cocok Device.");
		// AddRequirement(s.requirements, "blob", "juggernauthammer", "Juggernaut Hammer", 1);
		// s.customButton = true;
		// s.buttonwidth = 1;
		// s.buttonheight = 1;

		// s.spawnNothing = true;
	// }
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	const f32 power = blob.get_f32("deity_power");
	const f32 radius = 64.00f + ((power / 100.00f) * 8.00f);
	const f32 gravity = sv_gravity * 0.03f;
	
	blob.setInventoryName("Altar of Cocok\n\nRussian Power: " + power + "\nGravitation field radius: " + radius);
	blob.SetLightRadius(radius);

	CBlob@ localBlob = getLocalPlayerBlob();
	if (localBlob !is null)
	{
		f32 diameter = radius * 2.00f;

		f32 dist = blob.getDistanceTo(localBlob);
		f32 distMod = 1.00f - (dist / diameter);
		f32 sqrDistMod = 1.00f - Maths::Sqrt(dist / radius);

		this.SetEmitSoundVolume(0.20f + (distMod * 0.20f));
	}
}

void onTick(CBlob@ this)
{
	if (!this.hasTag("cocok_gravity")) return;
	const f32 power = this.get_f32("deity_power");
	const f32 radius = 64.00f + ((power / 100.00f) * 8.00f);
	const f32 gravity = sv_gravity * 0.03f;

	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ blob = blobsInRadius[i];

			if (blob.get_u8("deity_id") != Deity::cocok && blob.hasTag("flesh"))
			{
				blob.AddForce(Vec2f(0, gravity * blob.getMass()));
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller))
	{
		if (this.hasTag("cocok_gravity")) caller.CreateGenericButton(27, Vec2f(10, 0), this, ToggleButton, "OFF");
		else caller.CreateGenericButton(23, Vec2f(10, 0), this, ToggleButton, "ON");
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void ToggleButton(CBlob@ this, CBlob@ caller)
{
	if (this.hasTag("cocok_gravity"))
	{
		this.Untag("cocok_gravity");
		this.getSprite().SetEmitSoundPaused(true);
	}
	else
	{
		this.Tag("cocok_gravity");
		this.getSprite().SetEmitSoundPaused(false);
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
						this.add_f32("deity_power", 100);
						if (isServer()) this.Sync("deity_power", false);

						if (isClient())
						{
							// if (callerBlob.get_u8("deity_id") != Deity::cocok)
							// {
								// client_AddToChat(callerPlayer.getCharacterName() + " has become a follower of Cocok.", SColor(255, 255, 0, 0));
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
							callerPlayer.set_u8("deity_id", Deity::cocok);
							callerPlayer.Sync("deity_id", false);

							callerBlob.set_u8("deity_id", Deity::cocok);
							callerBlob.Sync("deity_id", false);
						}
					}
					else
					{
						if (data == "offering_molotov")
						{
							this.add_f32("deity_power", 10);
							if (isServer()) this.Sync("deity_power", false);

							if (isServer())
							{
								CBlob@ item = server_CreateBlob("mat_molotov", this.getTeamNum(), this.getPosition());
								callerBlob.server_Pickup(item);
							}
						}
						else if (data == "offering_molothrower")
						{
							this.add_f32("deity_power", 50);
							if (isServer()) this.Sync("deity_power", false);

							if (isServer())
							{
								CBlob@ item = server_CreateBlob("molothrower", this.getTeamNum(), this.getPosition());
								callerBlob.server_Pickup(item);
							}
						}
						else if (data == "offering_bomb")
						{
							this.add_f32("deity_power", 400);
							if (isServer()) this.Sync("deity_power", false);

							if (isServer())
							{
								CBlob@ item = server_CreateBlob("mat_cocokbomb", this.getTeamNum(), this.getPosition());
								callerBlob.server_Pickup(item);
							}
						}
					}
				}
			}
		}
	}
}
