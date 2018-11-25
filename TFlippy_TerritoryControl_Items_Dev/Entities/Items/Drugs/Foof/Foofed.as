#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

const f32 max_time = 3.00f;

void onInit(CBlob@ this)
{

}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	f32 true_level = this.get_f32("foofed");		
	f32 level = 1.00f + true_level;
	
	// print("" + true_level);
	
	if (true_level <= 0)
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		// print("foofing");
	
	
		// f32 time = f32(getGameTime() * level);
		// f32 original_radius = this.get_f32("foof_original_radius");
		// f32 radius = this.get_f32("foof_radius") + 0.01f;
		
		// this.set_f32("foof_radius", radius);
		
		// // f32 modifier = Maths::Min(level / max_time, 1);
		// // modifier = modifier * modifier * modifier;
		// // f32 modifier = level / 3.00f;
		
		// CShape@ shape = this.getShape();
		// ShapeConsts@ consts = shape.getConsts();
		
		// consts.radius = radius;
		
		// print("" + radius);
		
		// RunnerMoveVars@ moveVars;
		// if (this.get("moveVars", @moveVars))
		// {
			// moveVars.walkFactor *= 1.50f * modifier;
			// moveVars.jumpFactor *= 1.50f * modifier;
		// }	
				
		// if (modifier >= 1)
		// {
			// if (this.getTickSinceCreated() % 30 == 0)
			// {
				// f32 maxHealth = Maths::Ceil(this.getInitialHealth() * 2.00f);
				// if (this.getHealth() < maxHealth)
				// {				
					// if (getNet().isServer())
					// {
						// this.server_SetHealth(Maths::Min(this.getHealth() + 0.125f, maxHealth));
					// }
					
					// if (getNet().isClient())
					// {
						// for (int i = 0; i < 4; i++)
						// {
							// ParticleAnimated("HealParticle.png", this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), Vec2f(0, f32(XORRandom(100) * -0.02f)) * 0.25f, 0, 0.5f, 10, 0, true);
						// }
					// }
				// }
			// }	
		// }
		// else
		// {
			// f32 invModifier = 1.00f - modifier;
		
			// if (getKnocked(this) == 0 && XORRandom(500 * modifier) == 0)
			// {
				// u8 knock = (30 + XORRandom(90)) * invModifier;
			
				// SetKnocked(this, knock);
				// this.getSprite().PlaySound("TraderScream.ogg", 0.8f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			// }
			
			// if (getNet().isClient())
			// {
				// if (this.isMyPlayer())
				// {
					// f32 rot;
					// rot += Maths::Sin(getGameTime() / 30.0f) * invModifier * 1.8f;
					// rot += Maths::Cos(getGameTime() / 25.0f) * invModifier * 1.3f;
					// rot += Maths::Sin(380 + getGameTime() / 40.0f) * invModifier * 2.5f;
					
					// CCamera@ cam = getCamera();
					// cam.setRotation(rot);
					
					// SetScreenFlash(255 * invModifier, XORRandom(3) * 25, 0, 0, 2 * invModifier);
					// ShakeScreen(250.0f * invModifier, 1, this.getPosition());
				// }
			// }
			
			// if (XORRandom(500 * invModifier) == 0)
			// {
				// switch (XORRandom(2))
				// {
					// case 0:
						// this.setKeyPressed(key_action1, true);
						// break;
					
					// case 1:
						// this.setKeyPressed(key_action2, true);
						// break;
				// }
			
				
			// }
		// }
	
		// print("" + modifier);
		// print("" + level / max_time);
		this.set_f32("foofed", Maths::Max(0, this.get_f32("foofed") - (0.0005f)));
	}
	
	// print("" + true_level);
	// print("" + (1.00f / (level)));
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	MegaHit(this, worldPoint, velocity, damage, hitBlob, customData);
}

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	MegaHit(this, worldPoint, velocity, damage, null, customData);
}

void MegaHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (customData == HittersTC::foof) return;

	// print("megahit");
	
	f32 true_level = this.get_f32("foofed");		
	f32 level = 1.00f + true_level;

	// print("" + level);
	
	if (level > 1)
	{
		bool client = getNet().isClient();
		bool server = getNet().isServer();
		
		Vec2f dir = worldPoint - this.getPosition();
		f32 len = dir.getLength();
		dir.Normalize();
		f32 angle = dir.Angle();
		
		int count = true_level * 5.00f;
		
		for (int i = 0; i < count; i++)
		{
			Vec2f pos = worldPoint + getRandomVelocity(0, XORRandom(Maths::Min(24.00f * true_level, 48)), 360);	
			
			if (client && XORRandom(100) < 50)
			{
				MakeDustParticle(pos, "dust2.png");
			}
			
			if (server)
			{
				this.server_HitMap(pos, dir, damage, HittersTC::foof);
			}
		}
		
		if (client)
		{
			f32 magnitude = damage * level;
			this.getSprite().PlaySound("FallBig" + (XORRandom(5) + 1), level, 1.00f);
			ShakeScreen(magnitude * 10.0f, magnitude * 8.0f, this.getPosition());
		}
		
		if (hitBlob !is null)
		{
			if (server) this.server_Hit(hitBlob, worldPoint, velocity, true_level * 0.50f, HittersTC::foof, true);
			if (client) this.getSprite().PlaySound("nightstick_hit" + (1 + XORRandom(3)) + ".ogg", 0.9f, 0.8f);
			
			f32 mass = hitBlob.getMass();
			hitBlob.AddForce(dir * Maths::Min(500.0f * true_level, mass * 10.00f));
		}
	}
}

// f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
// {
	// f32 true_level = this.get_f32("foofed");		
	// f32 level = 1.00f + true_level;
	// f32 modifier = Maths::Min(level / max_time, 1);
	
	// if (modifier >= 1)
	// {
		// return damage / Maths::Min(level, 2);
	// }
	// else
	// {
		// switch (customData)
		// {
			// case Hitters::nothing:
			// case Hitters::suicide:
			// case Hitters::suddengib:
				// return 0;
		// }
	// }

	// return damage;
// }