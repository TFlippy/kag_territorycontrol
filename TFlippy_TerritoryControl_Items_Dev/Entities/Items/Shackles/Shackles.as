#include "Hitters.as";
#include "Knocked.as";
#include "Survival_Structs.as";
#include "DeityCommon.as";

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
		if(point is null){return;}
		CBlob@ holder = point.getOccupied();
		
		if (holder is null){return;}
		u8 team = holder.getTeamNum();
		
		TeamData@ team_data;
		GetTeamData(team, @team_data);

		bool slavery_enabled = true;
		
		if (team_data != null)
		{
			slavery_enabled = team_data.slavery_enabled;
			// print("" + slavery_enabled);
		}
		
		if (point.isKeyJustPressed(key_action1))
		{
			if (slavery_enabled && getGameTime() >= this.get_u32("next attack") && getKnocked(holder) <= 0)
			{
				HitInfo@[] hitInfos;
				if (getMap().getHitInfosFromArc(this.getPosition(), -(holder.getAimPos() - this.getPosition()).Angle(), 45, 16, this, @hitInfos))
				{
					for (uint i = 0; i < hitInfos.length; i++)
					{
						CBlob@ blob = hitInfos[i].blob;
						if (blob !is null && blob.hasTag("player") && blob.getTeamNum() != team && (blob.get_u8("deity_id") != Deity::ivan || blob.get_u8("deity_id") != Deity::swaglag))
						{
							f32 chance = 1.0f - (blob.getHealth() / blob.getInitialHealth());
							if (blob.get_f32("babbyed") > 0) chance = 1.00f;
							
							// print("" + chance);
						
							if ((chance > 0.50f && XORRandom(100) < chance * 80) || (getKnocked(blob) > 15 && chance > 0.2f))
							{
								// if (isClient())
								// {
									// this.getSprite().PlaySound("shackles_success.ogg", 1.25f, 1.00f);
								// }
								
								if (isServer())
								{
									CBlob@ slave = server_CreateBlob("slave", holder.getTeamNum(), blob.getPosition());
									slave.set_u8("slaver_team", holder.getTeamNum());
									
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
							
								if (isClient())
								{
									this.getSprite().PlaySound("shackles_fail.ogg", 0.80f, 1.00f);
								}
								
								return;
							}
						}
					}
				}
			}
			else
			{
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