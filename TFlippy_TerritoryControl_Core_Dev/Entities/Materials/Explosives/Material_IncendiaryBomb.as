#include "Hitters.as";
#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);

	// this.set_string("custom_explosion_sound", "bigbomb_explosion.ogg");
	this.set_bool("map_damage_raycast", true);
	this.set_Vec2f("explosion_offset", Vec2f(0, 16));

	this.set_u8("stack size", 4);
	this.set_f32("bomb angle", 90);

	this.Tag("explosive");
	this.Tag("medium weight");

	this.maxQuantity = 4;
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
		//this.set_f32("bomb angle", 90);
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
	if (vellen >= 8.0f) 
	{
		//Vec2f dir = Vec2f(-normal.x, normal.y);

		this.Tag("DoExplode");
		//this.set_f32("bomb angle", dir.Angle());
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

	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = this.getAngleDegrees() - this.get_f32("bomb angle");

	this.set_f32("map_damage_radius", (40.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);

	Explode(this, 40.0f + random, 15.0f);

	for (int i = 0; i < 4 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();

		LinearExplosion(this, dir, 8.0f + XORRandom(16) + (modifier * 8), 8 + XORRandom(24), 3, 0.125f, Hitters::explosion);
	}

	Vec2f pos = this.getPosition();
	CMap@ map = getMap();

	if (isServer())
	{
		CBlob@[] blobs;

		if (map.getBlobsInRadius(pos, 128.0f, @blobs))
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

		for (int i = 0; i < (7 + XORRandom(5)) * modifier; i++)
		{
			CBlob@ blob = server_CreateBlob("flame", -1, this.getPosition());
			blob.setVelocity(Vec2f(XORRandom(10) - 5, -XORRandom(10)));
			blob.server_SetTimeToDie(10 + XORRandom(10));
		}
		for(int a = 0; a < 80; a++)
		{
			map.server_setFireWorldspace(pos + Vec2f(8 - XORRandom(16), 8 - XORRandom(16)) * 8, true);
		}
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), XORRandom(100) * -0.00005f, true);
}
