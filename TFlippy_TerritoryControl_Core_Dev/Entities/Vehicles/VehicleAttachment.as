// requires VEHICLE attachment point

void onInit(CBlob@ this)
{
	this.addCommandID("detach vehicle");
	this.addCommandID("attach vehicle");
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_hasattached;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() != this.getTeamNum())
		return;

	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			if (ap !is null && (ap.socket && (ap.name.findFirst("VEHICLE") != -1 || ap.name.findFirst("CARGO") != -1)))
			{
				CBlob@ occBlob = ap.getOccupied();
				if (occBlob !is null) //detach button
				{
					CBitStream params;
					params.write_netid(occBlob.getNetworkID());
					caller.CreateGenericButton(1, ap.offset, this, this.getCommandID("detach vehicle"), "Detach " + occBlob.getInventoryName(), params);
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer() && cmd == this.getCommandID("attach vehicle"))
	{
		CBlob@ vehicle = getBlobByNetworkID(params.read_netid());
		const u8 id = params.read_u8();
		CAttachment@ att = this.getAttachments();
		if (vehicle !is null && att !is null)
		{
			this.server_AttachTo(vehicle, att.getAttachmentPointByID(id));
		}
	}
	else if (isServer() && cmd == this.getCommandID("detach vehicle"))
	{
		CBlob@ vehicle = getBlobByNetworkID(params.read_netid());
		if (vehicle !is null)
		{
			vehicle.server_DetachFrom(this);
		}
	}
}
