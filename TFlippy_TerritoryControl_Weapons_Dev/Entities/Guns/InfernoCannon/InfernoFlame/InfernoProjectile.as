#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";

string[] particles = 
{
	"FireFlash.png",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.5f);

	this.set_string("custom_explosion_sound", "InfernoCannon_Explosion");

	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 200, 50));
}

void onTick(CSprite@ this)
{
	if (!isClient()) return;

	this.RotateBy(20.0f, Vec2f());
	ParticleAnimated("SmallFire", this.getBlob().getPosition() + Vec2f(4 - XORRandom(8), 4 - XORRandom(8)), Vec2f(0, 0), 0, 1.0f + (XORRandom(100) * 0.01f), 2, 0.25f, false);
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

	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (40.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);

	Explode(this, 64.0f + random, 15.0f);

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
			blob.server_SetTimeToDie(10 + XORRandom(15));
		}

		for(int i = 0; i < 40; i++)
		{
			map.server_setFireWorldspace(pos + Vec2f(8 - XORRandom(16), 8 - XORRandom(16)) * 8, true);
		}
	}

	if (isClient())
	{
		this.getSprite().Gib();
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 1.0f + (XORRandom(100) * 0.01f), 1 + XORRandom(8), XORRandom(100) * -0.0001f, true);
}