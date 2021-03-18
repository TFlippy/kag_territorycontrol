
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

	this.getShape().SetGravityScale(0.67f);

	// this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(7.0f);

	this.set_string("custom_explosion_sound", "shockmine_explode.ogg");
	this.set_bool("map_damage_raycast", true);
	this.set_u8("custom_hitter", Hitters::explosion);

	this.Tag("map_damage_dirt");

	if (!this.exists("toxicity")) this.set_f32("toxicity", 0.80f);

	// this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_up | CBlob::map_collide_down);
	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	if(isClient())
	{
		this.getCurrentScript().tickFrequency = 2;
		this.getCurrentScript().runFlags |= Script::tick_onscreen;
	}
	else // its like this for localhost, so we can still see it
	{
		this.getCurrentScript().tickFrequency = 90;
	}

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	this.server_SetTimeToDie(17 + XORRandom(17));
}

void onTick(CBlob@ this)
{
	if(isClient())
	{
		CParticle@ particle = ParticleAnimated("Coal.png", this.getPosition(), this.getOldVelocity() / 7, 1.0f, 1, 6, 0.0f, false);
		if (particle !is null)
		{
			particle.frame = XORRandom(7);
			particle.collides = false;
			particle.deadeffect = 1;
			particle.bounce = 0.0f;
			particle.fastcollision = true;
			particle.lighting = false;
		}

		return; // now we dont need to run the isServer() :)
	}

	if (isServer())
	{
		if (this.getPosition().y < 0) 
		{
			this.server_Die();
		}
		else if (this.isOnGround() || this.isInWater())
		{
			this.server_Die();
			CBlob@ blob = server_CreateBlob("mat_coal", -1, this.getPosition());
			blob.server_SetQuantity(1 + XORRandom(6));
			blob.Tag("dusted");
			blob.setInventoryName("Coal Dust");
		}
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

	Random@ random = Random(this.getNetworkID());
	f32 angle = this.get_f32("bomb angle");

	this.set_f32("map_damage_radius", (32.0f + random.NextRanged(32)));
	this.set_f32("map_damage_ratio", 0.25f);
	Explode(this, 40.0f, 1.2f);

	Vec2f pos = this.getPosition();
	CMap@ map = getMap();

	if (isServer())
	{
		CBlob@[] blobs;

		if (map.getBlobsInRadius(pos, 15.0f, @blobs))
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

	if (isClient())
	{
		// this.getSprite().PlaySound("shockmine_explode.ogg", 0.80f, 1.10f);
		ShakeScreen(100, 60, this.getPosition());

		if (this.isOnScreen())
		{
			for (int i = 0; i < 4; i++)
			{
				MakeParticle(this, this.getPosition() + getRandomVelocity(0, random.NextRanged(6), 360), getRandomVelocity(0, random.NextRanged(3), 360), particles[XORRandom(particles.length)]);
			}
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
			this.server_SetTimeToDie(0.1f);
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

	if ((blob.getName() == "lantern" ? blob.isLight() : false) || blob.getName() == "fireplace" || (blob.getName() == "arrow" && blob.get_u8("arrow type") == ArrowType::fire))
	{
		this.Tag("lit");
		this.server_Die();
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	CParticle@ p = ParticleAnimated(filename, pos, vel, XORRandom(360), 1 + (XORRandom(100) * 0.02f), 2 + XORRandom(5), 0, true);
	if(p !is null)
	{
		p.fastcollision = true;
		p.bounce = 0.0f;
	}
}
