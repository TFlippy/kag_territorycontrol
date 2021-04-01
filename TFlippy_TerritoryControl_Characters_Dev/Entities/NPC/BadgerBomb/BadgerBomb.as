#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

const f32 hitmap_chance = 0.25f;

void onInit(CBlob@ this)
{
	this.set_f32("voice pitch", 1.20f);

	this.getSprite().SetEmitSound("Sparkle.ogg");
	this.getSprite().SetEmitSoundPaused(true);
	this.SetLight(false);
	this.SetLightRadius(48.0f);

	this.set_bool("map_damage_raycast", true);
	this.Tag("map_damage_dirt");

	this.Tag("use hitmap");
	this.set_f32("hitmap_chance", hitmap_chance);

	this.set_f32("mining_multiplier", (1.25f / hitmap_chance) * 2.00f);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob.hasTag("lit_fuse"))
	{
		EmitSparks(blob.getPosition() + (blob.isFacingLeft() ? Vec2f(11.50f, 1.50f) : Vec2f(-11.50f, 1.50f)), 0, 3.5f + (XORRandom(10) / 5.0f), SColor(255, 255, 230, 0));
	}
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		if (this.hasTag("lit_fuse") && getGameTime() >= this.get_u32("explosion_time"))
		{
			this.server_Die();
		}
	}
}

void EmitSparks(Vec2f position, f32 angle, f32 speed, SColor color)
{
	Vec2f vel = getRandomVelocity(angle + 90.0f, speed, 25.0f);
	position.y -= 2.5f;
	ParticlePixel(position, vel, color, true, 119);
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("exploded")) return;

	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}


	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (40.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.50f);

	Explode(this, 40.0f + random, 25.0f);

	for (int i = 0; i < 10 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();

		LinearExplosion(this, dir, 16.0f + XORRandom(16) + (modifier * 8), 16 + XORRandom(24), 3, 2.00f, Hitters::explosion);
	}

	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();

		for (int i = 0; i < 35; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(220) * 0.01f, 90), particles[XORRandom(particles.length)]);
		}

		this.Tag("exploded");
		this.getSprite().Gib();
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (!this.hasTag("lit_fuse"))
	{
		this.Tag("lit_fuse");
		this.set_u32("explosion_time", getGameTime() + 120);

		this.getSprite().SetEmitSoundPaused(false);
		this.SetLight(true);
	}

	return damage;
}