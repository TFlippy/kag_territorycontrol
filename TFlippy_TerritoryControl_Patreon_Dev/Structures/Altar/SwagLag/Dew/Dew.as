void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.addCommandID("consume");
	this.Tag("hopperable");
	this.maxQuantity = 4;
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
			if (!caller.hasScript("Dew_Effect.as")) caller.AddScript("Dew_Effect.as");
			caller.add_f32("dew_effect", 1);

			if (isClient() && caller.isMyPlayer())
			{	
				Sound::Play("MLG_Airhorn.ogg");
				getMap().CreateSkyGradient("skygradient_dew.png");
				
				CSprite@ sprite = caller.getSprite();
				sprite.SetEmitSound("AltarSwagLag_Music.ogg");
				sprite.SetEmitSoundVolume(1.00f);
				sprite.SetEmitSoundSpeed(1.00f);
				sprite.SetEmitSoundPaused(false);
			}

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
