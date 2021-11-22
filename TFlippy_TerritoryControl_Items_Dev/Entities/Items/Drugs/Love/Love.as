void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.addCommandID("consume");
	this.Tag("hopperable");
	this.maxQuantity = 2;
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
		// this.getSprite().PlaySound("Huuu.ogg", 1.0f, 1.5f);
		this.getSprite().PlaySound("Pus_Attack_0.ogg", 2.00f, 1.00f);

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if (!caller.hasScript("Love_Effect.as")) caller.AddScript("Love_Effect.as");
			// caller.add_f32("love_effect", caller.get_f32("love_effect"));
			
			if (isServer())
			{
				int8 remain = this.getQuantity() - 1;
				if (remain > 0)
				{
					this.server_SetQuantity(remain);
				}
				else
				{
					this.Tag("dead");
					this.server_Die();
				}
			}
		}
	}
}
