void onInit(CBlob@ this)
{
	this.addCommandID("consume");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("consume"), "Drink!", params);
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
			if (!caller.exists("drunk") || caller.get_u16("drunk") == 0) caller.AddScript("Drunk.as");
		
			caller.set_u16("drunk", Maths::Min(caller.get_u16("drunk") + 1, 250));
			caller.set_u32("next sober", getGameTime());
			
			if (getNet().isServer())
			{
				this.server_Die();
			}
		
		}
	}
}
