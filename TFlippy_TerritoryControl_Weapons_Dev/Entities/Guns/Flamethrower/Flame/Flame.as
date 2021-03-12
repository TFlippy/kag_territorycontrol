#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.4f);
	this.server_SetTimeToDie(2 + XORRandom(3));

	if(isServer())
	{
		this.getCurrentScript().tickFrequency = 15;
	}

	if(isClient())
	{
		this.getCurrentScript().tickFrequency = 2;
	}

	/*this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 200, 50));*/

	if(isClient())
	{
		this.getCurrentScript().runFlags |= Script::tick_onscreen;
	}
}

void onTick(CBlob@ this)
{
	// print("" + this.getDamageOwnerPlayer().getUsername());

	if (isServer() && this.getTickSinceCreated() > 5) 
	{
		// getMap().server_setFireWorldspace(this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), true);

		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
	
		map.server_setFireWorldspace(pos, true);
		
		for (int i = 0; i < 3; i++)
		{
			Vec2f bpos = pos + Vec2f(12 - XORRandom(24), XORRandom(8));
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

	if (isClient())
	{
		this.getSprite().SetFrame(XORRandom(6));
		ParticleAnimated("SmallFire", this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), Vec2f(0, 0), 0, 1.0f, 2, 0.25f, false);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (solid)
		{
			Vec2f pos = this.getPosition();
			CMap@ map = getMap();

			map.server_setFireWorldspace(pos, true);

			for (int i = 0; i < 3; i++)
			{
				Vec2f bpos = pos + Vec2f(12 - XORRandom(24), XORRandom(8));
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
		if (this.isInWater())
		{
			if (isServer()) this.server_Die();
		}
		else if (blob !is null && blob.isCollidable())
		{
			if (this.getTeamNum() != blob.getTeamNum()) this.server_Hit(blob, this.getPosition(), Vec2f(0, 0), 0.50f, Hitters::fire, false);
		}
	}
}
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::water || customData == Hitters::water_stun)
	{
		if (isServer()) this.server_Die();
	}

	return damage;
}
