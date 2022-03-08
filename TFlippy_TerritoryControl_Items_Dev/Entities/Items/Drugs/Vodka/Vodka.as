void onInit(CBlob@ this)
{
	this.addCommandID("consume");
	this.Tag("hopperable");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller) || this.isAttachedTo(caller))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("consume"), "Drink!", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("consume"))
	{
		this.getSprite().PlaySound("gasp.ogg");
		this.getSprite().PlaySound("Gurgle2.ogg");

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{		
			if (!caller.hasScript("Drunk_Effect.as")) caller.AddScript("Drunk_Effect.as");			
			caller.add_f32("drunk_effect", 6);

			if (isServer())
			{
				this.server_Die();
			}
		}
	}
}