#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

const f32 hitmap_chance = 0.25f;

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 8;

	this.getSprite().SetEmitSound("Sparkle.ogg");

	this.getSprite().SetEmitSoundPaused(false);
	this.SetLight(true);
	this.SetLightRadius(48.0f);

	this.server_SetTimeToDie(5);

	this.set_bool("map_damage_raycast", true);
	this.Tag("map_damage_dirt");
	this.Tag("projectile");

	this.Tag("use hitmap");
	this.set_f32("hitmap_chance", hitmap_chance);

	 // To compensate for explosions dealing higher tile damage
	this.set_f32("mining_multiplier", (1.25f / hitmap_chance) * 2.00f);
}

void onTick(CSprite@ this)
{
	sparks(this.getBlob().getPosition(), this.getBlob().getAngleDegrees(), 3.5f + (XORRandom(10) / 5.0f), SColor(255, 255, 230, 0));
}

void sparks(Vec2f at, f32 angle, f32 speed, SColor color)
{
	Vec2f vel = getRandomVelocity(angle + 90.0f, speed, 25.0f);
	at.y -= 2.5f;
	ParticlePixel(at, vel, color, true, 119);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable();
}

// void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
// {
	// if (inventoryBlob is null) return;

	// CInventory@ inv = inventoryBlob.getInventory();

	// if (inv is null) return;

	// this.doTickScripts = true;
	// inv.doTickScripts = true;
// }

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::water || customData == Hitters::water_stun)
	{
		this.Tag("exploded");
		if (isServer())
		{
			CBlob@ blob = server_CreateBlob("mat_dynamite", this.getTeamNum(), this.getPosition());
			this.server_Die();
		}
	}

	return damage;
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
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

	if (this.hasTag("exploded")) return;

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

	if(isClient())
	{

		Vec2f pos = this.getPosition();
		CMap@ map = getMap();

		this.Tag("exploded");
		this.getSprite().Gib();
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}