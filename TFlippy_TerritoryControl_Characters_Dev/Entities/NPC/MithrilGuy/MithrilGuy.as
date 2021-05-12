// Princess brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";
#include "MaterialCommon.as";
#include "Requirements.as";

void onInit( CBrain@ this )
{
	if (isServer())
	{
		InitBrain(this);
		this.server_SetActive(true); // always running
	}
}

void onInit(CBlob@ this)
{
	// this.Tag("npc");
	this.getSprite().addSpriteLayer("isOnScreen","NoTexture.png",1,1);
	this.Tag("flesh");
	this.Tag("player");
	this.Tag("dangerous");
	this.Tag("map_damage_dirt");

	this.set_f32("map_damage_ratio", 0.3f);
	this.set_f32("map_damage_radius", 32.0f);
	this.set_bool("map_damage_raycast", true);

	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 25, 255, 100));

	this.set_f32("voice pitch", 0.50f);

	this.server_setTeamNum(230);

	this.addCommandID("mg_spawn_pigger");
	this.addCommandID("mg_explode");

	this.set_u32("next pigger", 0);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 21, Vec2f(16, 16));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	Vec2f ul = gridmenu.getUpperLeftPosition();
	Vec2f lr = gridmenu.getLowerRightPosition();

	this.ClearGridMenusExceptInventory();
	Vec2f pos = Vec2f(lr.x, ul.y) + Vec2f(-72, 150);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(3, 1), "Abilities");

	this.set_Vec2f("InventoryPos",pos);

	AddIconToken("$mg_create_pigger$", "Pigger.png", Vec2f(16, 8), 0);
	AddIconToken("$mg_explode$", "SmallExplosion2.png", Vec2f(24, 24), 1);
	// AddIconToken("$deletesymbol$", "RuneSymbols.png", Vec2f(32, 16), 1);

	if (menu !is null)
	{
		menu.deleteAfterClick = true;
		// menu.SetCaptionEnabled(false);

		{
			CGridButton@ button = menu.AddButton("$mg_create_pigger$", "Spawn a Pigger", this.getCommandID("mg_spawn_pigger"));
			if (button !is null)
			{
				// button.SetEnabled(this.hasBlob("mat_mithril", 50));
				button.SetEnabled(getGameTime() >= this.get_u32("next pigger"));
				// button.SetHoverText("Spawn a pigger.");
				button.selectOneOnClick = false;
			}
		}
		{
			CGridButton@ button = menu.AddButton("$mg_explode$", "Explode", this.getCommandID("mg_explode"));
			if (button !is null)
			{
				button.SetEnabled(true);
				// button.SetHoverText("Spawn a pigger.");
				button.selectOneOnClick = false;
			}
		}
	}
}

void onTick(CBlob@ this)
{
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 0.40f;
		moveVars.jumpFactor *= 0.75f;
	}

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			this.getSprite().PlaySound("MithrilGuy_Scream_" + XORRandom(5) + ".ogg", 0.7f, 0.5f);
			this.set_u32("next sound", getGameTime() + 350);
		}
		if(!this.getSprite().getSpriteLayer("isOnScreen").isOnScreen()){
			return;
		}
	}

	if (isServer())
	{
		if (XORRandom(100) == 0)
		{
			CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(10 + XORRandom(20));

			this.server_Hit(this, this.getPosition(), Vec2f(), 0.125f, Hitters::stab, true);
		}
	}

	if (XORRandom(8) == 0) 
	{
		if (isServer())
		{
			CBlob@[] blobsInRadius;
			if (this.getMap().getBlobsInRadius(this.getPosition(), 96, @blobsInRadius))
			{
				for (int i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ blob = blobsInRadius[i];
					if (!blob.hasTag("flesh") || blob.hasTag("dead")) continue;

					f32 distMod = Maths::Max(0, (1.00f - ((this.getPosition() - blob.getPosition()).Length() / 64)));
					if (XORRandom(100) < 100.0f * distMod) 
					{
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.25f, HittersTC::radiation, true);

						if (blob.hasTag("human") && !blob.hasTag("transformed") && blob.getHealth() <= 0.25f && XORRandom(3) == 0)
						{
							CBlob@ man = server_CreateBlob("mithrilman", blob.getTeamNum(), blob.getPosition());
							if (blob.getPlayer() !is null) man.server_SetPlayer(blob.getPlayer());
							blob.Tag("transformed");
							blob.server_Die();
						}
					}
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("mg_explode"))
	{
		if (isServer())
		{
			this.server_Die();
		}
	}
	else if (cmd == this.getCommandID("mg_spawn_pigger"))
	{
		this.set_u32("next pigger", getGameTime() + 30 * 15);

		if (isClient())
		{
			this.getSprite().PlaySound("FleshHit.ogg", 1.00f, 1.00f);
			this.getSprite().PlaySound("Pigger_Pop_" + XORRandom(2), 1.00f, 1.00f);
			ParticleBloodSplat(this.getPosition(), true);
		}

		if (isServer())
		{
			this.server_Hit(this, this.getPosition(), Vec2f(0, 0), 1.00f + (XORRandom(300) / 100.00f), Hitters::stab, true);

			CBlob@ blob = server_CreateBlob("pigger", this.getTeamNum(), this.getPosition());
			if (blob !is null)
			{
				blob.setVelocity(Vec2f(XORRandom(8) - 4, -2 - XORRandom(4)));
			}
		}
	}
}

void onDie(CBlob@ this)
{
	this.getSprite().Gib();

	Explode(this, 96.0f, 24.0f);

	if (!isServer()) return;

	for (int i = 0; i < 8; i++)
	{
		CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());

		if (blob !is null)
		{
			blob.server_SetQuantity(10 + XORRandom(40));
			blob.setVelocity(Vec2f(XORRandom(4) - 2, -2 - XORRandom(4)));
		}
	}
}

void onTick(CBrain@ this)
{
	if (!isServer()) return;

	CBlob @blob = this.getBlob();

	if (blob.getPlayer() !is null) return;

	SearchTarget(this, false, true);
	CBlob @target = this.getTarget();

	this.getCurrentScript().tickFrequency = 30;
	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;

		const f32 distance = (target.getPosition() - blob.getPosition()).getLength();
		f32 visibleDistance;
		const bool visibleTarget = isVisible( blob, target, visibleDistance);

		if (target.hasTag("dead") || distance > 200.0f) 
		{
			CPlayer@ targetPlayer = target.getPlayer();

			this.SetTarget(null);
			return;
		}
		else if (target.isOnGround())
		{
			DefaultChaseBlob(blob, target);
		}

		LoseTarget(this, target);
	}
	else
	{
		if (XORRandom(100) < 50) RandomTurn(blob);
	}

	FloatInWater(blob); 
} 

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case HittersTC::radiation:
			return 0;
			break;

		// Kill it with fire
		case Hitters::fire:
		case Hitters::burn:
			damage *= 4.00f;
			break;
	}

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 25)
		{
			this.getSprite().PlaySound("MithrilGuy_Scream_" + (1 + XORRandom(2)) + ".ogg", 1, 0.8f);
			this.set_u32("next sound", getGameTime() + 300);
		}
	}

	if (isServer())
	{
		CBrain@ brain = this.getBrain();

		if (brain !is null && hitterBlob !is null)
		{
			if (hitterBlob.getTeamNum() != this.getTeamNum()) brain.SetTarget(hitterBlob);
		}
	}

	return damage;
}
