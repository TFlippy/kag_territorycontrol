#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

const f32 max_time = 3.00f;

void onInit(CBlob@ this)
{
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient_babby.png");
}

void onDie(CBlob@ this)
{
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	f32 true_level = this.get_f32("babbyed");		
	f32 level = 1.00f + true_level;
	
	if (true_level <= 0)
	{
		if (isServer())
		{
			this.server_Die();
		}
	
		if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		f32 time = f32(getGameTime() * level);
		
		f32 modifier = Maths::Min(level / max_time, 1);
		modifier = modifier * modifier * modifier;
		// f32 modifier = level / 3.00f;
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 1.25f * modifier;
			moveVars.jumpFactor *= 1.50f * modifier;
		}	
				
		if (isClient())
		{
			if (XORRandom(300) == 0)
			{
				this.getSprite().PlaySound("Babby_Laugh_" + XORRandom(5), 0.90f, 1.00f);
				// ParticleAnimated("Heart.png", this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), Vec2f(0, f32(XORRandom(100) * -0.02f)) * 0.25f, 0, 0.5f, 30, 0, false);
			}
		}

		this.set_f32("babbyed", Maths::Max(0, this.get_f32("babbyed") - (0.0002f)));
	}
	
	// print("" + true_level);
	// print("" + (1.00f / (level)));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null ? !blob.isCollidable() : !solid)
	{
		return;
	}

	f32 vellen = this.getOldVelocity().Length();
	if (vellen >= 3.5f) 
	{
		Sound::Play("launcher_boing" + XORRandom(2), this.getPosition(), 0.4f, 0.75f + (vellen * 0.05f));
		// this.setVelocity(this.getVelocity() + (normal * vellen * 0.50f));
	}
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return true;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return true;
}