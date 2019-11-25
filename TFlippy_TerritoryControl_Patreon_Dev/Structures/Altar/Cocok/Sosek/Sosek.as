void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.addCommandID("consume");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("consume"), "Suck!", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("consume"))
	{
		this.getSprite().PlaySound("shid.ogg", 0.50f, this.get_f32("voice pitch"));

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{		
			if (!caller.hasScript("Sosek_Effect.as")) caller.AddScript("Sosek_Effect.as");
			caller.add_f32("sosek_effect", 1);

			if (isServer())
			{
				this.server_Die();
			}
		}
	}
}
