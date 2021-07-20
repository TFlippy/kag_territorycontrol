#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("gas");

	this.getShape().SetGravityScale(0.10f);
	
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(10.0f);
	
	// this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_up | CBlob::map_collide_down);
	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 15 + XORRandom(15);
	
	if (!this.exists("toxicity")) this.set_f32("toxicity", 0.50f);
	
	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());
	this.server_SetTimeToDie(60 + XORRandom(90));
}

void onTick(CBlob@ this)
{
	if (isServer() && this.getPosition().y < 0) this.server_Die();
	
	CBlob@[] blobsInRadius;
	if (getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		int blobSize = blobsInRadius.length;
		for (uint i = 0; i < blobSize; i++)
		{
			CBlob@ blob = blobsInRadius[i];
			if (blob is null || !blob.hasTag("flesh") || blob.hasTag("gas") || blob.hasTag("gas immune") || !blob.isCollidable()) { break; }

			blob.set_u8("mustard value", Maths::Clamp(blob.get_u8("mustard value") + 1, 0, 64));
		
			if (isServer()) this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.0625f, Hitters::burn);
		
			if (!blob.hasTag("mustarded"))
			{
				blob.set_u32("mustard time", getGameTime());
				blob.AddScript("MustardEffect.as");
				if (blob.isMyPlayer())
				{
					blob.getSprite().AddScript("MustardEffect.as");
				}
			}
		}
	}

	if(isClient())
	{
		if (this.isOnScreen()) 
		{
			MakeParticle(this, "Mustard.png");
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
 
// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// if (blob is null) return;
	// if (blob.hasTag("gas")) return;
// }

void MakeParticle(CBlob@ this, const string filename = "LargeSmoke")
{
	CParticle@ particle = ParticleAnimated(filename, this.getPosition() + Vec2f(16 - XORRandom(32), 8 - XORRandom(32)), Vec2f(), float(XORRandom(360)), 1.0f + (XORRandom(50) / 100.0f), 4, 0.00f, false);
	if (particle !is null) 
	{
		particle.collides = false;
		particle.bounce = 0.0f;
		particle.fastcollision = true;
		particle.lighting = false;
		particle.setRenderStyle(RenderStyle::additive);
	}
}