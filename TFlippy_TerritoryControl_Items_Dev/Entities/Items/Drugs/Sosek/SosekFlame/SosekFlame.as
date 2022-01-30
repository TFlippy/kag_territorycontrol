#include "Hitters.as";
#include "Explosion.as";

string[] particles = 
{
	"LargeFire.png",
	"SmallFire1.png",
	"SmallFire2.png",
	"SmallExplosion.png",
};

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.10f);
	this.server_SetTimeToDie(0.70f);
	
	this.getCurrentScript().tickFrequency = 15;
	
	this.set_f32("map_damage_ratio", 0.2f);
	this.set_string("custom_explosion_sound", "methane_explode.ogg");
	this.set_u8("custom_hitter", Hitters::burn);
	this.Tag("map_damage_dirt");
	
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 200, 50));
}

void onTick(CBlob@ this)
{
	if (isServer() && this.getTickSinceCreated() > 5) 
	{
		// getMap().server_setFireWorldspace(this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), true);
		
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
	
		map.server_setFireWorldspace(pos, true);
		
		f32 radius = getFlameRadius(this);
		for (int i = 0; i < radius; i++)
		{
			Vec2f bpos = pos + getRandomVelocity(0, XORRandom(radius), 360);
			TileType t = map.getTile(bpos).type;
			if (map.isTileGround(t) && t != CMap::tile_ground_d0 && (XORRandom(100) < 50 ? true : t != CMap::tile_ground_d1))
			{
				map.server_DestroyTile(bpos, 1, this);
			}
			else
			{
				map.server_setFireWorldspace(bpos, true);
			}
		}
	}
}

void onTick(CSprite@ this)
{
	if (!isClient()) return;
	
	
	CBlob@ blob = this.getBlob();
	f32 radius = getFlameRadius(blob);
	Vec2f pos = blob.getPosition();
	
	Vec2f vel = blob.getVelocity();
	vel.Normalize();
	
	for (int i = 0; i < radius; i++)
	{
		Vec2f offset = getRandomVelocity(0, XORRandom(radius), 360);
		// offset.x *= vel.x;
		// offset.y *= vel.y;
		
		ParticleAnimated(particles[XORRandom(particles.length)], pos + offset, Vec2f(0, 0), 0, 1.0f, 3, XORRandom(100) * 0.01f * 0.30f, false);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	bool server = isServer();
	if (solid || (blob !is null && blob.getTeamNum() != this.getTeamNum() && blob.isCollidable())) 
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();

		f32 radius = getFlameRadius(this);
		for (int i = 0; i < radius; i++)
		{
			Vec2f bpos = pos + getRandomVelocity(0, XORRandom(radius * 2), 360);
			TileType t = map.getTile(bpos).type;
			
			if (t != CMap::tile_castle_d0 && t != CMap::tile_ground_d0 && (XORRandom(100) < 50 ? true : t != CMap::tile_ground_d1))
			{
				if (server)
				{
					map.server_DestroyTile(bpos, 1, this);
				}
				else
				{
					if (XORRandom(100) < 25) ParticleAnimated("SmallExplosion.png", bpos + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), getRandomVelocity(0, 2, 360), 0, 1.00f + XORRandom(5) * 0.10f, 4, 0.1, false);
				}
				
			}
			
			if (server)
			{
				map.server_setFireWorldspace(bpos, true);
			}
		}
		
		this.set_f32("map_damage_radius", Maths::Pow(radius * 8.00f, 0.75f));
		Explode(this, radius, 1.00f);
		
		// this.getSprite().PlaySound("Missile_Explode", 1, 1);
		
		if (server) 
		{
			CBlob@[] blobs;
			if (map.getBlobsInRadius(pos, 12.0f, @blobs))
			{
				for (int i = 0; i < blobs.length; i++)
				{		
					CBlob@ blob = blobs[i];
					if (blob !is null) 
					{
						map.server_setFireWorldspace(blob.getPosition(), true);
						blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.25f, Hitters::fire);
					}
				}
			}
		
			map.server_setFireWorldspace(pos, true);
			this.server_Die();
		}
	}
}

f32 getFlameRadius(CBlob@ this)
{
	return f32(this.getTickSinceCreated()) * 0.50f;
}