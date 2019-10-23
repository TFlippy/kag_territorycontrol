#include "Hitters.as";
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
}

void onTick(CBlob@ this)
{	
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		
		if (holder is null) return;

		if (getKnocked(holder) <= 0)
		{
			if (holder.isKeyPressed(key_action1) || point.isKeyPressed(key_action1))
			{
				if (this.get_u32("next attack") > getGameTime()) return;
			
				if (isClient())
				{
					this.getSprite().PlaySound("BadgerPlushie_Squeak" + XORRandom(2) + ".ogg", 0.8f, 0.9f + (XORRandom(100) * 0.002f));
				}
				
				this.set_u32("next attack", getGameTime() + 10);
			}
		}
	}
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	detached.Untag("noLMB");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	attached.Tag("noLMB");
}