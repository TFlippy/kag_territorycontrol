#include "Hitters.as";
#include "Explosion.as";

string[] particles =
{
	"SmallSmoke1.png",
	"SmallSmoke2.png",
	"SmallExplosion1.png",
	"SmallExplosion2.png",
	"SmallExplosion3.png"
	"SmallFire1.png"
	"SmallFire2.png"
};

void onInit(CBlob@ this)
{
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_f32("map_damage_radius", 40.0f);
	this.set_string("custom_explosion_sound", "Keg.ogg");

	this.Tag("builder always hit");
	this.Tag("map_damage_dirt");
	this.Tag("projectile");

	this.getShape().SetRotationsAllowed(true);
}

void onTick(CBlob@ this)
{
	if(!this.hasTag("grenade collided"))
	{
		this.setAngleDegrees(-this.getVelocity().Angle());
	}
	else
	{
		this.getShape().SetStatic(true);
	}
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum() && blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (this.hasTag("grenade collided") && blob !is null && blob.getTeamNum() != this.getTeamNum())
	{
		if (getNet().isServer())
		{
			this.server_Die();
		}
	}
	else if (solid)
	{
		this.Tag("grenade collided");
			
		if (blob is null)
		{
			// this.getShape().SetStatic(true);
			this.setVelocity(Vec2f(0, 0));
			this.setPosition(point2);
		}
		else if (doesCollideWithBlob(this, blob) && (blob.hasTag("flesh") || blob.hasTag("vehicle"))) this.server_Die();
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData != Hitters::explosion && customData != Hitters::fire)
	{
		this.Tag("dead");
		this.server_Die();
	}
	
	return damage;
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	this.Tag("dead");

	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (24.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.40f);

	Explode(this, 24.0f + random, 12.0f);

	for (int i = 0; i < 4 * modifier; i++)
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();

		LinearExplosion(this, dir, 8.0f + XORRandom(8) + (modifier * 8), 8 + XORRandom(24), 2, 0.125f, Hitters::explosion);
	}
	
	if(isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();

		for (int i = 0; i < 35; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(32) - 16, XORRandom(40) - 20), getRandomVelocity(0, XORRandom(300) * 0.01f, 360), particles[XORRandom(particles.length)]);
		}

		this.getSprite().Gib();
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + pos, vel, float(XORRandom(360)), 1.0f + XORRandom(100) * 0.01f, 2 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}