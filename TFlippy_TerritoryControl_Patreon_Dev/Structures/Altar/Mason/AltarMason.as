#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "DeityCommon.as";

void onInit(CBlob@ this)
{
	this.set_u8("deity_id", Deity::mason);
	this.set_Vec2f("shop menu size", Vec2f(3, 2));

	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 180, 0));

	//this.set_f32("deity_power",10000); //for testing if the cap is actually working

	this.getCurrentScript().tickFrequency = 15;

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
	{
		ShopItem@ s = addShopItem(this, "Building for Dummies", "$artisancertificate$", "artisancertificate", "Simplified Builder manuscript for building cooperation.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Engineer's Tools", "$engineertools$", "engineertools", "Engineer's Tools for advanced builders.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4);

		s.spawnNothing = true;
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	const f32 power = blob.get_f32("deity_power");
	blob.setInventoryName("Altar of Grand Mason\n\nMasonic Power: " + power + "\nFree block chance: " + Maths::Min((power * 0.01f),MAX_FREE_BLOCK_CHANCE) + "%");
}

void onTick(CBlob@ this)
{
	const f32 power = this.get_f32("deity_power");
	float range = Maths::Sqrt(power) + 10.0f; //area around altar that will be affected by stone autorepair
	int tileChecks = range / 4 + 5; //the amount of times we'll check random tiles until a tile that is hurt is found
	//print(range+": Range, "+ tileChecks+": TileChecks");

	Random rand(getGameTime());

	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	Vec2f topLeft = pos - Vec2f((range / 2.0f) * 8.0f, (range / 2.0f) * 8.0f);

	if (isServer())
	{
		for (int i = 0; i < tileChecks; i++)
		{
			Vec2f tileWorldPos = topLeft + Vec2f(rand.NextFloat() * range * 8.0f, rand.NextFloat() * range * 8.0f); 
			TileType tile = map.getTile(tileWorldPos).type;

			//Castle back block
			switch(tile)
			{
				case CMap::tile_castle_back + 13:
				case CMap::tile_castle_back + 14:
				case CMap::tile_castle_back + 15:
					map.server_SetTile(tileWorldPos, tile - 1);
					break;
				case CMap::tile_castle_back + 12:
				case CMap::tile_castle_moss:
					map.server_SetTile(tileWorldPos, CMap::tile_castle_back);
					break;
			}

			//Castle block
			if (map.isTileCastle(tile) && tile != CMap::tile_castle)
			{
				if (tile > CMap::tile_castle_d1 && tile != CMap::tile_castle_moss)
				{
					//repair by one
					map.server_SetTile(tileWorldPos, tile - 1);
				}
				else
				{
					//set to castle block since repairing would mess it up
					map.server_SetTile(tileWorldPos, CMap::tile_castle);
				}
				break;
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
					else if(isServer())
					{
						string[] spl = data.split("-");
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
	}
}