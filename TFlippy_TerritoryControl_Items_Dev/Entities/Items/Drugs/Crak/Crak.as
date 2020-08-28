void onInit(CBlob@ this)
{
	this.addCommandID("consume");
	this.Tag("hopperable");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("consume"), "Smoke!", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("consume"))
	{
		this.getSprite().PlaySound("Gurgle2.ogg");

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if (!caller.hasScript("Crak_Effect.as")) caller.AddScript("Crak_Effect.as");
			caller.add_f32("crak_effect", 1.00f);
			
			if (isServer())
			{
				this.server_Die();
			}
		}
	}
}
