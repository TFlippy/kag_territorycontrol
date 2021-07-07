void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.addCommandID("consume");
	this.Tag("hopperable");
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
		//this.getSprite().PlaySound("sound here" + XORRandom(5), 1.50f, 1.00f);

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if (caller.hasScript("Babbyed.as")) caller.RemoveScript("Babbyed.as");       // maybe?
			else if (caller.hasScript("Drunk_Effect.as")) caller.RemoveScript("Drunk_Effect.as");
			else if (caller.hasScript("Bobomaxed.as")) caller.RemoveScript("Bobomaxed.as");
			else if (caller.hasScript("Bobonged.as")) caller.RemoveScript("Bobonged.as");
			else if (caller.hasScript("Boofed.as")) caller.RemoveScript("Boofed.as");
			else if (caller.hasScript("Crak_Effect.as")) caller.RemoveScript("Crak_Effect.as");
			else if (caller.hasScript("Drunk_Effect.as")) caller.RemoveScript("Drunk_Effect.as");
			else if (caller.hasScript("Dominoed.as")) caller.RemoveScript("Dominoed.as");
			else if (caller.hasScript("Fiksed.as")) caller.RemoveScript("Fiksed.as");
			else if (caller.hasScript("Foofed.as")) caller.RemoveScript("Foofed.as");
			else if (caller.hasScript("Fusk_Effect.as")) caller.RemoveScript("Fusk_Effect.as");
			else if (caller.hasScript("Gooby_Effect.as")) caller.RemoveScript("Gooby_Effect.as");
			else if (caller.hasScript("Love_Effect.as")) caller.RemoveScript("Love_Effect.as");
			else if (caller.hasScript("Paxilion_Effect.as")) caller.RemoveScript("Paxilion_Effect.as");
			else if (caller.hasScript("Pooted.as")) caller.RemoveScript("Pooted.as");
			else if (caller.hasScript("Propeskoed.as")) caller.RemoveScript("Propeskoed.as");
			else if (caller.hasScript("Rippioed.as")) caller.RemoveScript("Rippioed.as");
			else if (caller.hasScript("Schisked.as")) caller.RemoveScript("Schisked.as");
			else if (caller.hasScript("Stimed.as")) caller.RemoveScript("Stimed.as");
			caller.set_f32("tead", 5);
			
			if (isServer())
			{
				this.server_Die();
			}
		}
	}
}
