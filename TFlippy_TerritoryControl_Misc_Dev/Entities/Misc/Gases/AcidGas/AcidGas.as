#include "Explosion.as";
#include "ArcherCommon.as";
#include "CustomBlocks.as";

void onInit(CBlob@ this)
{
	this.Tag("gas");

	this.getShape().SetGravityScale(0.60f);

	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(10.0f);

	if (!this.exists("acid_strength")) this.set_u16("acid_strength", 25);
	if (!this.exists("toxicity")) this.set_f32("toxicity", 1.00f);
	
	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	// this.getCurrentScript().tickFrequency = 15 + XORRandom(30);
	UpdateTickFrequency(this);

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	this.server_SetTimeToDie(10);
}

void UpdateTickFrequency(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 4;
}

void onTick(CBlob@ this)
{	
	if (this.getTickSinceCreated() < 2) return;

	const bool server = isServer();
	const bool client = isClient();

	Vec2f pos = this.getPosition();
	s32 strength = this.get_u16("acid_strength");
	
	if (strength > 0 && this.getPosition().y > 0 && !this.isInWater())
	{
		CMap@ map = this.getMap();
			
		bool hit = false;
		Vec2f hit_position = this.getPosition();
	
		for (int i = 0; i < 10; i++)
		{
			Vec2f bpos = pos + Vec2f(XORRandom(32) - 16, XORRandom(32) - 16);
			
			TileType type = map.getTile(bpos).type;
			
			if (!isTileGlass(type) && !isTileBGlass(type) && type != CMap::tile_goldingot && type != CMap::tile_mithrilingot && 
				type != CMap::tile_empty && type != CMap::tile_ground_back)
			{
				if (server && type != CMap::tile_bedrock)
				{
					map.server_DestroyTile(bpos, 1, this);
				}
				
				strength -= 1;
				
				if (!hit)
				{
					hit_position = bpos;
					hit = true;
				}
			}
		}
	
		CBlob@[] blobsInRadius;
		if (map.getBlobsInRadius(this.getPosition(), this.getRadius() * 2.25f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ blob = blobsInRadius[i];
				if (!blob.hasTag("gas immune") && !blob.hasTag("gas"))
				{
					// print("hit" + blob.getName());
				
					if (server) 
					{
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.40f, 8);
					}
					
					strength -= 1;
					
					if (!hit)
					{
						hit_position = blob.getPosition();
						hit = true;
					}
				}
			}
		}
				
		if (hit)
		{
			if (client)
			{
				this.getSprite().PlaySound("Steam", 1, 1);
				if (this.isOnScreen())
				{
					MakeSmokeParticle(this, hit_position, Vec2f(0, -1), "LargeSmoke");
				}
			}
		}
		
		if (client && this.isOnScreen())
		{
			MakeParticle(this, "AcidGas.png");
		}
		
		// print("" + strength);
		
		this.set_u16("acid_strength", Maths::Max(strength, 0));
		UpdateTickFrequency(this);
	}
	else
	{
		if (server)
		{
			this.server_Die();
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("gas");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}

void MakeSmokeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;
	ParticleAnimated(filename, pos, vel, XORRandom(360), 1.25f, 1 + XORRandom(5), XORRandom(100) * -0.00005f, false);
}

void MakeParticle(CBlob@ this, const string filename = "LargeSmoke")
{
	CParticle@ particle = ParticleAnimated(filename, this.getPosition() + Vec2f(16 - XORRandom(32), 8 - XORRandom(32)), Vec2f(), float(XORRandom(360)), 1.0f + (XORRandom(50) / 100.0f), 3, 0.00f, false);
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
