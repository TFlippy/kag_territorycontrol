#include "Hitters.as";
#include "HittersTC.as";
#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.Tag("ignore fall");
	this.set_u32("next attack", 0);

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2);
	}
}

void onTick(CBlob@ this)
{	
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		
		if (holder is null) return;

		if (this.get_u32("next attack") > getGameTime())
		{
			if (this.get_u32("next attack") - getGameTime() > 20)
			{
				this.getSprite().ResetTransform();
				this.getSprite().RotateBy((getGameTime() - this.get_u32("next attack")) * -40, Vec2f());
			}
			else this.getSprite().ResetTransform();
			
			return;
		}
		
		if (getKnocked(holder) <= 0)
		{		
			if (point.isKeyJustPressed(key_action1))
			{
				u8 team = holder.getTeamNum();
				
				HitInfo@[] hitInfos;
				if (getMap().getHitInfosFromArc(this.getPosition(), -(holder.getAimPos() - this.getPosition()).Angle(), 45, 16, this, @hitInfos))
				{
					for (uint i = 0; i < hitInfos.length; i++)
					{
						CBlob@ blob = hitInfos[i].blob;
						if (blob !is null && blob.hasTag("flesh"))
						{
							u8 knock;
						
							if (blob.getName() == "slave") knock = 45 + (1.0f - (blob.getHealth() / blob.getInitialHealth())) * (30 + XORRandom(50)) * 4.0f;
							else knock = 35 + (1.0f - (blob.getHealth() / blob.getInitialHealth())) * (30 + XORRandom(50));
						
							SetKnocked(blob, knock);
							
							// if (isClient())
							// {
								// this.getSprite().PlaySound("nightstick_hit" + (1 + XORRandom(3)) + ".ogg", 0.9f, 0.8f);
							// }
							
							if (isServer())
							{
								holder.server_Hit(blob, blob.getPosition(), Vec2f(), 0.125f, HittersTC::staff, true);
								holder.server_Hit(this, this.getPosition(), Vec2f(), 0.125f, HittersTC::staff, true);
							}
						}
					}
				}
				
				this.set_u32("next attack", getGameTime() + 30);
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

