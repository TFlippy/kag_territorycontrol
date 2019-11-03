#include "Hitters.as";
#include "Knocked.as";
#include "Explosion.as";

const f32 max_range = 256.00f;

void onInit(CBlob@ this)
{
	this.getSprite().PlaySound("grenade_pinpull.ogg");

	this.Tag("projectile");
	this.server_SetTimeToDie(3);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid)
	{
		return;
	}

	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 1.7f)
	{
		Sound::Play("/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f), 1.2f);
	}
}

void onDie(CBlob@ this)
{
	CBlob@[] blobs;
	if (this.getMap().getBlobsInRadius(this.getPosition(), max_range, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			
			if (!this.getMap().rayCastSolidNoBlobs(blob.getPosition(), this.getPosition()))
			{
				f32 dist = (blob.getPosition() - this.getPosition()).getLength();
				f32 factor = 1.00f - Maths::Pow(dist / max_range, 2);
			
				// SetKnocked(blob, 250 * factor);
			
				if (blob is getLocalPlayerBlob())
				{		
					SetScreenFlash(255, 255, 255, 255, 30 * factor);
				}
			}
		}
	}
	
	if (isClient())
	{
		this.getSprite().PlaySound("FlashGrenade_Boom.ogg");
	}
	
	Explode(this, 0.01f, 0.00f);
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}
