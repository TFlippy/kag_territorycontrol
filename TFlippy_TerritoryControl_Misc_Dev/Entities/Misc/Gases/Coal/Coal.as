
#include "Hitters.as";
#include "Explosion.as";
#include "ArcherCommon.as";

// string[] particles = 
// {
	// "LargeSmoke.png",
	// "Explosion.png"
// };

string[] particles = 
{
	"SmallSmoke1.png",
	"SmallSmoke2.png",
	"SmallExplosion1.png",
	"SmallExplosion2.png",
	"SmallExplosion3.png"
};

void onInit(CBlob@ this)
{
	this.Tag("gas");

	this.getShape().SetGravityScale(0.03f);

	// this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(10.0f);

	this.set_string("custom_explosion_sound", "shockmine_explode.ogg");
	this.set_bool("map_damage_raycast", true);
	this.set_u8("custom_hitter", Hitters::explosion);

	this.Tag("map_damage_dirt");
	
	if (!this.exists("toxicity")) this.set_f32("toxicity", 0.80f);
	
	// this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_up | CBlob::map_collide_down);
	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 90;

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	this.server_SetTimeToDie(100 + XORRandom(100));
}

void onTick(CBlob@ this)
{
	if (getNet().isServer())
	{
		if (this.getPosition().y < 0) 
		{
			this.server_Die();
		}
		else if (this.isOnGround())
		{
			this.server_Die();
			CBlob@ blob = server_CreateBlob("mat_coal", -1, this.getPosition());
			blob.server_SetQuantity(1 + XORRandom(6));
		}
	}
}

void DoExplosion(CBlob@ this)
{
	Random@ random = Random(this.getNetworkID());
	f32 angle = this.get_f32("bomb angle");

	this.set_f32("map_damage_radius", (32.0f + random.NextRanged(32)));
	this.set_f32("map_damage_ratio", 0.25f);
	Explode(this, 64.0f, 2.0f);
	
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
		
	if (getNet().isServer())
	{
		CBlob@[] blobs;
		
		if (map.getBlobsInRadius(pos, 32.0f, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{		
				CBlob@ blob = blobs[i];
				if (blob !is null) 
				{
					map.server_setFireWorldspace(blob.getPosition(), true);
					blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.5f, Hitters::fire);
				}
			}
		}
	}	
	
	if (getNet().isClient())
	{
		// this.getSprite().PlaySound("shockmine_explode.ogg", 0.80f, 1.10f);
		ShakeScreen(100, 60, this.getPosition());
	
		for (int i = 0; i < 8; i++)
		{
			MakeParticle(this, this.getPosition() + getRandomVelocity(0, random.NextRanged(6), 360), getRandomVelocity(0, random.NextRanged(3), 360), particles[XORRandom(particles.length)]);
		}
	}
	
	this.getSprite().Gib();
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
	if (this.hasTag("lit"))
	{
		DoExplosion(this);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	if (blob.hasTag("gas")) return;

	if ((blob.getConfig() == "lantern" ? blob.isLight() : false) || blob.getConfig() == "fireplace" || (blob.getConfig() == "arrow" && blob.get_u8("arrow type") == ArrowType::fire))
	{
		this.Tag("lit");
		this.server_Die();
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;
	ParticleAnimated(CFileMatcher(filename).getFirst(), pos, vel, XORRandom(360), 1 + (XORRandom(100) * 0.02f), 2 + XORRandom(5), 0, true);
}
