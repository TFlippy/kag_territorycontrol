#include "Hitters.as";
#include "HittersTC.as";

void onInit(CBlob@ this)
{
	this.Tag("smoke");
	this.Tag("gas");

	// this.Tag("blocks spawn");
	
	this.getShape().SetGravityScale(0.05f);

	this.getSprite().SetZ(10.0f);

	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 5;

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	if (!this.exists("toxicity")) this.set_f32("toxicity", 5.00f);
	
	this.server_SetTimeToDie((30 * 60 * 5) + XORRandom(30 * 60 * 15));
	
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(200, 25, 255, 100));
	
	// this.getCurrentScript().runFlags |= Script::tick_not_inwater | Script::tick_not_ininventory;
}

void onTick(CBlob@ this)
{
	if (getNet().isServer() && this.getPosition().y < 0) this.server_Die();

	MakeParticle(this, "FalloutGas.png");
	f32 radius = 128;

	// SetScreenFlash(240, 16, 40, 8);	
	
	// this.AddForce(getRandomVelocity(0, 100, 360));
	
	if (XORRandom(100) < 20) 
	{
		if (getNet().isServer())
		{
			CMap@ map = getMap();
			

			// f32 x = this.getPosition().x + XORRandom(radius * 2) - radius;
			// f32 y = (map.getLandYAtX(x / 8) - 1) * 8;
		
			Vec2f pos = this.getPosition() + getRandomVelocity(0, XORRandom(radius), 360);
		
			TileType t = map.getTile(pos).type;
			TileType g = map.getTile(Vec2f(pos.x, pos.y - 8)).type;
			
			if (map.isTileGround(t) && t != CMap::tile_ground_d0 && (XORRandom(100) < 50 ? true : t != CMap::tile_ground_d1)) map.server_DestroyTile(pos, 0.10f);
			else if (map.isTileGrass(g)) map.server_DestroyTile(Vec2f(pos.x, pos.y - 8), 10.00f);
			else if (map.isTileWood(t) && t != CMap::tile_wood_d0) map.server_DestroyTile(pos, 0.10f);
			else if (map.isTileCastle(t) && t != CMap::tile_castle_d0) map.server_DestroyTile(pos, 0.10f);
			
		
			CBlob@[] blobsInRadius;
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
			{
				for (int i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ blob = blobsInRadius[i];
					if ((blob.hasTag("flesh") || blob.hasTag("nature")) && !blob.hasTag("dead"))
					{
						Vec2f pos = this.getPosition();
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.0625f, HittersTC::radiation, true);
					}
				}
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}

void MakeParticle(CBlob@ this, const string filename = "LargeSmoke")
{
	if (!getNet().isClient()) return;
	CParticle@ particle = ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + Vec2f(XORRandom(1000) / 10.0f - 50.0f, -XORRandom(600) / 10.0f + 20.0f), Vec2f(), float(XORRandom(360)), 2.0f + (XORRandom(150) / 100.0f), 4, 0.00f, false);
	if (particle !is null) 
	{
		particle.setRenderStyle(RenderStyle::additive);
	}
	
	// normal
	// light
	// outline
	// outline_front
	// additive
	// subtractive
	// shadow
	// solid
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
   return blob.hasTag("smoke");
}
