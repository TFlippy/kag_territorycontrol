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
		
	this.set_string("custom_explosion_sound", "Fireball_Boom");
		
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 200, 50));
	
	if (!this.exists("power")) this.set_f32("power", 1.00f);
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
	f32 modifier = this.get_f32("power");
	// print("Modifier: " + modifier);

	this.set_f32("map_damage_radius", (16.0f + random) * Maths::Sqrt(modifier));
	this.set_f32("map_damage_ratio", 0.50f);
	
	Explode(this, 128.0f * Maths::Sqrt(modifier), 50.0f * modifier);
	
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	
	SetScreenFlash(255, 255, 255, 255, 15);
	Sound::Play("Fireball_Boom");
	ShakeScreen(666, 666, this.getPosition());
	
	if (isServer())
	{
		CBlob@[] blobs;
		
		if (map.getBlobsInRadius(pos, 256.0f, @blobs))
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
		
		for (int i = 0; i < 40; i++)
		{
			CBlob@ blob = server_CreateBlob("flame", -1, this.getPosition());
			blob.setVelocity(Vec2f(8 - XORRandom(16), -XORRandom(10)));
			blob.server_SetTimeToDie(60 + XORRandom(10));
		}
		
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		if (boom !is null)
		{
			boom.setPosition(this.getPosition());
			boom.set_u8("boom_start", 0);
			boom.set_u8("boom_end", 40);
			boom.set_u8("boom_frequency", 4);
			boom.set_u32("boom_delay", 0);
			boom.set_u32("flash_delay", 0);
			boom.Tag("no fallout");
			boom.Tag("no flash");
			boom.Tag("no mithril");
			boom.set_string("custom_explosion_sound", "Fireball_Boom");
			boom.Init();
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