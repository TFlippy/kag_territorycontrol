#include "Hitters.as";
#include "ShieldCommon.as";
#include "Explosion.as";

const f32 BLOB_DAMAGE = 20.0f;
const f32 MAP_DAMAGE = 10.0f;

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

string[] particles_smoke = 
{
	"LargeSmoke"
};

void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(20);
	
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().net_threshold_multiplier = 4.0f;

	this.set_u32("wait_time", getGameTime() + 5); // Awful fix, I'm quite ashamed.
	
	this.Tag("map_damage_dirt");
	this.Tag("projectile");
	this.Tag("explosive");
	
	this.set_f32("map_damage_radius", 96.0f);
	this.set_f32("map_damage_ratio", 0.4f);
	this.set_string("custom_explosion_sound", "ShockMine_explode.ogg");
	
	this.getSprite().SetFrame(0);
	this.getSprite().getConsts().accurateLighting = false;
	this.getSprite().SetFacingLeft(!this.getSprite().isFacingLeft());

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
	this.getShape().SetGravityScale(1.18f);
	this.sendonlyvisible = false;
	
	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.bullet = true;
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Shell_Whistle.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(0.0f);
	sprite.SetEmitSoundSpeed(0.7f);
}

void onTick(CBlob@ this)
{
	f32 angle = 0;

	Vec2f velocity = this.getVelocity();
	angle = velocity.Angle();
	Pierce(this, velocity, angle);

	this.setAngleDegrees(-angle + 180.0f);
	
	f32 modifier = Maths::Max(0, this.getVelocity().y * 0.015f);
	this.getSprite().SetEmitSoundVolume(Maths::Max(0, modifier));
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

	Vec2f[] positions =
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
	if (blob !is null) return (this.getTeamNum() != blob.getTeamNum() && (blob.isCollidable() || blob.hasTag("building")));
	else return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (blob !is null && doesCollideWithBlob(this, blob)) this.server_Die();
		else if (solid) this.server_Die();
	}
}

void onDie(CBlob@ this)
{
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

	f32 modifier = 1;
	f32 angle = this.getOldVelocity().Angle();
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", 48.0f);
	this.set_f32("map_damage_ratio", 0.40f);
	
	Explode(this, 128.0f, 150.0f);
	
	for (int i = 0; i < 4; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 30);
		dir.x *= 2;
		dir.Normalize();
		
		LinearExplosion(this, dir, 32.0f + XORRandom(16) + (modifier * 8), 24 + XORRandom(24), 4, 0.50f, Hitters::explosion);
	}
	
	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		if (boom !is null)
		{
			boom.setPosition(this.getPosition());
			boom.set_u8("boom_start", 0);
			boom.set_u8("boom_end", 4);
			boom.set_u8("boom_frequency", 2);
			boom.set_u32("boom_delay", 0);
			boom.set_u32("flash_delay", 0);
			boom.Tag("no fallout");
			boom.Tag("no flash");
			boom.Tag("no mithril");
			// boom.Tag("no particles");
			// boom.Tag("no explosion particles");
			boom.set_string("custom_explosion_sound", "ShockMine_explode");
			boom.Init();
		}
	}
	
	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		this.getSprite().Gib();
	}
	
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (isClient())
	{
		ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(3), XORRandom(100) * -0.00005f, true);
	}
}

// void MakeParticleEmber(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
// {
	// if (isClient())
	// {
		// ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.10f + XORRandom(100) * 0.01f, 5 + XORRandom(15), 0.30f, true);
	// }
// }

// void MakeParticleSmoke(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
// {
	// if (isClient())
	// {
		// ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 1.5f + XORRandom(100) * 0.01f, 8 + XORRandom(10), XORRandom(100) * -0.00005f, true);
	// }
// }