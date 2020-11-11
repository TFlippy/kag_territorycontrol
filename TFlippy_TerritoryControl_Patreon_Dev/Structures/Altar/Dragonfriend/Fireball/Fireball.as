#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";

string[] particles = 
{
	"FireFlash.png",
	"Explosion.png"
};

string[] particles_trail = 
{
	"FireFlash.png",
	"LargeFire.png",
	"SmallFire1.png",
	"SmallFire2.png"
};

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.80f);
		
	this.set_string("custom_explosion_sound", "methane_explode");
		
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 200, 50));
	
	if (!this.exists("power")) this.set_f32("power", 100000.00f);
}

void onTick(CSprite@ this)
{
	if (!isClient()) return;
	
	this.RotateBy(20.0f, Vec2f());
	ParticleAnimated(particles_trail[XORRandom(particles_trail.length)], this.getBlob().getPosition(), Vec2f(0, 0), 0, 1.0f, 2, 0.25f, false);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (this.getTickSinceCreated() > 5 && blob !is null ? blob.isCollidable() : solid)
	{
		this.server_Die();
	}
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}
	
	f32 random = XORRandom(8);
	f32 modifier = 1.00f + Maths::Sqrt(this.get_f32("power") * 0.00002f);
	// print("Modifier: " + modifier);

	this.set_f32("map_damage_radius", (16.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.50f);
	
	Explode(this, 32.0f * modifier, 2.0f * modifier);
	
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	
	if (isServer())
	{
		CBlob@[] blobs;
		
		if (map.getBlobsInRadius(pos, 16.0f, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{		
				CBlob@ blob = blobs[i];
				if (blob !is null && (blob.hasTag("flesh") || blob.hasTag("plant"))) 
				{
					map.server_setFireWorldspace(blob.getPosition(), true);
					blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.5f, Hitters::fire);
				}
			}
		}
	
		for (int i = 0; i < 14; i++)
		{
			map.server_setFireWorldspace(pos + Vec2f(2 - XORRandom(4), 2 - XORRandom(4)) * 8, true);
		}
	}
	
	if (isClient())
	{
		for (int i = 0; i < 4; i++)
		{
			MakeParticle(this, Vec2f(16 - XORRandom(32), 16 - XORRandom(32)), getRandomVelocity(0, XORRandom(100) * 0.02f, 360), particles[XORRandom(particles.length)]);
		}
		
		this.getSprite().Gib();
	}
	
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 1.00f, 1 + XORRandom(8), XORRandom(100) * -0.0001f, true);
}