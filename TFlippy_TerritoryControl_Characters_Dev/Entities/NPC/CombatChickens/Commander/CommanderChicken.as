// Princess brain

#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";
#include "MakeCrate.as";
#include "ThrowCommon.as";
#include "Survival_Structs.as";

u32 next_commander_event = 0; // getGameTime() + (30 * 60 * 5) + XORRandom(30 * 60 * 5));
bool dry_shot = true;

void onInit(CBlob@ this)
{
	this.set_u32("nextAttack", 0);
	this.set_u32("nextBomb", 0);

	this.set_f32("minDistance", 32);
	this.set_f32("chaseDistance", 200);
	this.set_f32("maxDistance", 400);

	this.set_f32("inaccuracy", 0.01f);
	this.set_u8("reactionTime", 20);
	this.set_u8("attackDelay", 0);
	this.set_bool("bomber", false);
	this.set_bool("raider", false);

	// this.set_u32("next_event", getGameTime() + (30 * 60 * 5) + XORRandom(30 * 60 * 5));

	next_commander_event = getGameTime(); // + (30 * 60 * 5) + XORRandom(30 * 60 * 5));
	this.addCommandID("commander_order_recon_squad");

	this.SetDamageOwnerPlayer(null);

	this.Tag("can open door");
	this.Tag("combat chicken");
	this.Tag("npc");
	this.Tag("flesh");
	this.Tag("player");

	this.getCurrentScript().tickFrequency = 1;

	this.set_f32("voice pitch", 1.50f);
	this.getSprite().addSpriteLayer("isOnScreen","NoTexture.png",1,1);
	if (isServer())
	{
		this.set_u16("stolen coins", 850);

		this.server_setTeamNum(250);

		string gun_config;
		string ammo_config;

		switch(XORRandom(6))
		{
			case 0:
				gun_config = "autoshotgun";
				ammo_config = "mat_shotgunammo";

				this.set_u8("reactionTime", 10);
				this.set_u8("attackDelay", 5);
				this.set_f32("chaseDistance", 50);
				this.set_f32("minDistance", 8);
				this.set_f32("maxDistance", 400);
				this.set_bool("bomber", true);
				this.set_f32("inaccuracy", 0.00f);

				break;

			case 1:
			case 2:
				gun_config = "sar";
				ammo_config = "mat_rifleammo";
				
				this.set_u8("reactionTime", 30);
				this.set_u8("attackDelay", 6);
				this.set_f32("chaseDistance", 400);
				this.set_f32("minDistance", 64);
				this.set_f32("maxDistance", 600);
				
				break;

			case 3:
			case 4:
				gun_config = "pdw";
				ammo_config = "mat_pistolammo";
				
				this.set_u8("attackDelay", 1);
				this.set_u8("reactionTime", 30);
				this.set_f32("chaseDistance", 100);
				this.set_f32("minDistance", 8);
				this.set_f32("maxDistance", 300);
				
				break;		

			default:
				gun_config = "beagle";
				ammo_config = "mat_rifleammo";

				this.set_u8("reactionTime", 2);
				this.set_u8("attackDelay", 2);
				this.set_f32("chaseDistance", 100);
				this.set_f32("minDistance", 32);
				this.set_f32("maxDistance", 300);
				this.set_f32("inaccuracy", 0.00f);
				break;
		}

		CBlob@ phone = server_CreateBlob("phone", this.getTeamNum(), this.getPosition());
		this.server_PutInInventory(phone);

		if (XORRandom(100) < 60) 
		{
			CBlob@ bp_auto = server_CreateBlob("bp_automation_advanced", -1, this.getPosition());
			this.server_PutInInventory(bp_auto);
		}

		if (XORRandom(100) < 80) 
		{
			CBlob@ bp_sdr = server_CreateBlob("bp_energetics", -1, this.getPosition());
			this.server_PutInInventory(bp_sdr);
		}

		// gun and ammo
		CBlob@ ammo = server_CreateBlob(ammo_config, this.getTeamNum(), this.getPosition());
		ammo.server_SetQuantity(ammo.maxQuantity);
		this.server_PutInInventory(ammo);

		CBlob@ gun = server_CreateBlob(gun_config, this.getTeamNum(), this.getPosition());
		if(gun !is null)
		{
			this.server_Pickup(gun);
			
			if (gun.hasCommandID("reload"))
			{
				CBitStream stream;
				gun.SendCommand(gun.getCommandID("reload"), stream);
			}
		}
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 17, Vec2f(16, 16));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

void onTick(CBlob@ this)
{
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 1.15f;
		moveVars.jumpFactor *= 1.50f;
	}

	if (this.getHealth() < 0.0 && this.hasTag("dead"))
	{
		this.getSprite().PlaySound("Wilhelm.ogg", 1.8f, 1.8f);

		if (isServer())
		{
			this.server_SetPlayer(null);
			server_DropCoins(this.getPosition(), Maths::Max(0, Maths::Min(this.get_u16("stolen coins"), 5000)));
			CBlob@ carried = this.getCarriedBlob();

			if (carried !is null)
			{
				carried.server_DetachFrom(this);
			}
		}

		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}

	if (this.isMyPlayer())
	{
		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}
	}

	if (isServer())
	{
		if (getGameTime() >= next_commander_event)
		{
			CBlob@[] bases;
			getBlobsByTag("faction_base", @bases);
			u16 base_netid = 0;

			if (bases.length > 0) 
			{
				CBlob@ base = bases[XORRandom(bases.length)];
				if (base !is null)
				{
					next_commander_event = getGameTime() + (30 * 60 * 5) + XORRandom(30 * 60 * 20);
					if(dry_shot)
					{
						dry_shot = false;
					}
					else
					{
						f32 map_width = getMap().tilemapwidth * 8;
						f32 initial_position_x = Maths::Clamp(base.getPosition().x + (80 - XORRandom(160)) * 8.00f, 256.00f, map_width - 256.00f);

						CBitStream stream;
						stream.write_u16(base.getNetworkID());
						this.SendCommand(this.getCommandID("commander_order_recon_squad"), stream);

						for (int i = 0; i < 4; i++)
						{
							CBlob@ blob = server_MakeCrateOnParachute("scoutchicken", "SpaceStar Ordering Recon Squad", 0, 250, Vec2f(initial_position_x + (64 - XORRandom(128)), XORRandom(32)));
							blob.Tag("unpack on land");
							blob.Tag("destroy on touch");
						}
					}
				}
			}
			else
			{
				next_commander_event = getGameTime() + 2*((30 * 60 * 5) + XORRandom(30 * 60 * 20));
				dry_shot = true;
			}
		}
	}

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			// this.getSprite().PlaySound("scoutchicken_vo_perish.ogg", 0.8f, 1.5f);
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 50)
		{
			this.getSprite().PlaySound("scoutchicken_vo_hit" + (1 + XORRandom(3)) + ".ogg", 1, 0.8f);
			this.set_u32("next sound", getGameTime() + 60);
		}
	}

	return damage;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("commander_order_recon_squad"))
	{
		CBlob@ target = getBlobByNetworkID(params.read_u16());
		if (target !is null)
		{
			CTeam@ team = getRules().getTeam(target.getTeamNum());
			if (team !is null)
			{
				client_AddToChat("An UPF Recon Squad has been called upon " + GetTeamName(target.getTeamNum()) + "'s " + target.getInventoryName() + "!", SColor(255, 255, 0, 0));
				Sound::Play("ChickenMarch.ogg", target.getPosition(), 1.00f, 1.00f);
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum();
}
