#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "DeityCommon.as";

const f32 radius = 128.0f;
	
void onInit(CBlob@ this)
{
	this.set_u8("deity_id", Deity::mithrios);

	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("DemonicLoop.ogg");
	sprite.RewindEmitSound();
	sprite.SetEmitSoundPaused(false);
	
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 0, 0));
	
	AddIconToken("$icon_mithrios_follower$", "InteractionIcons.png", Vec2f(32, 32), 11);
	{
		ShopItem@ s = addShopItem(this, "Become a follower of Mithrios", "$icon_mithrios_follower$", "follower", "Gain Mithrios's interest by offering him a dead peasant and some meat.");
		AddRequirement(s.requirements, "blob", "peasant", "Peasant's Corpse", 1);
		AddRequirement(s.requirements, "blob", "mat_meat", "Mystery Meat", 100);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
	
	// AddIconToken("$icon_mithrios_offering_0$", "AltarMithrios_Icons.png", Vec2f(24, 24), 0);
	// {
		// ShopItem@ s = addShopItem(this, "Offering of Flesh", "$icon_mithrios_offering_0$", "offering_flesh", "Sacrifice an unidentifiable carcass for a Demonic Artifact.");
		// AddRequirement(s.requirements, "blob", "mat_meat", "Meat", 50);
		// s.customButton = true;
		// s.buttonwidth = 1;	
		// s.buttonheight = 1;
		
		// s.spawnNothing = true;
	// }
	
	AddIconToken("$icon_mithrios_offering_0$", "AltarMithrios_Icons.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Offering of Death", "$icon_mithrios_offering_0$", "offering_death", "Sacrifice a slave to kill a random person in this region.");
		AddRequirement(s.requirements, "blob", "slave", "Slave's Corpse", 1);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
	
	AddIconToken("$icon_mithrios_offering_1$", "AltarMithrios_Icons.png", Vec2f(24, 24), 1);
	{
		ShopItem@ s = addShopItem(this, "Offering of Might", "$icon_mithrios_offering_1$", "offering_might", "Sacrifice Juggernaut's Hammer in exchange for he Mithrios Device.");
		AddRequirement(s.requirements, "blob", "juggernauthammer", "Juggernaut Hammer", 1);
		s.customButton = true;
		s.buttonwidth = 1;	
		s.buttonheight = 1;
		
		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	const bool server = isServer();
	const bool client = isClient();

	const f32 power = this.get_f32("deity_power");
	this.setInventoryName("Altar of Mithrios\n\nDemonic Power: " + power + "\nDamage Reflection: " + (power * 0.01f) + "%");
	
	CBlob@ playerBlob = getLocalPlayerBlob();
	if (playerBlob !is null)
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetFrameIndex(0);
		sprite.SetEmitSoundPaused(false);
	
		Vec2f diff = playerBlob.getPosition() - this.getPosition();
		f32 dist = diff.getLength();
		
		if (dist < radius)
		{
			f32 invFactor = (dist / radius);
			f32 factor = 1.00f - invFactor;
			
			sprite.SetEmitSoundVolume(factor);
			sprite.SetEmitSoundSpeed(0.50f + (0.50f * invFactor) + Maths::Min(power * 0.0005f, 0.35f));
			
			SetScreenFlash(Maths::Clamp((50 * factor) + XORRandom(10 + (power * 0.02)) + (power * 0.005f), 0, 255), 64, 0, 0);
			ShakeScreen((25 * factor) + (power * 0.0050f), 30, this.getPosition());
			
			if (playerBlob.get_u8("deity_id") != Deity::mithrios)
			{
				CControls@ controls = getControls();
				Driver@ driver = getDriver();

				Vec2f spos = driver.getScreenPosFromWorldPos(this.getPosition());
				Vec2f dir = (controls.getMouseScreenPos() - spos);
				// dir.Normalize();
				
				controls.setMousePosition(controls.getMouseScreenPos() - (dir * 0.01f * factor));
			}
			
			if (getGameTime() > this.get_u32("next_whisper"))
			{
				if (XORRandom(100 * (invFactor)) == 0)
				{
					this.set_u32("next_whisper", getGameTime() + 30 * 10);
					this.getSprite().PlaySound("dem_whisper_" + XORRandom(6), 0.75f * factor, 0.75f);
				}
			}
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
						this.add_f32("deity_power", 50);
						
						if (isClient())
						{
							if (callerBlob.get_u8("deity_id") != Deity::mithrios)
							{
								client_AddToChat(callerPlayer.getCharacterName() + " has become a follower of Mithrios.", SColor(255, 255, 0, 0));
							}
							
							CBlob@ localBlob = getLocalPlayerBlob();
							if (localBlob !is null)
							{
								if (this.getDistanceTo(localBlob) < 128)
								{
									this.getSprite().PlaySound("mysterious_perc_05.ogg", 2.00f, 1.00f);
								}
							}
						}
						
						if (isServer())
						{
							callerPlayer.set_u8("deity_id", Deity::mithrios);
							callerPlayer.Sync("deity_id", false);
							
							callerBlob.set_u8("deity_id", Deity::mithrios);
							callerBlob.Sync("deity_id", false);
						}
					}
					else
					{
						if (data == "offering_flesh")
						{
							this.add_f32("deity_power", 25);
							
							if (isServer())
							{
								CMap@ map = getMap();
							
								float x = this.getPosition().x + (128 - XORRandom(256));
								Vec2f pos;
								
								if(map.rayCastSolid(Vec2f(x, 0.0f), Vec2f(x, map.tilemapheight * map.tilesize), pos))
								{
									CBlob@ artifact = server_CreateBlob("demonicartifact", this.getTeamNum(), pos);
									CBlob@ lightning = server_CreateBlob("lightningbolt", this.getTeamNum(), pos);
								}
							}
						}
						else if (data == "offering_death")
						{
							this.add_f32("deity_power", 50);
							
							int count = getPlayerCount();
							CPlayer@ player = getPlayer(XORRandom(count));
							if (player !is null)
							{
								CBlob@ blob = player.getBlob();
								if (blob !is null)
								{
									if (isClient())
									{
										client_AddToChat(player.getCharacterName() + " has been turned inside-out by Mithrios.", SColor(255, 255, 0, 0));
										ShakeScreen(48.0f, 32.0f, blob.getPosition());
									
										blob.getSprite().PlaySound("Pigger_Gore", 1.00f, 1.00f);
										blob.getSprite().Gib();
										
										ParticleBloodSplat(blob.getPosition(), true);
									}
									
									if (isServer())
									{
										blob.server_Die();
									}
								}
							}
						}
						else if (data == "offering_might")
						{
							this.add_f32("deity_power", 150);
							
							if (isServer())
							{
								CMap@ map = getMap();
							
								float x = this.getPosition().x + (128 - XORRandom(256));
								Vec2f pos;
								
								if(map.rayCastSolid(Vec2f(x, 0.0f), Vec2f(x, map.tilemapheight * map.tilesize), pos))
								{
									CBlob@ gun = server_CreateBlob("mithrios", this.getTeamNum(), pos);
									CBlob@ lightning = server_CreateBlob("lightningbolt", this.getTeamNum(), pos);
								}
							}
						}
					}
				}				
			}
		}
	}
}