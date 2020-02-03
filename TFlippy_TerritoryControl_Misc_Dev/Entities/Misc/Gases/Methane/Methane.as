
#include "Hitters.as";
#include "Explosion.as";
#include "ArcherCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("gas");

	this.getShape().SetGravityScale(-0.025f);

	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(10.0f);

	this.set_f32("map_damage_ratio", 0.2f);
	this.set_f32("map_damage_radius", 64.0f);
	this.set_string("custom_explosion_sound", "methane_explode.ogg");
	this.set_u8("custom_hitter", Hitters::burn);

	if (!this.exists("toxicity")) this.set_f32("toxicity", 0.125f);
	
	// this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_up | CBlob::map_collide_down);
	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 15 + XORRandom(15);

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	this.server_SetTimeToDie(90);
}

void onTick(CBlob@ this)
{
	if (isServer() && this.getPosition().y < 0) this.server_Die();
	
	if (isClient())
	{
		MakeParticle(this, "Methane.png");
	}
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

		if (map.getBlobsInRadius(pos, 32.0f, @blobs))
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

		for (int i = 0; i < 24; i++)
		{
			map.server_setFireWorldspace(this.getPosition() + getRandomVelocity(0, 8 + XORRandom(48), 360), true);
		}
	}

	Explode(this, 32.0f, 0.1f);

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

void MakeParticle(CBlob@ this, const string filename = "LargeSmoke")
{
	if (isClient())
	{
		CParticle@ particle = ParticleAnimated(filename, this.getPosition() + Vec2f(16 - XORRandom(32), 8 - XORRandom(32)), Vec2f(), float(XORRandom(360)), 1.0f + (XORRandom(50) / 100.0f), 4, 0.00f, false);
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
}