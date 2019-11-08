#include "RunnerCommon.as";
#include "Hitters.as";
#include "Knocked.as"
#include "FireCommon.as"
#include "Help.as"
#include "Survival_Structs.as";
#include "Logging.as";
#include "DeityCommon.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.Tag("medium weight");

	//default player minimap dot - not for migrants
	if (this.getName() != "migrant")
	{
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 8, Vec2f(8, 8));
	}

	this.set_s16(burn_duration , 130);

	//fix for tiny chat font
	this.SetChatBubbleFont("hud");
	this.maxChatBubbleLines = 4;

	setKnockable(this);
}

void onTick(CBlob@ this)
{
	DoKnockedUpdate(this);
	
	CRules@ rules = getRules();
	if (rules !is null)
	{
		if (rules.get_bool("raining"))
		{
			RunnerMoveVars@ moveVars;
			if (this.get("moveVars", @moveVars))
			{
				Vec2f pos = this.getPosition();
				if (!getMap().rayCastSolidNoBlobs(Vec2f(pos.x, 0), pos))
				{
					moveVars.walkFactor *= 0.95f;
					moveVars.jumpFactor *= 0.90f;
				}
			}
		}
		
		const u8 team = this.getTeamNum();
		if (team < 7)
		{
			TeamData@ team_data;
			GetTeamData(team, @team_data);
			
			if (team_data != null && team_data.upkeep_cap > 0)
			{
				u16 upkeep = team_data.upkeep;
				u16 upkeep_cap = team_data.upkeep_cap;
				f32 upkeep_ratio = f32(upkeep) / f32(upkeep_cap);
				
				RunnerMoveVars@ moveVars;
				if (this.get("moveVars", @moveVars))
				{
					if (upkeep_ratio <= UPKEEP_RATIO_BONUS_SPEED) 
					{ 
						moveVars.walkFactor *= 1.20f;
						moveVars.jumpFactor *= 1.15f;
					}
					
					if (upkeep_ratio >= UPKEEP_RATIO_PENALTY_SPEED) 
					{
						moveVars.walkFactor *= 0.80f;
						moveVars.jumpFactor *= 0.80f;
					}
				}
			}
		}
	}

	u8 deity_id = this.get_u8("deity_id");
	switch (deity_id)
	{
		case Deity::mithrios:
		{
			CBlob@ altar = getBlobByName("altar_mithrios");
			if (altar !is null)
			{
				f32 power = altar.get_f32("deity_power");
			
				RunnerMoveVars@ moveVars;
				if (this.get("moveVars", @moveVars))
				{
					moveVars.walkFactor *= 1.00f + Maths::Clamp(power * 0.00009f, 0.00f, 0.40f);
				}
				
				CBlob@[] blobs;
				getBlobsByTag("flesh", @blobs);
				
				if (getGameTime() % 90 == 0)
				{
					CBlob@ localBlob = getLocalPlayerBlob();
					if (this is localBlob)
					{
						u8 light_intensity = u8(255.00f * Maths::Clamp(power / 1000.00f, 0.00f, 1.00f));
						
						for (int i = 0; i < blobs.length; i++)
						{
							CBlob@ blob = blobs[i];
							if (blob !is null)
							{
								blob.SetLight(true);
								blob.SetLightRadius(16.00f);
								blob.SetLightColor(SColor(0, light_intensity, 0, 0)); // Currently not being reset upon altar destruction or deity change, deal with that later
							}
						}
					}
				}
			}
		}
		break;
	
		case Deity::ivan:
		{
			RunnerMoveVars@ moveVars;
			if (this.get("moveVars", @moveVars))
			{
				moveVars.walkFactor *= 1.20f;
				moveVars.jumpFactor *= 1.15f;
			}
		}
		break;
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (isClient() && this.isMyPlayer())
	{
		CCamera@ cam = getCamera();
		cam.setRotation(0, 0, 0);
		
		if (isClient() && this.isMyPlayer()) 
		{
			if (getRules().get_bool("raining"))
			{
				getMap().CreateSkyGradient("skygradient_rain.png");
			}
			else
			{
				getMap().CreateSkyGradient("skygradient.png");	
			}
		}
		print("reset camera");
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if ((customData == Hitters::suicide || customData == Hitters::nothing) && (getKnocked(this) > 0 || this.get_f32("babbyed") > 0.00f))
	{
		damage = 0;
	}

	u8 deity_id = this.get_u8("deity_id");
	switch (deity_id)
	{
		case Deity::mithrios:
		{
			if (hitterBlob !is null && hitterBlob !is this)
			{
				CBlob@ altar = getBlobByName("altar_mithrios");
				if (altar !is null)
				{
					f32 ratio = Maths::Clamp(altar.get_f32("deity_power") * 0.0001f, 0.00f, 0.50f);
					f32 inv_ratio = 1.00f - ratio;
					
					// print("" + ratio);
					
					f32 damage_reflected = Maths::Min(damage * ratio, Maths::Max(this.getHealth(), 0));
		
					print("" + damage_reflected + "/" + damage + "; took " + (damage * inv_ratio));
			
					hitterBlob.setVelocity(hitterBlob.getVelocity() - (velocity * damage_reflected * 2.00f));
					this.setVelocity(this.getVelocity() + (velocity * damage_reflected * 2.00f));
				
					if (isServer())
					{
						this.server_Hit(hitterBlob, worldPoint, velocity, damage_reflected, customData);
					}
				
					if (isClient())
					{
						this.getSprite().PlaySound("DemonicBoing", 0.50f, 2.00f);
						if (this.isMyPlayer()) SetScreenFlash(100, 50, 0, 0);			
					}
					
					damage *= inv_ratio;
				}
		
			}
		}
		break;
	}
	
	// if (hitterBlob is null) return damage;

	// AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	// if (point is null) return damage;
	
	// CBlob@ vehicle = point.getOccupied();
	
	// // print("");
	
	// if (vehicle !is null)
	// {
		// hitterBlob.server_Hit(vehicle, worldPoint, velocity, damage, customData);
	// }
	
	return damage;
}

// pick up efffects
// something was picked up

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	this.getSprite().PlaySound("/PutInInventory.ogg");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getSprite().PlaySound("/Pickup.ogg");

	if (attached !is null)
	{
		CRules@ r = getRules();
		if(r.get_bool("log"))
		{
			print_log(this, "has picked up " + attached.getName());
		}
		// print_log(player.getUsername() + " (" + this.getName() + ") has picked up " + attached.getName()
		
	}
	
	if (isClient())
	{
		RemoveHelps(this, "help throw");

		if (!attached.hasTag("activated"))
			SetHelp(this, "help throw", "", "$" + attached.getName() + "$" + "Throw    $KEY_C$", "", 2);
	}

	// check if we picked a player - don't just take him out of the box
	/*if (attached.hasTag("player"))
	this.server_DetachFrom( attached ); CRASHES*/
}

bool isDangerous(CBlob@ blob)
{
	return blob.hasTag("explosive") || blob.hasTag("isWeapon") || blob.hasTag("dangerous");
}

// set the Z back
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (detached !is null)
	{
		print_log(this, "has dropped " + detached.getName());
	}

	this.getSprite().SetZ(0.0f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob !is this && (this.hasTag("migrant") || this.hasTag("dead"));
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob !is this) && ((getKnocked(this) > 0) || (this.get_f32("babbyed") > 0) || (this.isKeyPressed(key_down)) || (this.getPlayer() is null));
}

