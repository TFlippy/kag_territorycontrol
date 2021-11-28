#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

const f32 increment = 1.00f / (30.00f * 20.00f);

void onInit(CBlob@ this)
{
	CSpriteLayer@ zzz = this.getSprite().addSpriteLayer("paxilon_zzz", "Quarters.png", 8, 8);
	if (zzz !is null)
	{
		{
			zzz.addAnimation("default", 15, true);
			int[] frames = {96, 97, 98, 98, 99};
			zzz.animation.AddFrames(frames);
		}
		zzz.SetOffset(Vec2f(-3, -7));
		zzz.SetRelativeZ(5);
		zzz.SetLighting(false);
		zzz.SetVisible(false);
	}
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) 
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		return;
	}
		
	const f32 value = this.get_f32("paxilon_effect");
	const bool sleeping = value > 0.05f && !this.hasTag("dead");
	
	// print("" + value);
	
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		f32 mod = 1.00f - Maths::Clamp(value * 10.00f, 0.00f, 1.00f);

		// print("" + mod);
	
		moveVars.walkFactor *= mod;
		moveVars.jumpFactor *= mod;
	}
	
	if (getGameTime() % 30 == 0)
	{
		if (sleeping)
		{
			SetKnocked(this, 90);
		}
		
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSound("MigrantSleep.ogg");
		sprite.SetEmitSoundVolume(0.5f);
		sprite.SetEmitSoundPaused(!sleeping);
		
		CSpriteLayer@ layer = sprite.getSpriteLayer("paxilon_zzz");
		if (layer !is null)
		{
			layer.SetVisible(sleeping);
		}
	}

	if (value >= 0.00f)
	{
		this.set_f32("paxilon_effect", value - increment);
	}

	if (value >= 2.0f)
		this.server_Hit(this, this.getPosition(), Vec2f(0, 0), Maths::Max(this.getHealth() * 0.01f, 0.02f * value), HittersTC::poison, true);
}