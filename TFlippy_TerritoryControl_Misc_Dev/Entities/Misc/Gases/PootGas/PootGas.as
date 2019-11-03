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
	this.getCurrentScript().tickFrequency = 1;
	
	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());
	this.server_SetTimeToDie(3 + XORRandom(10));
}

void onTick(CBlob@ this)
{
	if (isServer() && this.getPosition().y < 0) this.server_Die();
	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ blob = blobsInRadius[i];
			if (blob.hasTag("flesh") && !blob.hasTag("gas immune"))
			{
				if (!blob.hasScript("Pooted.as")) blob.AddScript("Pooted.as");
				blob.add_f32("pooted", 0.01f);
			
				// blob.set_u8("mustard value", Maths::Clamp(blob.get_u8("mustard value") + 1, 0, 64));
			
				// if (isServer()) this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.0625f, Hitters::burn);
			
				// if (!blob.hasTag("mustarded"))
				// {
					// blob.set_u32("mustard time", getGameTime());
					// blob.AddScript("MustardEffect.as");
					// blob.getSprite().AddScript("MustardEffect.as");
				// }
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
 
// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// if (blob is null) return;
	// if (blob.hasTag("gas")) return;
// }