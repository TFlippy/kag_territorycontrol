#include "Hitters.as";
#include "Explosion.as";
#include "Knocked.as";

string[] particles = 
{
	"SmallSteam",
	"MediumSteam",
	"LargeSmoke",
};

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	
	// this.set_string("custom_explosion_sound", "bigbomb_explosion.ogg");
	this.set_bool("map_damage_raycast", false);
	this.set_Vec2f("explosion_offset", Vec2f(0, 16));
	
	this.set_u8("stack size", 4);
	this.set_f32("bomb angle", 90);
	
	this.Tag("explosive");
	
	this.maxQuantity = 8;
}

void onDie(CBlob@ this)
{
	if (this.hasTag("DoExplode"))
	{
		DoExplosion(this);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage >= this.getHealth() && !this.hasTag("dead"))
	{
		this.Tag("DoExplode");
		this.set_f32("bomb angle", 90);
		this.server_Die();
	}
	
	return damage;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null ? !blob.isCollidable() : !solid)
	{
		return;
	}

	f32 vellen = this.getOldVelocity().Length();
	if (vellen >= 6.0f) 
	{
		Vec2f dir = Vec2f(-normal.x, normal.y);
		
		this.Tag("DoExplode");
		this.set_f32("bomb angle", dir.Angle());
		this.server_Die();
	}
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}
	
	const bool server = isServer();

	f32 random = XORRandom(16);
	f32 quantity = this.getQuantity();
	f32 modifier = 1 + Maths::Log(quantity);
	f32 angle = -this.get_f32("bomb angle");
	
	this.set_f32("map_damage_radius", (32.0f + random));
	this.set_f32("map_damage_ratio", 0.01f);
	
	Explode(this, 32.0f + random, 0.2f);
	if(isClient())
	{
		u8 len = particles.length;
		for (int i = 0; i < 200 * modifier; i++) 
		{
			Vec2f dir = getRandomVelocity(-angle, 8.5f * (XORRandom(100) * 0.01f), 100);
			MakeParticle(this, dir, particles[XORRandom(len)]);
		}
	}
	
	
	Vec2f pos = this.getPosition() + this.get_Vec2f("explosion_offset");
	
	CMap@ map = getMap();
	CBlob@[] blobs;
	if (map.getBlobsInRadius(pos, 192.0f, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{		
			CBlob@ blob = blobs[i];
			if (blob !is null && !blob.getShape().isStatic()) 
			{
				Vec2f dir = blob.getPosition() - pos;
				f32 dist = dir.Length();
				dir.Normalize();
				
				f32 mod = Maths::Clamp(1.00f - (dist / 192.00f), 0, 1);
				f32 force = Maths::Clamp(blob.getRadius() * 70 * mod * modifier, 0, blob.getMass() * 50);
				
				blob.AddForce(dir * force);
				SetKnocked(blob, 150 * mod);
				
				if (server && XORRandom(100) < 12 * modifier)
				{
					if (blob.hasTag("explosive"))
					{
						this.server_Hit(blob, blob.getPosition(), dir, 10.0f, Hitters::explosion, false);
					}
				}
			}
		}
	}
	
	this.getSprite().Gib();
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(filename, this.getPosition() + random, vel, float(XORRandom(360)), 1.0f, 1 + XORRandom(2), -0.005f, true);
}