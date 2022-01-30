#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

const f32 increment = 1.00f / (30.00f * 6.00f);

void onInit(CBlob@ this)
{
	this.Tag("no_suicide");

	CSprite@ sprite = this.getSprite();
	sprite.RewindEmitSound();
	sprite.SetEmitSound("Love_Loop.ogg");
	sprite.SetEmitSoundSpeed(1.00f);
	sprite.SetEmitSoundVolume(0.00f);
	sprite.SetEmitSoundPaused(false);
	
	this.set_u32("love_time", getGameTime());
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient_poot.png");
}

void onDie(CBlob@ this)
{
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) 
	{
		if (isClient())
		{
			ParticleBloodSplat(this.getPosition(), true);
		
			f32 mod = XORRandom(100) * 0.01f * 5.00f;
			Vec2f pos = this.getPosition();

			for (int i = 0; i < 40; i++)
			{
				Vec2f vel = getRandomVelocity(0, XORRandom(400) * 0.01f * 3.00f, 360);
			
				CParticle@ p = ParticleBlood(pos + vel, vel * -1.0f, SColor(255, 126, 0, 0));
				if (p !is null)
				{
					p.timeout = 10 + XORRandom(60);
					p.scale = 1.50f;
					p.fastcollision = true;
					// p.stretches = true;
				}
			}
		
			CSprite@ sprite = this.getSprite();
			sprite.PlaySound("Pigger_Gore", 2.00f, 1.00f);
			sprite.SetEmitSoundPaused(true);
			sprite.Gib();
		}
		
		if (isServer())
		{
			this.server_Die();
		}
		
		return;
	}
		
	const f32 value = this.get_f32("love_effect");
	const u32 time = getGameTime() - this.get_u32("love_time");
	
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor = 0;
		moveVars.jumpFactor = 0;
	}	
	
	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
	
		if (this.isMyPlayer())
		{
			CCamera@ cam = getCamera();
			f32 camX = Maths::Cos(time * value * 0.001f) * 10 * Maths::Pow(value, 2);
			cam.targetDistance = 2.00f + ((1 + Maths::Cos(time * 10.0f * value)) * 0.50f) * (value * 1.50f);

			CControls@ controls = getControls();
			Driver@ driver = getDriver();
			controls.setMousePosition(controls.getMouseScreenPos() + getRandomVelocity(0, (100 - XORRandom(200)) * value, 360));
			
			sprite.SetEmitSoundVolume(value * 0.50f);
		}
		else
		{
			sprite.SetEmitSoundVolume(Maths::Min(value * 0.25f, 0.15f));
		}
		
		f32 pitch = 1.00f;
		if (this.exists("voice pitch")) pitch = this.get_f32("voice pitch");
		
		sprite.SetEmitSoundSpeed(pitch + (Maths::Cos(time * 0.10f * value) * 0.50f * 0.10f));
	}
	
	if (time % (3 + XORRandom(5)) == 0)
	{
		SetKnocked(this, 30);

		if (isClient())
		{
			if (XORRandom(100) < 25)
			{
				ParticleBloodSplat(this.getPosition(), true);
				this.getSprite().PlaySound("Pigger_Gore", 0.30f, 0.90f);
			}
		
			f32 mod = XORRandom(100) * 0.01f * value;
			Vec2f pos = this.getPosition();
			int count = Maths::Clamp(time * 0.50f, 3, 20);
			
			for (int i = 0; i < count; i++)
			{
				Vec2f vel = getRandomVelocity(0, XORRandom(400) * 0.01f * value, 360);
			
				CParticle@ p = ParticleBlood(pos + vel, vel * -1.0f, SColor(255, 126, 0, 0));
				if (p !is null)
				{
					p.timeout = 10 + XORRandom(60);
					p.scale = 0.75f + mod;
					p.fastcollision = true;
					// p.stretches = true;
				}
			}
		}
		
		if (this.isMyPlayer())
		{
			SetScreenFlash(Maths::Clamp((25 + XORRandom(100)) * value, 0, 255), 25 + (XORRandom(4) * 25), 0, 0);
			
			// if (value > 0.40f && XORRandom(1 + (4 / (1 + value))) == 0)
			// {
				// this.getSprite().PlaySound("Rippio_Screech", 0.1f * value, 0.05f + (0.05f * value) + (XORRandom(100) * value * 0.001f));
			// }
		}
	}
	
	if (value > 0.15f)
	{
		if (time % 3 == 0)
		{
			this.setAngleDegrees(Maths::Clamp((180 - XORRandom(360)) * (value * 0.25f), -180, 180));
		}
	}

	if (value > 1.50f)
	{
		if (isServer() && time % 10 == 0)
		{
			this.server_Hit(this, this.getPosition(), Vec2f(0, 0), Maths::Max(this.getHealth() * 0.10f, 0.25f * value), HittersTC::poison, true);
		}
	}
		
	this.set_f32("love_effect", value + increment);
}

