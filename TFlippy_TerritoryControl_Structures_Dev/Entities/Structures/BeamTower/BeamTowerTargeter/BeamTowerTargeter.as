#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.addCommandID("targeter_set_link");
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point !is null)
		{
			CBlob@ holder = point.getOccupied();
		
			if (holder !is null && getKnocked(holder) <= 0)
			{
				CSprite@ sprite = this.getSprite();
				const bool lmb = holder.isKeyJustPressed(key_action1) || point.isKeyPressed(key_action1);
				
				if (lmb)
				{
					CBlob@ tower = getBlobByNetworkID(this.get_u16("tower_netid"));
					if (tower !is null)
					{
						// this.getSprite().PlaySound("BeamTowerTargeter_Success.ogg", 0.50f, 1.00f);
					
						CBlob@ localBlob = getLocalPlayerBlob();
						if (localBlob !is null && localBlob is holder)
						{
							CBitStream stream;
							stream.write_Vec2f(localBlob.getAimPos());
							tower.SendCommand(tower.getCommandID("beam_fire_signal"), stream);
						}
					}
					else
					{
						this.getSprite().PlaySound("BeamTowerTargeter_Failed.ogg", 0.50f, 1.00f);
					}
				}
			}
		}
	}
}