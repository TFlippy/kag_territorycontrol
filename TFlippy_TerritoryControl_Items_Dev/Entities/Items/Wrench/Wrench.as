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

		if (getKnocked(holder) <= 0) //Cant wrench while stunned
		{
			if (holder.isKeyPressed(key_action1) || point.isKeyPressed(key_action1))
			{
				if (this.get_u32("next attack") > getGameTime()) return;
				Vec2f pos = holder.getAimPos();
				
				if ((pos - this.getPosition()).getLength() < 48) //Range
				{
					getMap().rayCastSolidNoBlobs(this.getPosition(), pos, pos);
					CBlob@ blob = getMap().getBlobAtPosition(pos);
					if (blob !is null && blob.getHealth() < blob.getInitialHealth()) //Must be damaged
					{
						if (blob.hasTag("vehicle") || blob.getShape().isStatic() && !blob.hasTag("nature"))
						{
							if (isServer())
							{
								blob.Tag("MaterialLess"); //No more materials can be harvested by mining this (prevents abuse with stone doors)
								if (blob.getShape().isStatic())
								{
									blob.server_Heal(2); //Remember this is halved
								}
								else
								{
									blob.server_Heal(1); //Only heals a small amount, bizaarly the actual healing amount is half of this
								}
								//print("health"+blob.getHealth() + " "+ blob.getInitialHealth());
							}
							if (isClient())
							{
								sparks(blob.getPosition(), 1, 0.25f);
							}
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