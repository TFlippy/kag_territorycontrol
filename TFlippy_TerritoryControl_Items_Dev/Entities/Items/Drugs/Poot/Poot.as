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
	
	// this.getSprite().addAnimation("honk", 0, false);
}

void onTick(CBlob@ this)
{	
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null) {return;}
		CBlob@ holder = point.getOccupied();
		
		if (holder is null) {return;}

		if (getKnocked(holder) <= 0)
		{
			if (holder.isKeyPressed(key_action1) || point.isKeyPressed(key_action1))
			{
				if (this.get_u32("next attack") > getGameTime()) return;
			
				if (isClient())
				{
					this.getSprite().PlaySound("drunk_fx3.ogg", 0.8f, 0.75f);
					this.getSprite().SetAnimation("default");
					this.getSprite().SetAnimation("honk");
				}
				
				if (isServer())
				{
					CBlob@ blob = server_CreateBlobNoInit("pootgas");
					blob.setVelocity(Vec2f(holder.isFacingLeft() ? -3 : 3, 0));
					blob.server_setTeamNum(holder.getTeamNum());
					blob.setPosition(this.getPosition());
					blob.Init();
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