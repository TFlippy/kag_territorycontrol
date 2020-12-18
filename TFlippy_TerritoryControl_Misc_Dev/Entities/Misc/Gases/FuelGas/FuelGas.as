
#include "Hitters.as";
#include "Explosion.as";
#include "ArcherCommon.as";

string[] particles = 
{
	"LargeSmoke.png",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.Tag("gas");

	this.getShape().SetGravityScale(0.10f);

	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(10.0f);

	this.set_f32("map_damage_ratio", 0.05f);
	this.set_f32("map_damage_radius", 64.0f);
	this.set_string("custom_explosion_sound", "Missile_Explode.ogg");
	this.set_u8("custom_hitter", Hitters::explosion);

	this.Tag("map_damage_dirt");
	
	if (!this.exists("toxicity")) this.set_f32("toxicity", 0.80f);
	
	// this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_up | CBlob::map_collide_down);
	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 15 + XORRandom(15);

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	this.server_SetTimeToDie(150);
	
	if (isClient())
	{
		this.getCurrentScript().runFlags |= Script::tick_onscreen;
	}
}

void onTick(CBlob@ this)
{
	if (isClient() && this.isOnScreen())
	{
		MakeParticle(this, "FuelGas.png");
	}

	if (isServer() && this.getPosition().y < 0) this.server_Die();
}

void Boom(CBlob@ this)
{
	if (!this.hasTag("lit")) return;
	if (this.hasTag("dead")) return;

	CMap@ map = getMap();
	Vec2f pos = this.getPosition();

	if (isServer())
	{
		CBlob@[] blobs;

		if (map.getBlobsInRadius(pos, 64.0f, @blobs))
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
		
		for (int i = 0; i < XORRandom(2); i++)
		{
			CBlob@ blob = server_CreateBlob("flame", -1, this.getPosition());
			blob.setVelocity(Vec2f(XORRandom(10) - 5, -XORRandom(6)));
			blob.server_SetTimeToDie(4 + XORRandom(6));
		}
	}
		
	for (int i = 0; i < 24; i++)
	{
		if (isServer()) map.server_setFireWorldspace(this.getPosition() + getRandomVelocity(0, 8 + XORRandom(96), 360), true);
		if (isClient() && XORRandom(100) < 25) MakeExplosionParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(0, XORRandom(220) * 0.01f, 360), particles[XORRandom(particles.length)]);
	}
	
	Explode(this, 48.0f, 0.02f);

	this.Tag("dead");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("gas");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::fire:
		case Hitters::burn:
		case Hitters::explosion:
		case Hitters::keg:
		case Hitters::mine:
			this.Tag("lit");
			this.server_SetTimeToDie(2.00f / 20.00f);
			return 0;
			break;

		default:
			return 0;
			break;
	}

	return 0;
}

void onDie(CBlob@ this)
{
	Boom(this);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	if (blob.hasTag("gas")) return;

	if ((blob.getName() == "lantern" ? blob.isLight() : false) ||
		blob.getName() == "fireplace" ||
		(blob.getName() == "arrow" && blob.get_u8("arrow type") == ArrowType::fire))
	{
		this.Tag("lit");
		this.server_Die();
	}
}

void MakeExplosionParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (isClient())
	{
		ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 1 + (XORRandom(100) * 0.02f), 2 + XORRandom(3), XORRandom(100) * -0.00005f, true);
	}
}

void MakeParticle(CBlob@ this, const string filename = "LargeSmoke")
{
	CParticle@ particle = ParticleAnimated(filename, this.getPosition() + Vec2f(16 - XORRandom(32), 8 - XORRandom(32)), Vec2f(), float(XORRandom(360)), 1.5f + (XORRandom(50) / 100.0f), 4, 0.00f, false);
	if (particle !is null) 
	{
		particle.collides = false;
		particle.deadeffect = 1;
		particle.bounce = 0.0f;
		particle.fastcollision = true;
		particle.lighting = false;
		particle.setRenderStyle(RenderStyle::additive);
	}
}