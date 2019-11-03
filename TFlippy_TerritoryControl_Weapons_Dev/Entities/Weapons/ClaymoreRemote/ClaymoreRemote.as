void onInit(CBlob@ this)
{
	this.addCommandID("detonate");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("detonate"), "Detonate!", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("detonate"))
	{
		this.getSprite().PlaySound("mechanical_click.ogg", 4.0f);
		if(isServer())
		{
			CBlob@ blob = getBlobByNetworkID(params.read_u16());
			if(blob is null) return;

			CPlayer@ caller = blob.getPlayer();
			if(caller is null) return;

			CBlob@[] claymores;
			getBlobsByName('claymore', @claymores);

			for(int i = 0; i < claymores.length; i++)
			{
				CBlob@ claymore = claymores[i];
				CPlayer@ owner = claymores[i].getDamageOwnerPlayer();
				
				if(owner !is null && owner.getNetworkID() == caller.getNetworkID())
				{
					if(claymore.get_u8("mine_state") == 1) // Primed?
					{
						// Yup, blow 'em away!
						claymore.Tag("exploding");
						claymore.Sync("exploding", true);

						claymore.server_SetHealth(-1.0f);
						claymore.server_Die();
					}
				}
			}
		}
	}
}
