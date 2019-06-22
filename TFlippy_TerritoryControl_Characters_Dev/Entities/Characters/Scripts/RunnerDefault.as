#include "RunnerCommon.as";
#include "Hitters.as";
#include "Knocked.as"
#include "FireCommon.as"
#include "Help.as"
#include "Survival_Structs.as";
#include "Logging.as";

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

				if (upkeep_ratio <= UPKEEP_RATIO_BONUS_HEALTH) 
				{ 
					//every minute  60*30
					if (getGameTime() % (60*30) == 0)
					{
						f32 maxHealth = Maths::Ceil(this.getInitialHealth()*4.0f);
						if (this.getHealth() < maxHealth)
						{				
							if (isServer())
							{
								this.server_SetHealth(Maths::Min(this.getHealth() + 0.125f, maxHealth));
							}

							if (isClient())
							{
								for (int i = 0; i < 4; i++)
								{
									ParticleAnimated("HealParticle.png", this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), Vec2f(0, f32(XORRandom(100) * -0.02f)) * 0.25f, 0, 0.5f, 10, 0, true);
								}
							}
						}
					}
				}
			}
		}
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (getNet().isClient() && this.isMyPlayer())
	{
		CCamera@ cam = getCamera();
		cam.setRotation(0, 0, 0);
		
		if (getNet().isClient() && this.isMyPlayer()) 
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
	if ((customData == Hitters::suicide || customData == Hitters::nothing) && getKnocked(this) > 0)
	{
		damage = 0;
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
			print_log(this, "has picked up " + attached.getConfig());
		}
		// print_log(player.getUsername() + " (" + this.getConfig() + ", team " + this.getTeamNum() + ") has picked up " + attached.getConfig());
		
	}
	
	if (getNet().isClient())
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
		print_log(this, "has dropped " + detached.getConfig());
	}

	this.getSprite().SetZ(0.0f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob !is this && (this.hasTag("migrant") || this.hasTag("dead"));
}
