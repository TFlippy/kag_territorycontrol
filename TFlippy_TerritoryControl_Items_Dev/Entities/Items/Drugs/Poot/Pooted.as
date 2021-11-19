#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

void onInit(CBlob@ this)
{
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient_poot.png");
}

void onDie(CBlob@ this)
{
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	f32 true_level = this.get_f32("pooted");		
	f32 level = 1.00f + Maths::FastSqrt(true_level);
	
	if (true_level <= 0)
	{
		CSprite@ sprite = this.getSprite();
		this.setAngleDegrees(0);
		sprite.SetEmitSoundPaused(true);
		
		if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
		this.Untag("custom_camera");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		f32 time = f32(getGameTime() * level);

		this.Tag("custom_camera");
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 1.50f + Maths::Log((level * level));
			moveVars.jumpFactor *= 1.75f;
		}	
		
		// this.getShape().SetGravityScale(0.15f + 0.25f * (1.00f - (f32(level) / f32(max))));
		
		if (this.isMyPlayer())
		{
			CCamera@ cam = getCamera();
			f32 time = getGameTime();
			f32 camX = Maths::Cos(getGameTime() * 0.1f * level) * level;
			
			cam.setRotation(camX);
			cam.targetDistance = 1.50f + ((1 + Maths::Sin(getGameTime() * 0.1f * level)) * 0.50f) * (level * level * 0.125f);
			
			if (getGameTime() % 5 == 0) SetScreenFlash(Maths::Min(255, level * 25), 150 + (XORRandom(4) * 25), 0, 0);
		}
		
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSound("/AAAA.ogg");
		sprite.SetEmitSoundPaused(false);
		sprite.SetEmitSoundSpeed(level * 0.70f);
		sprite.SetEmitSoundVolume(true_level * 0.50f);
		
		Vec2f vel = this.getVelocity();
		if (Maths::Abs(vel.x) > 0.1)
		{
			f32 angle = this.get_f32("angle");
			angle += vel.x * this.getRadius() * true_level;
			if (angle > 360.0f)
				angle -= 360.0f;
			else if (angle < -360.0f)
				angle += 360.0f;
			this.set_f32("angle", angle);
			this.setAngleDegrees(angle);
		}
		
		if (this.isOnGround())
		{
			u32 key = XORRandom(3);
			switch (key)
			{
				case 0:
					this.setKeyPressed(key_left, true);
					this.AddForce(Vec2f(-0.50f * this.getMass(), 0));
					break;
				
				case 1:
					this.setKeyPressed(key_right, true);
					this.AddForce(Vec2f(0.50f * this.getMass(), 0));
					break;
				
				case 2:
					this.setKeyPressed(key_up, true);
					this.AddForce(Vec2f(0, -2 * this.getMass()));
					break;
			}
		}
			
		this.set_f32("pooted", Maths::Max(0, this.get_f32("pooted") - 0.0005f));
	}
	
	// print("" + level);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	f32 true_level = this.get_f32("pooted");
	f32 level = 1.00f + true_level;

	if (level > 1)
	{
		f32 vellen = this.getOldVelocity().Length();
		bool client = isClient();
		bool server = isServer();
		
		if (solid && vellen > 5.00f / true_level)
		{
			int count = vellen * (true_level * 0.33f);
			for (int i = 0; i < count; i++)
			{
				Vec2f pos = point1 + getRandomVelocity(-normal.Angle(), 2.00f * i, Maths::Min(15 * i, 80));	

				if (client && XORRandom(100) < 50)
				{
					MakeDustParticle(pos, "dust2.png");
				}
				
				if (server)
				{
					getMap().server_DestroyTile(pos, 0.005f * vellen);
				}
			}
			
			if (client)
			{
				this.getSprite().PlaySound("FallBig" + (XORRandom(5) + 1), vellen / 8.0f + 0.2f, 1.6f - vellen / 45.0f);
				ShakeScreen(vellen * 8.0f, vellen * 2.0f, this.getPosition());
			}
			
			if (server)
			{
				f32 dmg = (vellen * level) * 0.002f;
				this.server_Hit(this, this.getPosition(), -this.getOldVelocity(), dmg, Hitters::stomp);
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 true_level = this.get_f32("pooted");		
	f32 level = 1.00f + true_level;

	if (level > 1)
	{
		switch (customData)
		{
			case Hitters::fall:
				return 0.00f;
		}
	}
	
	return damage;
}