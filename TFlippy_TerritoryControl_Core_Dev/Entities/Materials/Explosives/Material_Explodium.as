#include "Hitters.as";
#include "Explosion.as";
#include "Knocked.as";

string[] particles = 
{
	"SmallExplosion1.png"
	"SmallExplosion2.png",
	"SmallExplosion3.png",
};

string[] explosion_particles = 
{
	"LargeSmoke"
};

const f32 push_radius = 512.00f;

void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.maxQuantity = 200;
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
	f32 intensity = this.getQuantity() / f32(this.maxQuantity);	
	
	this.set_f32("map_damage_radius", (16.0f + random));
	this.set_f32("map_damage_ratio", 0.50f);
	
	Explode(this, 512.0f * intensity, 250.0f * intensity);
	
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	
	SetScreenFlash(255, 255, 255, 255, 3);
	Sound::Play("Fireboom_Boom", this.getPosition(), 1.00f, 2.00f - intensity);
	if (intensity > 0.25f) Sound::Play("Fireboom_Boom");

	CBlob@[] blobs;
	f32 radius = 1.00f + (push_radius * intensity);
	if (map.getBlobsInRadius(pos, radius, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{		
			CBlob@ blob = blobs[i];
			if (blob is null || blob.getShape() is null)
			{
				continue;
			}
			
			if (blob !is null && !blob.getShape().isStatic()) 
			{
				Vec2f dir = blob.getPosition() - pos;
				f32 dist = dir.Length();
				dir.Normalize();
				
				f32 mod = Maths::Sqrt(Maths::Clamp(dist / radius, 0, 1));
				blob.AddForce(dir * blob.getRadius() * 30 * mod);
				SetKnocked(blob, 50 * mod);
			}
		}
	}
	
	if (isServer())
	{				
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		if (boom !is null)
		{
			boom.setPosition(this.getPosition());
			boom.set_u8("boom_start", 0);
			boom.set_u8("boom_end", 5 + (100 * intensity));
			boom.set_u8("boom_frequency", 1);
			boom.set_u32("boom_delay", 0);
			boom.set_u32("flash_delay", 0);
			boom.Tag("no fallout");
			boom.Tag("no flash");
			boom.Tag("no mithril");
			boom.set_string("custom_explosion_sound", "Fireboom_Boom");
			boom.Init();
		}
	}
	
	if (isClient())
	{
		this.getSprite().Gib();
	}
	
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire || customData == Hitters::burn)
	{
		if (isServer()) this.server_Die();
	}

	return damage;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (blob !is null ? !blob.isCollidable() : !solid) return;
		f32 vellen = this.getOldVelocity().Length();

		if (vellen > 3.0f)
		{
			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.getQuantity() == 0) { return; }
	DoExplosion(this);
}
