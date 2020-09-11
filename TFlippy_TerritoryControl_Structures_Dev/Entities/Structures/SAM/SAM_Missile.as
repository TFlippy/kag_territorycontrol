#include "Hitters.as";
#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

const u32 fuel_timer_max = 30 * 8;
const f32 inp_ratio = 0.50f;

void onInit(CBlob@ this)
{
	this.Tag("aerial");
	this.Tag("projectile");
	this.Tag("explosive");
	
	this.set_f32("bomb angle", 90);
	
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_f32("map_damage_radius", 48.0f);
	this.Tag("map_damage_dirt");
	this.set_string("custom_explosion_sound", "Missile_Explode.ogg");
		
	this.set_u32("no_explosion_timer", getGameTime() + 15);
	this.set_u32("fuel_timer", fuel_timer_max + getGameTime());
	// this.set_f32("velocity", 10.0f);
	// this.set_Vec2f("direction", Vec2f(0, -1));
		
	this.SetMapEdgeFlags(0);
	this.getShape().SetRotationsAllowed(true);
}

void onTick(CBlob@ this)
{
	Vec2f dir;
	f32 dist = 90000.00f;
	
	if (this.get_u32("fuel_timer") > getGameTime())
	{
		// Not as hardcore shitcode anymore, but still shitcode
		if (this.getTickSinceCreated() > 15)
		{
			CBlob@ target = getBlobByNetworkID(this.get_u16("target"));
			if (target !is null)
			{
				dir = (target.getPosition() - this.getPosition());
				dist = dir.getLength();
				dir.Normalize();
			}
			else if (this.hasTag("self_destruct"))
			{
				this.server_Die();
			}
		}
		else
		{
			dir = this.get_Vec2f("direction");
		}
				
		// Vec2f nDir = (this.get_Vec2f("direction") * (1.00f - inp_ratio)) + (dir * inp_ratio);
		// dir.y *= -1.00f;
		
		const f32 ratio = 0.25f;
		
		Vec2f nDir = (this.get_Vec2f("direction") * (1.00f - ratio)) + (dir * ratio);
		nDir.Normalize();
		
		this.SetFacingLeft(false);
		
		this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.75f, 20.0f));
		this.setAngleDegrees(-nDir.getAngleDegrees() + 90);
		this.setVelocity(nDir * this.get_f32("velocity"));
		
		if (isServer())
		{
			if (dist < 8) this.server_Die();
		}
		
		this.set_Vec2f("direction", nDir);


		if(isClient())
		{
			MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
		}
		
	}		
	
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable() && blob.getTeamNum() != this.getTeamNum(); // && blob.isCollidable();
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}
	
	if (this.hasTag("dead")) return;

	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (30.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);
	
	Explode(this, 30.0f + random, 20.0f);
	
	for (int i = 0; i < 4 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();
		
		LinearExplosion(this, dir, 8.0f + XORRandom(16) + (modifier * 8), 8 + XORRandom(24), 3, 0.125f, Hitters::explosion);
	}
	
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	
	for (int i = 0; i < 35; i++)
	{
		MakeExplosionParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(220) * 0.01f, 90), particles[XORRandom(particles.length)]);
	}
	
	this.Tag("dead");
	this.getSprite().Gib();
}

void MakeExplosionParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(8), 0, true);
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(0, 16).RotateBy(this.getAngleDegrees());
	ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (solid && this.get_u32("no_explosion_timer") < getGameTime()) this.server_Die();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}





			
