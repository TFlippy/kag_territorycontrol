#include "Hitters.as";
#include "ParticleSparks.as";
#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.Tag("ignore fall");
	this.set_u32("next attack", 0);

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}
	
	// this.getSprite().addAnimation("honk", 0, false);
}

void onTick(CBlob@ this)
{	
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null){return;}
		CBlob@ holder = point.getOccupied();
		
		if (holder is null){return;}

		if (getKnocked(holder) <= 0)
		{
			if (holder.isKeyPressed(key_action1) || point.isKeyPressed(key_action1))
			{
				if (this.get_u32("next attack") > getGameTime()) return;
				Vec2f pos = holder.getAimPos();
			
				if (isClient())
				{
					this.getSprite().PlaySound("Lighter_Use", 1.00f, 0.90f + (XORRandom(100) * 0.30f));
					sparks(this.getPosition(), 1, 0.25f);
				}
				
				if (isServer())
				{
					if ((pos - this.getPosition()).getLength() < 32)
					{
						getMap().rayCastSolidNoBlobs(this.getPosition(), pos, pos);
						CBlob@ blob = getMap().getBlobAtPosition(pos);
						
						if (blob !is null)
						{
							this.server_Hit(blob, pos, Vec2f(0, 0), 0.25f, Hitters::fire, true);
						}
						else
						{
							getMap().server_setFireWorldspace(pos, true);
						}
					}
				}
				
				this.set_u32("next attack", getGameTime() + 20);
			}
		}
	}
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	detached.Untag("noLMB");
	// detached.Untag("noShielding");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	attached.Tag("noLMB");
	// attached.Tag("noShielding");
}