void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.addCommandID("consume");
	this.Tag("hopperable");
	
	this.Tag("forcefeed_always");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller) || this.isAttachedTo(caller))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("consume"), "Inject!", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("consume"))
	{
		// this.getSprite().PlaySound("Huuu.ogg", 1.0f, 1.5f);
		this.getSprite().PlaySound("Pus_Attack_0.ogg", 2.00f, 1.00f);

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if (!caller.hasScript("Paxilon_Effect.as")) caller.AddScript("Paxilon_Effect.as");
			caller.add_f32("paxilon_effect", 1.00f);
			
			if (isServer())
			{
				this.server_Die();
			}
		}
	}
}
