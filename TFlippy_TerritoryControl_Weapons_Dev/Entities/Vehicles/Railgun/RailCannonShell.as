#include "Hitters.as";
#include "ShieldCommon.as";
#include "Explosion.as";

const f32 BLOB_DAMAGE = 20.0f;
const f32 MAP_DAMAGE = 10.0f;

void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(20);
	
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().net_threshold_multiplier = 4.0f;

	this.set_u32("wait_time", getGameTime() + 2); // Awful fix, I'm quite ashamed.
	
	this.Tag("map_damage_dirt");
	this.Tag("explosive");
	
	this.Tag("projectile");
	this.getSprite().SetFrame(0);
	this.getSprite().getConsts().accurateLighting = false;
	this.getSprite().SetFacingLeft(!this.getSprite().isFacingLeft());

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
	this.sendonlyvisible = false;
	
	this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);
}

void onTick(CBlob@ this)
{
	f32 angle = 0;

	Vec2f velocity = this.getVelocity();
	angle = velocity.Angle();
	Pierce(this, velocity, angle);

	this.setAngleDegrees(-angle + 180.0f);
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

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && !solid && doesCollideWithBlob(this, blob)) DoExplosion(this, this.getOldVelocity());
	else if (solid) DoExplosion(this, this.getOldVelocity());
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	// print("This: " + this.getTeamNum() + "; Other: " + blob.getTeamNum() + " called " + blob.getName());	

	if (blob !is null)
	{
		return (this.getTeamNum() != blob.getTeamNum() && blob.isCollidable());
	}
	else return false;
}

void DoExplosion(CBlob@ this, Vec2f velocity)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, velocity, DoExplosion);
		return;
	}

	if (this.hasTag("dead")) return;
	this.Tag("dead");

	this.SetMinimapRenderAlways(false);
		
	ShakeScreen(256, 64, this.getPosition());
	SetScreenFlash(64, 255, 255, 255);
	
	// LinearExplosion(this, velocity, 256.00f, 16.0f, 32, 64.0f, Hitters::explosion);
	
	for (int i = 0; i < 4; i++)
	{
		// Vec2f jitter = Vec2f((XORRandom(200) - 100) / 200.0f, (XORRandom(200) - 100) / 200.0f);
		// LinearExplosion(this, Vec2f(velocity.x * jitter.x, velocity.y * jitter.y), 64.0f + XORRandom(32), 48.0f, 8, 40.0f, Hitters::explosion);
		LinearExplosion(this, velocity.RotateBy((100 - XORRandom(200)) * 0.02f), 64.00f + XORRandom(64), 12.0f, 32, 64.0f, Hitters::explosion);
	}
	
	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		if (boom !is null)
		{
			boom.setPosition(this.getPosition());
			boom.set_u8("boom_start", 0);
			boom.set_u8("boom_end", 10);
			boom.set_u8("boom_frequency", 1);
			boom.set_u32("boom_delay", 0);
			boom.set_u32("flash_delay", 0);
			boom.Tag("no fallout");
			boom.Tag("no flash");
			boom.Tag("no mithril");
			boom.Init();
		}
	}


	this.Tag("dead");
	this.server_Die();
	this.getSprite().Gib();
}