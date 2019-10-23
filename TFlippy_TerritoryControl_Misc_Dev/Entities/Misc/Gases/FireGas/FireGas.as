#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.7f);
	this.server_SetTimeToDie(1 + XORRandom(2));
	
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(10.0f);
	
	this.getCurrentScript().tickFrequency = 5;
	
	this.SetLight(true);
	this.SetLightRadius(64.0f);
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
		
		for (int i = 0; i < 3; i++)
		{
			Vec2f bpos = pos + Vec2f(XORRandom(64) - 32, XORRandom(16));
			
			TileType t = map.getTile(bpos).type;
			if (t != CMap::tile_castle_d0 && t != CMap::tile_ground_d0 && (XORRandom(100) < 50 ? true : t != CMap::tile_ground_d1))
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
	// for (int i = 0; i < 2; i++) ParticleAnimated(CFileMatcher("Explosion.png").getFirst(), this.getBlob().getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), getRandomVelocity(0, 2, 360), 0, 1.00f + XORRandom(5) * 0.10f, 4, 0.1, false);
	if (this.getBlob().getTickSinceCreated() % 1 == 0) ParticleAnimated(XORRandom(100) < 90 ? "SmallFire.png" : "LargeSmoke", this.getBlob().getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), getRandomVelocity(0, 1, 360), 0, 1.00f + XORRandom(5) * 0.10f, 4, 0.1, false);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	bool server = isServer();
	if (solid) 
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();

		for (int i = 0; i < 8; i++)
		{
			Vec2f bpos = pos + Vec2f(XORRandom(48) - 24, XORRandom(48) - 24);
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
		
		this.getSprite().PlaySound("Missile_Explode", 1, 1);
		
		if (server) 
		{
			CBlob@[] blobs;
			if (map.getBlobsInRadius(pos, 24.0f, @blobs))
			{
				for (int i = 0; i < blobs.length; i++)
				{		
					CBlob@ blob = blobs[i];
					if (blob !is null) 
					{
						map.server_setFireWorldspace(blob.getPosition(), true);
						blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 1.5f, Hitters::fire);
					}
				}
			}
		
			map.server_setFireWorldspace(pos, true);
			this.server_Die();
		}
	}
	else if (blob !is null && blob.isCollidable())
	{
		if (this.getTeamNum() != blob.getTeamNum()) this.server_Hit(blob, this.getPosition(), Vec2f(0, 0), 2.50f, Hitters::fire, false);
	}
}