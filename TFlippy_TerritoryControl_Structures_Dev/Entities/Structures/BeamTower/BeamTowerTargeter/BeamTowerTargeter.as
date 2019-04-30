void onInit(CBlob@ this)
{
	this.addCommandID("targeter_set_link");
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		
		if (holder !is null && holder.get_u8("knocked") <= 0)
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
						tower.SendCommand(tower.getCommandID("beam_fire"), stream);
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

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("targeter_set_link"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			CBlob@ carried = caller.getCarriedBlob();
			if (carried !is null && carried.getConfig() == "securitycard")
			{
				if (this.get_u32("security_link_id") == 0)
				{
					this.set_u32("security_link_id", carried.get_u32("security_link_id"));
				}
				else if (this.get_u32("security_link_id") == carried.get_u32("security_link_id"))
				{
					this.set_u32("security_link_id", 0);
				}
			}
		}
	}
}