
#include "Hitters.as";
#include "Explosion.as";
#include "ArcherCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("gas");

	this.getShape().SetGravityScale(-0.025f);

	this.set_f32("map_damage_ratio", 0.2f);
	this.set_f32("map_damage_radius", 64.0f);
	//this.set_string("custom_explosion_sound", "methane_explode.ogg");
	//this.set_u8("custom_hitter", Hitters::burn);

	if (!this.exists("toxicity")) this.set_f32("toxicity", 0.125f);

	// this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_up | CBlob::map_collide_down);
	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 15 + XORRandom(15);

	this.server_SetTimeToDie(50 + XORRandom(40));
}

void onTick(CBlob@ this)
{
	if (isServer() && this.getPosition().y < 0) { this.server_Die(); }

	if (isClient() && this.isOnScreen())
	{
		MakeParticle(this, "Methane.png");
	}
}

void Boom(CBlob@ this)
{
	if (!this.hasTag("lit")) return;
	if (this.hasTag("dead")) return;

	this.Tag("dead");

	CMap@ map = getMap();
	Vec2f pos = this.getPosition();

	if (isServer())
	{
		HitInfo@[] hitlist;

		if (map.getHitInfosFromCircle(pos, 32.0f, this, @hitlist))
		{
			for (int i = 0; i < hitlist.length; i++)
			{
				CBlob@ blob = hitlist[i].blob;
				Vec2f pos = hitlist[i].hitpos;
				if (blob !is null)
				{
					if (!blob.hasTag("dead") && (blob.hasTag("gas") || blob.hasTag("flesh") || blob.hasTag("plant")))
					{
						// Much faster to check isInFire then to constantly set 1 position on fire
						if (!map.isInFire(pos))
							map.server_setFireWorldspace(pos, true);

						blob.server_Hit(blob, pos, Vec2f(0, 0), 1.5f, Hitters::burn);
					}
				}
				else
				{
					u16 tile = hitlist[i].tile;
					switch(tile)
					{
						case CMap::tile_bedrock:
							continue;

						default:
							this.server_HitMap(pos, Vec2f(0, 0), 1.0f, Hitters::burn);
							map.server_setFireWorldspace(pos, true);
					}
				}
			}
		}
	}

	if (isClient())
	{
		Vec2f pos = this.getPosition();

		Sound::Play("methane_explode.ogg", pos);
		ShakeScreen(1.5f * 64.0f, 40.00f * Maths::FastSqrt(1.5f / 5.00f), pos);
		makeLargeExplosionParticle(pos);
	}
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

	if (blob.hasTag("gas"))
	{
		this.setVelocity(getRandomVelocity(0.0f, 0.5f, 360.0f));
		return;
	}

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
