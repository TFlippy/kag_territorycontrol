#include "Hitters.as";
#include "ShieldCommon.as";
#include "Explosion.as";

const f32 modifier = 1;

const string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(20);

	this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().net_threshold_multiplier = 4.0f;

	this.Tag("map_damage_dirt");
	this.Tag("explosive");

	this.set_f32("map_damage_radius", 64.0f);
	this.set_f32("map_damage_ratio", 0.2f);

	this.Tag("projectile");
	this.getSprite().SetFrame(0);
	this.getSprite().getConsts().accurateLighting = false;
	this.getSprite().SetFacingLeft(!this.getSprite().isFacingLeft());

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
	this.sendonlyvisible = false;
	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSound("Shell_Whistle.ogg");
		sprite.SetEmitSoundPaused(false);
		sprite.SetEmitSoundVolume(0.0f);
	}
}

void onTick(CBlob@ this)
{
	Vec2f velocity = this.getVelocity();
	f32 angle = velocity.Angle();
	if (isServer()) Pierce(this, velocity, angle);

	this.setAngleDegrees(-angle + 90.0f);

	// this.getSprite().SetEmitSoundPaused(this.getVelocity().y < 0);
	if (isClient())
	{
		f32 modifier = Maths::Max(0, this.getVelocity().y * 0.02f);
		this.getSprite().SetEmitSoundVolume(Maths::Max(0, modifier));
	}
}

void Pierce(CBlob@ this, Vec2f velocity, const f32 angle)
{
	CMap@ map = this.getMap();

	const f32 speed = velocity.getLength();

	Vec2f direction = velocity;
	direction.Normalize();

	Vec2f position = this.getPosition();
	Vec2f tip_position = position + direction * 4.0f;
	Vec2f tail_position = position + direction * -4.0f;

	const Vec2f[] positions =
	{
		position,
		tip_position,
		tail_position
	};

	for (uint i = 0; i < positions.length; i ++)
	{
		Vec2f temp_position = positions[i];
		TileType type = map.getTile(temp_position).type;
		const u32 offset = map.getTileOffset(temp_position);

		if (map.hasTileFlag(offset, Tile::SOLID))
		{
			onCollision(this, null, true);
		}
	}

	HitInfo@[] infos;

	if (map.getHitInfosFromArc(tail_position, -angle, 10, (tip_position - tail_position).getLength(), this, false, @infos))
	{
		for (uint i = 0; i < infos.length; i ++)
		{
			CBlob@ blob = infos[i].blob;
			Vec2f hit_position = infos[i].hitpos;

			if (blob !is null)
			{
				onCollision(this, blob, false);
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob !is null) return (this.getTickSinceCreated() > 5 && this.getTeamNum() != blob.getTeamNum() && blob.isCollidable());
	else return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer() && getGameTime() >= this.get_u32("primed_time"))
	{
		if (blob !is null && doesCollideWithBlob(this, blob)) this.server_Die();
		else if (solid) this.server_Die();
	}
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::explosion) return 0;
	return damage;
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}

	f32 angle = this.getOldVelocity().Angle();
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", 32.0f);
	this.set_f32("map_damage_ratio", 0.25f);

	Explode(this, 64.0f, 4.0f);

	for (int i = 0; i < XORRandom(4); i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();

		LinearExplosion(this, dir, 8.0f + XORRandom(16) + (modifier * 8), 8 + XORRandom(24), 2, 0.25f, Hitters::explosion);
	}

	if (isClient())
	{
		this.getSprite().Gib();
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}
