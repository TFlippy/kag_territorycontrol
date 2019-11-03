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
	this.set_Vec2f("explosion_offset", Vec2f(0, 0));
	
	this.set_u8("stack size", 1);
	this.set_f32("bomb angle", 90);
	
	this.Tag("map_damage_dirt");
	this.Tag("explosive");
	
	this.maxQuantity = 2;
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
		// this.set_f32("bomb angle", (this.getPosition() - worldPoint).Angle());
		// print("hit");
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
		this.Tag("DoExplode");
		this.set_f32("bomb angle", -this.getOldVelocity().Angle());
		print("coll");
		this.server_Die();
	}
}

void DoExplosion(CBlob@ this)
{
	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = 180 + this.get_f32("bomb angle");
	f32 vellen = Maths::Min(this.getVelocity().Length(), 8);
	
	print("ang " + angle);
	
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (40.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);
	
	Explode(this, 40.0f + random, 15.0f);
	
	print("len " + vellen);
	
	for (int i = 0; i < 8 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 25);
		LinearExplosion(this, dir, (4.0f + XORRandom(4) + (modifier * 8)) * vellen, 8 + XORRandom(8), 10 + XORRandom(vellen * 2), 10.0f, Hitters::explosion);
	}
	
	if(!isClient()){return;}
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	
	for (int i = 0; i < 35; i++)
	{
		MakeParticle(this, Vec2f( XORRandom(32) - 16, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(500) * 0.01f, 25), particles[XORRandom(particles.length)]);
	}
	
	this.getSprite().Gib();
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}