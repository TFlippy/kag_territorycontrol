void onInit(CBlob@ this)
{
	this.addCommandID("consume");
	this.Tag("hopperable");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("consume"), "Eat!", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("consume"))
	{
		this.getSprite().PlaySound("Huuu.ogg", 1.0f, 1.5f);
		this.getSprite().PlaySound("Gurgle2.ogg");

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if (!caller.exists("bobomaxed") || caller.get_u8("bobomaxed") == 0) caller.AddScript("Bobomaxed.as");
		
			caller.set_u8("bobomaxed", Maths::Min(caller.get_u8("bobomaxed") + 1, 250));
			
			if (isServer())
			{
				this.server_Die();
			}
		
		}
	}
}
