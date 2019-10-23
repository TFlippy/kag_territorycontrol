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
		InitBrain( this );
		this.server_SetActive( true ); // always running
	}
}

void onInit(CBlob@ this)
{
	// this.Tag("npc");
	this.Tag("flesh");
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
	
	this.getSprite().SetZ(100.0f);
	
	CSprite@ sprite = this.getSprite();
	sprite.RewindEmitSound();
	sprite.SetEmitSound("Mound_Hover_Loop.ogg");
	sprite.SetEmitSoundSpeed(1);
	sprite.SetEmitSoundVolume(0.40f);
	sprite.SetEmitSoundPaused(false);
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
	Vec2f pos = Vec2f(lr.x, ul.y) + Vec2f(-72, 200);
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
			this.getSprite().PlaySound("Mound_Growl_" + XORRandom(2), 1.0f, 1.00f);
			this.set_u32("next sound", getGameTime() + 200);
		}
		
		if (isClient())
		{
			if (XORRandom(100) < 25) MakeParticle(this, 0.75f);
		}
	}
	
	CSprite@ sprite = this.getSprite();
	if (false && this.isOnGround())
	{
		sprite.SetAnimation("idle");
	}
	else
	{
		sprite.SetAnimation("floating");
	}
	
	sprite.SetEmitSoundSpeed(0.85f + (Maths::Clamp(this.getVelocity().getLength() / 50.00f, 0.00f, 1.00f) * 0.75f));
	
	this.SetFacingLeft(this.getVelocity().x < 0);
	
	// if (isServer())
	// {
		// if (XORRandom(100) == 0)
		// {
			// CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			// blob.server_SetQuantity(10 + XORRandom(20));
		
			// this.server_Hit(this, this.getPosition(), Vec2f(), 0.125f, Hitters::stab, true);
		// }
	// }
	
	if (this.isKeyPressed(key_action1))
	{
		const f32 radius = 64.00f;
		
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(this.getAimPos(), radius, @blobsInRadius)) 
		{
			for (int i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if (b !is null)
				{
					// if (b is this) continue;
					
					Vec2f dir = this.getAimPos() - b.getPosition();
					f32 dist = dir.getLength();
					dir.Normalize();
						
					b.AddForce((dir * Maths::Min(100.00f, b.getMass()) * (dist / radius)) + Vec2f(0, -sv_gravity * b.getMass() / 30.00f));
				}
			}
		}
	}
	else if (this.isKeyPressed(key_action2))
	{
		const f32 radius = 16.00f;
		
		Vec2f aimPos = this.getAimPos();
		
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(aimPos, radius, @blobsInRadius)) 
		{
			for (int i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if (b !is null)
				{
					if (b is this || b.hasTag("invincible")) continue;
					
					Vec2f dir = aimPos - b.getPosition();
					f32 dist = dir.getLength();
					dir.Normalize();

					if (isServer())
					{
						if (getGameTime() % 5 == 0) this.server_Hit(b, b.getPosition(), Vec2f(0, 0), 0.50f, Hitters::crush, true);
					}
					
					b.AddForce((dir * Maths::Min(100.00f, b.getMass()) * (dist / radius)) + Vec2f(0, -sv_gravity));
					// if (b.getShape().isRotationsAllowed()) 
					
					if (!b.hasTag("building") && !b.getShape().isStatic()) b.setAngleDegrees(b.getAngleDegrees() + (20.00f * (1.00f - (b.getHealth() / b.getInitialHealth()))));
				}
			}
		}
		
		CMap@ map = getMap();
		for (int i = 0; i < 2; i++)
		{
			map.server_DestroyTile(aimPos + getRandomVelocity(0, XORRandom(48), 360), 0.125f);
		}
	}
	
	if (XORRandom(8) == 0) 
	{	
		if (isServer())
		{
			const f32 radius = 256.00f;
		
			CBlob@[] blobsInRadius;
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
			{
				for (int i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ blob = blobsInRadius[i];
					if ((blob.hasTag("flesh") || blob.hasTag("nature")) && !blob.hasTag("dead"))
					{
						Vec2f pos = this.getPosition();
						Vec2f dir = blob.getPosition() - pos;
						f32 len = dir.Length();
						dir.Normalize();

						int counter = 1;

						for(int i = 0; i < len; i += 8)
						{
							if (getMap().isTileSolid(pos + dir * i)) counter++;
						}
						
						f32 distMod = Maths::Max(0, (1.00f - ((this.getPosition() - blob.getPosition()).Length() / radius)));
						
						if (XORRandom(100) < 100.0f * distMod) 
						{
							this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.50f / counter, HittersTC::radiation, true);
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
		
	for (int i = 0; i < 8; i++)
	{
		CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
		
		if (blob !is null)
		{
			blob.server_SetQuantity(10 + XORRandom(40));
			blob.setVelocity(Vec2f(XORRandom(4) - 2, -2 - XORRandom(4)));
		}
	}

	// if (isServer())
	// {
		// CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		// boom.setPosition(this.getPosition());
		// boom.set_u8("boom_start", 0);
		// boom.set_u8("boom_end", 2);
		// boom.set_f32("mithril_amount", 100);
		// boom.set_f32("flash_distance", 32);
		// boom.set_u32("boom_delay", 0);
		// boom.set_u32("flash_delay", 0);
		// boom.Tag("no fallout");
		// boom.Tag("no flash");
		// boom.Init();
	// }
}

void onTick(CBrain@ this)
{
	if (!isServer()) return;

	CBlob @blob = this.getBlob();
	
	if (blob.getPlayer() !is null) return;
	
	SearchTarget(this, false, true);
	CBlob @target = this.getTarget();
	
	// this.getCurrentScript().tickFrequency = 30;
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
		if (getGameTime() > this.get_u32("next sound") - 100)
		{
			this.getSprite().PlaySound("Mound_Hit_" + XORRandom(2), 0.5f, 0.9f);
			this.set_u32("next sound", getGameTime() + 150);
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

void MakeParticle(CBlob@ this, float magnitude)
{
	if (!isClient()) return;
	CParticle@ p = ParticleAnimated("FalloutGas.png", this.getPosition() + getRandomVelocity(0, magnitude * 32, 360), Vec2f(), float(XORRandom(360)), 1.00f + (magnitude * 2 * (XORRandom(100) / 100.0f)), 3 + (6 * magnitude), -0.05f, false);
	if (p !is null)
	{
		p.fastcollision = true;
		// p.deadeffect = 0;
	}
}