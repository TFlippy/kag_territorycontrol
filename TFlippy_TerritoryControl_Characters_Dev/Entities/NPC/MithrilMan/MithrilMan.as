// Princess brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";

void onInit( CBrain@ this )
{
	if (isServer())
	{
		InitBrain( this );
		this.server_SetActive( true ); // always running
	}
}

void onInit(CBlob@ this)
{
	this.getSprite().addSpriteLayer("isOnScreen","NoTexture.png",1,1);
	// this.Tag("npc");
	this.Tag("flesh");
	this.Tag("player");
	this.Tag("dangerous");

	this.Tag("map_damage_dirt");
	this.Tag("map_destroy_ground");
	this.set_f32("map_damage_ratio", 0.4f);
	this.set_f32("map_damage_radius", 32.0f);

	this.SetLight(true);
	this.SetLightRadius(16.0f);
	this.SetLightColor(SColor(255, 25, 255, 100));

	this.server_setTeamNum(230);

	this.addCommandID("mg_explode");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 21, Vec2f(16, 16));
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
		moveVars.walkFactor *= 0.60f;
		moveVars.jumpFactor *= 0.85f;
	}

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			this.getSprite().PlaySound("MithrilMan_Scream_" + XORRandom(4) + ".ogg", 0.7f, 1.0f);
			this.set_u32("next sound", getGameTime() + 210);
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
			blob.server_SetQuantity(5 + XORRandom(10));

			this.server_Hit(this, this.getPosition(), Vec2f(), 0.25f, Hitters::stab, true);
		}
	}

	if (XORRandom(10) == 0) 
	{
		if (isServer())
		{
			CBlob@[] blobsInRadius;
			if (this.getMap().getBlobsInRadius(this.getPosition(), 64, @blobsInRadius))
			{
				for (int i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ blob = blobsInRadius[i];
					if (!blob.hasTag("flesh") || blob.hasTag("dead")) continue;

					f32 distMod = Maths::Max(0, (1.00f - ((this.getPosition() - blob.getPosition()).Length() / 64)));
					if (XORRandom(100) < 100.0f * distMod) 
					{
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.125f, HittersTC::radiation, true);

						if (blob.hasTag("human") && !blob.hasTag("transformed") && blob.getHealth() <= 0.125f && XORRandom(3) == 0)
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

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	Vec2f ul = gridmenu.getUpperLeftPosition();
	Vec2f lr = gridmenu.getLowerRightPosition();

	this.ClearGridMenusExceptInventory();
	Vec2f pos = Vec2f(lr.x, ul.y) + Vec2f(-72, 150);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(1, 1), "Abilities");

	this.set_Vec2f("InventoryPos",pos);

	AddIconToken("$mg_explode$", "SmallExplosion2.png", Vec2f(24, 24), 1);
	// AddIconToken("$deletesymbol$", "RuneSymbols.png", Vec2f(32, 16), 1);

	if (menu !is null)
	{
		menu.deleteAfterClick = true;
		// menu.SetCaptionEnabled(false);

		{
			CGridButton@ button = menu.AddButton("$mg_explode$", "Explode", this.getCommandID("mg_explode"));
			if (button !is null)
			{
				button.SetEnabled(true);
				button.selectOneOnClick = false;
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
}

void onDie(CBlob@ this)
{
	this.Tag("dead");
	this.getSprite().PlaySound("MithrilMan_Scream_0.ogg", 1.0f, 1.0f);
	this.getSprite().Gib();

	Explode(this, 32.0f, 8.0f);

	if (isServer())
	{
		for (int i = 0; i < 6; i++)
		{
			CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			if (blob !is null)
			{
				blob.server_SetQuantity(10 + XORRandom(35));
				blob.setVelocity(Vec2f(4 - XORRandom(2), -2 - XORRandom(4)));
			}
		}
	}
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
			this.getSprite().PlaySound("MithrilMan_Scream_" + (1 + XORRandom(2)) + ".ogg", 1, 0.8f);
			this.set_u32("next sound", getGameTime() + 100);
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
