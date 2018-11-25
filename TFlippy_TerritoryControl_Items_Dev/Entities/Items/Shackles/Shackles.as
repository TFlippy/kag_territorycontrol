#include "Hitters.as";

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
			if (point.isKeyJustPressed(key_action1) && holder.isMyPlayer()) Sound::Play("/NoAmmo");
			return;
		}
		
		if (holder.get_u8("knocked") <= 0)
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
						if (blob !is null && blob.hasTag("player") && blob.getTeamNum() != team)
						{
							f32 chance = 1.0f - (blob.getHealth() / blob.getInitialHealth());
							print("" + chance);
						
							if ((chance > 0.50f && XORRandom(100) < chance * 80) || (blob.get_u8("knocked") > 15 && chance > 0.2f))
							{
								if (getNet().isClient())
								{
									this.getSprite().PlaySound("shackles_success.ogg", 1.25f, 1.00f);
								}
								
								if (getNet().isServer())
								{
									// CBlob@ slave = server_CreateBlob("slave", blob.getTeamNum(), blob.getPosition());
									CBlob@ slave = server_CreateBlob("slave", holder.getTeamNum(), blob.getPosition());
									if (slave !is null)
									{
										if (blob.getPlayer() !is null) slave.server_SetPlayer(blob.getPlayer());
										blob.server_Die();
										this.server_Die();
									}
								}
								
								return;
							}
							else
							{
								this.set_u32("next attack", getGameTime() + 90);
							
								if (getNet().isClient())
								{
									this.getSprite().PlaySound("shackles_fail.ogg", 0.80f, 1.00f);
								}
								
								return;
							}
						}
					}
				}
				
				if (holder.isMyPlayer()) Sound::Play("/NoAmmo");
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