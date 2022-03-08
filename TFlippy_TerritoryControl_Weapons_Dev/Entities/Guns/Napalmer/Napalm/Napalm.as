#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(5 + XORRandom(30));
	
	this.getCurrentScript().tickFrequency = 10;
	
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 200, 50));
	
	this.set_u16("attached_blob", 0);
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
	
	if (this.get_u16("attached_blob") > 0)
	{
		CBlob@ blob = getBlobByNetworkID(this.get_u16("attached_blob"));
		if (blob !is null)
		{
			this.setPosition(blob.getPosition());
			
			if (isServer())
			{
				this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.75f, Hitters::fire);
			}
		}
	}
}

void onTick(CSprite@ this)
{
	if (isClient())
	{
		CBlob@ blob = this.getBlob();
	
		ParticleAnimated(XORRandom(100) < 50 ? "SmallFire.png" : "LargeFire.png", blob.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), getRandomVelocity(0, 1, 360), 0, 1.00f + XORRandom(5) * 0.10f, 4, 0.1, false);
		if (XORRandom(100) < 25 && (blob.getShape().isStatic() || blob.get_u16("attached_blob") > 0))ParticleAnimated("SmallExplosion.png", blob.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), getRandomVelocity(0, 1, 360), 0, 1.00f + XORRandom(5) * 0.10f, 4, -0.1, false);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (this.getTickSinceCreated() < 3 ? (blob !is null ? blob.getTeamNum() != this.getTeamNum() : true) : true)
	{
		CBlob@ attachedBlob = getBlobByNetworkID(this.get_u16("attached_blob"));
		if (attachedBlob is null && blob !is null && !blob.hasTag("invincible") && !blob.hasTag("napalmed"))
		{
			this.set_u16("attached_blob", blob.getNetworkID());
			blob.Tag("napalmed");
		}
		// else if (solid)
		// {
			// this.getShape().SetStatic(true);
		// }
	}
}

// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// bool server = isServer();
	// if (solid) 
	// {
		// Vec2f pos = this.getPosition();
		// CMap@ map = getMap();

		// for (int i = 0; i < 8; i++)
		// {
			// Vec2f bpos = pos + Vec2f(XORRandom(48) - 24, XORRandom(48) - 24);
			// TileType t = map.getTile(bpos).type;
			
			// if (t != CMap::tile_castle_d0 && t != CMap::tile_ground_d0 && (XORRandom(100) < 50 ? true : t != CMap::tile_ground_d1))
			// {
				// if (server)
				// {
					// map.server_DestroyTile(bpos, 1, this);
				// }
				
				// if (XORRandom(100) < 25) ParticleAnimated(CFileMatcher("SmallExplosion.png").getFirst(), bpos + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), getRandomVelocity(0, 2, 360), 0, 1.00f + XORRandom(5) * 0.10f, 4, 0.1, false);
			// }
			
			// if (server)
			// {
				// map.server_setFireWorldspace(bpos, true);
			// }
		// }
		
		// // this.getSprite().PlaySound("Missile_Explode", 1, 1);
		
		// if (server) 
		// {
			// CBlob@[] blobs;
			// if (map.getBlobsInRadius(pos, 24.0f, @blobs))
			// {
				// for (int i = 0; i < blobs.length; i++)
				// {		
					// CBlob@ blob = blobs[i];
					// if (blob !is null) 
					// {
						// map.server_setFireWorldspace(blob.getPosition(), true);
						// blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 1.5f, Hitters::fire);
					// }
				// }
			// }
		
			// map.server_setFireWorldspace(pos, true);
			// // this.server_Die();
		// }
	// }
	// else if (blob !is null && blob.isCollidable())
	// {
		// if (this.getTeamNum() != blob.getTeamNum()) this.server_Hit(blob, this.getPosition(), Vec2f(0, 0), 2.50f, Hitters::fire, false);
	// }
// }