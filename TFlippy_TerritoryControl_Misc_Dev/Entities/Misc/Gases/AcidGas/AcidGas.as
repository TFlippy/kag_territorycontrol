
#include "Hitters.as";
#include "Explosion.as";
#include "ArcherCommon.as";
#include "CustomBlocks.as";

void onInit(CBlob@ this)
{
	this.Tag("gas");

	this.getShape().SetGravityScale(0.60f);

	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(10.0f);

	if (!this.exists("toxicity")) this.set_f32("toxicity", 1.00f);
	
	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 15 + XORRandom(30);

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	this.server_SetTimeToDie(30);
}

void onTick(CBlob@ this)
{
	
	if (isServer())
	{
		if (this.getPosition().y < 0) {this.server_Die();}
		Vec2f pos = this.getPosition();
		CMap@ map = this.getMap();
	
		CBlob@[] blobsInRadius;
		if (map.getBlobsInRadius(this.getPosition(), this.getRadius() * 2.5f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ blob = blobsInRadius[i];
				if (!blob.hasTag("gas immune"))
				{
					if (getNet().isServer()) this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.25f, Hitters::burn);
				}
			}
		}
		
		for (int i = 0; i < 10; i++)
		{
			Vec2f bpos = pos + Vec2f(XORRandom(32) - 16, XORRandom(32) - 16);
			TileType type = map.getTile(bpos).type;
			
			if (!isTileGlass(type) && !isTileBGlass(type))
			{
				map.server_DestroyTile(bpos, 1, this);
			}
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
