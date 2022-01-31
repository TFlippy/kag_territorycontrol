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

	this.set_string("custom_explosion_sound", "Missile_Explode.ogg");
	this.set_bool("map_damage_raycast", true);
	this.set_Vec2f("explosion_offset", Vec2f(0, 16));

	this.set_u8("stack size", 2);
	this.set_f32("bomb angle", 90);

	this.Tag("explosive");
	this.Tag("heavy weight");

	this.maxQuantity = 1;
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
	if (vellen >= 6.0f) 
	{
		//Vec2f dir = -this.getOldVelocity();
		//dir.Normalize();

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

	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (40.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);

	Explode(this, 24.0f + random, 5.0f);

	for (int i = 0; i < 4 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();

		LinearExplosion(this, dir, 8.0f + XORRandom(16) + (modifier * 8), 8 + XORRandom(24), 3, 0.125f, Hitters::explosion);
	}

	Vec2f pos = this.getPosition() + Vec2f(0, -8);
	CMap@ map = getMap();

	// if (isClient())
	// {
		// for (int i = 0; i < 25; i++) 
		// {
			// MakeParticle(this, "FalloutGas");
		// }
	// }

	if (isServer())
	{
		for (int i = 0; i < 4; i++)
		{
			CBlob@ blob = server_CreateBlob("mat_mithril", -1, this.getPosition());
			blob.setVelocity(getRandomVelocity(angle, 4 + XORRandom(15), 60));
			blob.server_SetQuantity(10 + XORRandom(20));

			CBlob@ gas = server_CreateBlob("falloutgas", -1, this.getPosition());
			gas.setVelocity(getRandomVelocity(angle, 8 + XORRandom(10), 70));
			gas.server_SetTimeToDie(180 + XORRandom(900));
		}

		CBlob@ gas = server_CreateBlob("falloutgas", -1, this.getPosition());
		gas.server_SetTimeToDie(180 + XORRandom(900));
	}

	this.getSprite().Gib();
}

// void MakeParticle(CBlob@ this, const string filename = "LargeSmoke")
// {
	// if (!isClient()) return;
	// CParticle@ particle = ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + Vec2f(XORRandom(1000) / 10.0f - 50.0f, -XORRandom(600) / 10.0f + 20.0f), Vec2f(), float(XORRandom(360)), 2.0f + (XORRandom(150) / 100.0f), 25, 0.00f, false);
	// if (particle !is null) 
	// {
		// particle.setRenderStyle(RenderStyle::additive);
	// }
// }

// void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
// {
	// if (!isClient()) return;

	// ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + pos, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), XORRandom(100) * -0.00005f, true);

// }
