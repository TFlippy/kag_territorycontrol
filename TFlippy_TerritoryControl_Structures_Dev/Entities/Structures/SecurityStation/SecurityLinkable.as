
// A script by TFlippy

void onInit(CBlob@ this)
{
	this.Tag("security_linkable");
	
	this.set_u32("security_link_id", 0);
	if (!this.exists("security_state")) this.set_bool("security_state", false);
	
	this.addCommandID("security_set_link");
	this.addCommandID("security_set_state");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("security_set_link"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			CBlob@ carried = caller.getCarriedBlob();
			if (carried !is null && carried.getName() == "securitycard")
			{
				if (this.get_u32("security_link_id") == 0)
				{
					this.set_u32("security_link_id", carried.get_u32("security_link_id"));
				}
				else if (this.get_u32("security_link_id") == carried.get_u32("security_link_id"))
				{
					this.set_u32("security_link_id", 0);
				}
				// print("set link to " + carried.get_u32("security_link_id"));
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getTeamNum() != 250)
	{
		CBlob@ carried = caller.getCarriedBlob();
		if (carried !is null && carried.getName() == "securitycard")
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			if (this.get_u32("security_link_id") == 0) // Link
			{
				CButton@ button = caller.CreateGenericButton(2, Vec2f(0, 8), this, this.getCommandID("security_set_link"), "Link Security Card", params);
			}
			else if ( this.get_u32("security_link_id") == carried.get_u32("security_link_id")) // Unlink
			{
				CButton@ button = caller.CreateGenericButton(3, Vec2f(0, 8), this, this.getCommandID("security_set_link"), "Unlink Security Card", params);
			}
			else // Go to hell, you have the wrong card
			{
				CButton@ button = caller.CreateGenericButton(2, Vec2f(0, 8), this, this.getCommandID("security_set_link"), "Link Security Card", params);
				button.SetEnabled(false);
			}
		}
	}
}