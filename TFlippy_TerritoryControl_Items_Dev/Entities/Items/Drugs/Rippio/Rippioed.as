#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

const f32 increment = 1.00f / (30.00f * 30.00f);

void onInit(CBlob@ this)
{
	this.Tag("no_suicide");

	if (this.hasTag("human") || this.hasTag("chicken"))
	{
		CSprite@ sprite = this.getSprite();
		sprite.RewindEmitSound();
		sprite.SetEmitSound("Rippio_Scream.ogg");
		sprite.SetEmitSoundSpeed(this.getSexNum() == 0 ? 1.0f : 2.0f);
		sprite.SetEmitSoundVolume(0);
		sprite.SetEmitSoundPaused(false);
	}
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) 
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		this.getSprite().PlaySound("oof", 2.00f, 1.00f);
		this.getSprite().SetEmitSoundPaused(true);
		this.setAngleDegrees(0);
		return;
	}
		
	const f32 value = this.get_f32("rippioed");
	const u32 time = getGameTime();
	
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		f32 mod = 1 + (value * value);
		moveVars.walkFactor /= mod;
		moveVars.jumpFactor /= mod;
	}	
	
	if (XORRandom(400) < (100 * value))
	{
		this.setKeyPressed(key_action1, true);
		this.setKeyPressed(key_action2, true);
	}
	
	if (this.isMyPlayer())
	{
	
		CCamera@ cam = getCamera();
		f32 camX = Maths::Cos(time * value * 0.001f) * 10 * Maths::Pow(value, 2);
		cam.setRotation(camX);
	}
	
	if (time % 5 == 0)
	{
		// SetKnocked(this, (5 * value) + (XORRandom(5) * value));
		
		if (this.isMyPlayer())
		{
			SetScreenFlash(Maths::Clamp((25 + XORRandom(100)) * value, 0, 255), 25 + (XORRandom(4) * 25), 0, 0);
			
			// if (value > 0.40f && XORRandom(1 + (4 / (1 + value))) == 0)
			// {
				// this.getSprite().PlaySound("psheh", 0.1f * value, 0.05f + (0.05f * value) + (XORRandom(100) * value * 0.001f));
			// }
		}
	}
	
	if (value > 0.75f)
	{
		if (time % (3 + XORRandom(10)) == 0)
		{
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSoundVolume(Maths::Min((value * value * value) - 0.50f, 1));
			sprite.SetEmitSoundSpeed((this.getSexNum() == 0 ? 0.0f : 1.0f) + 0.75f + (XORRandom(100) / 400.00f));
		}
	
		if (time % 3 == 0)
		{
			this.setAngleDegrees(Maths::Clamp((180 - XORRandom(360)) * (value * 0.25f), -180, 180));
		}
	}

	if (value > 1.50f)
	{
		if (isServer() && time % 10 == 0)
		{
			this.server_Hit(this, this.getPosition(), Vec2f(0, 0), Maths::Max(this.getHealth() * 0.01f, 0.02f * value), HittersTC::poison, true);
		}
	}
		
	this.set_f32("rippioed", value + increment);
}