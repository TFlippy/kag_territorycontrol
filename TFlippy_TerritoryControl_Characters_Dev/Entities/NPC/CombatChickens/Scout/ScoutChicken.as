// Princess brain

#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";
#include "ThrowCommon.as";

void onInit(CBlob@ this)
{
	this.getSprite().addSpriteLayer("isOnScreen","NoTexture.png",1,1);
	this.set_u32("nextAttack", 0);
	this.set_u32("nextBomb", 0);

	this.set_f32("minDistance", 32);
	this.set_f32("chaseDistance", 200);
	this.set_f32("maxDistance", 400);

	this.set_f32("inaccuracy", 0.025f);
	this.set_u8("reactionTime", 20);
	this.set_u8("attackDelay", 0);
	this.set_bool("bomber", false);
	this.set_bool("raider", true);

	this.SetDamageOwnerPlayer(null);

	this.Tag("can open door");
	this.Tag("combat chicken");
	this.Tag("npc");
	this.Tag("flesh");
	this.Tag("player");

	this.getCurrentScript().tickFrequency = 1;

	this.set_f32("voice pitch", 1.50f);

	if (isServer())
	{
		this.set_u16("stolen coins", 250);

		this.server_setTeamNum(250);

		string gun_config;
		string ammo_config;

		switch(XORRandom(15))
		{
			case 0:
			case 1:
			case 2:
				gun_config = "carbine";
				ammo_config = "mat_rifleammo";

				this.set_u8("attackDelay", 3);
				this.set_u8("reactionTime", 30);
				this.set_f32("chaseDistance", 100);
				this.set_f32("minDistance", 32);
				this.set_f32("maxDistance", 350);

				break;

			case 3:
			case 4:
			case 5:
				gun_config = "shotgun";
				ammo_config = "mat_shotgunammo";

				this.set_u8("reactionTime", 30);
				this.set_u8("attackDelay", 30);
				this.set_f32("chaseDistance", 48);
				this.set_f32("minDistance", 8);
				this.set_f32("maxDistance", 400);

				break;

			case 6:
			case 7:
				gun_config = "sar";
				ammo_config = "mat_rifleammo";

				this.set_u8("reactionTime", 30);
				this.set_u8("attackDelay", 6);
				this.set_f32("chaseDistance", 400);
				this.set_f32("minDistance", 64);
				this.set_f32("maxDistance", 600);

				break;

			case 8:
				gun_config = "silencedrifle";
				ammo_config = "mat_rifleammo";

				this.set_u8("reactionTime", 30);
				this.set_u8("attackDelay", 10);
				this.set_f32("chaseDistance", 400);
				this.set_f32("minDistance", 64);
				this.set_f32("maxDistance", 600);

				break;

			case 9:
			case 10:
				gun_config = "uzi";
				ammo_config = "mat_pistolammo";

				this.set_u8("attackDelay", 0);
				this.set_u8("reactionTime", 10);
				this.set_f32("chaseDistance", 100);
				this.set_f32("minDistance", 32);
				this.set_f32("maxDistance", 400);

				break;

			case 11:
			case 12:
			case 13:
				gun_config = "pdw";
				ammo_config = "mat_pistolammo";

				this.set_u8("attackDelay", 1);
				this.set_u8("reactionTime", 30);
				this.set_f32("chaseDistance", 100);
				this.set_f32("minDistance", 8);
				this.set_f32("maxDistance", 300);
				
				break;
				
			default:
				gun_config = "fuger";
				ammo_config = "mat_pistolammo";

				this.set_u8("reactionTime", 20);
				this.set_u8("attackDelay", 20);
				this.set_f32("chaseDistance", 120);
				this.set_f32("minDistance", 32);
				this.set_f32("maxDistance", 400);

				break;
		}

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

		// CBrain@ brain = this.getBrain();
		// if (brain !is null)
		// {

		// }
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 14, Vec2f(16, 16));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

void onTick(CBlob@ this)
{
	// if(isClient())
	// {
		// if (!this.getSprite().getSpriteLayer("isOnScreen").isOnScreen())
		// {
			// return;
		// }
	// }

	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 1.25f;
		moveVars.jumpFactor *= 1.80f;
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

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			// this.getSprite().PlaySound("scoutchicken_vo_perish.ogg", 0.8f, 1.5f);
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
	
	if (this.isMyPlayer())
	{
		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
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

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum();
}