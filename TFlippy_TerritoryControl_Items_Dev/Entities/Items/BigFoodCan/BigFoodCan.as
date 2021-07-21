const u8 food_max = 20;

void onInit(CBlob@ this)
{
	this.Tag("food");

	this.getShape().SetRotationsAllowed(false);
	this.addCommandID("food_eat");

	this.set_u8("food_amount", food_max);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller is null) return;

	if (caller.getHealth() < caller.getInitialHealth())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());

		CButton@ button = caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("food_eat"), "Eat (" + this.get_u8("food_amount") + "/" + food_max + ")", params);
		button.enableRadius = 32.0f;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("food_eat"))
	{
		this.getSprite().PlaySound("Eat.ogg");

		if (isServer())
		{
			u16 blob_id;
			if (!params.saferead_u16(blob_id)) return;

			CBlob@ blob = getBlobByNetworkID(blob_id);

			if (blob !is null)
			{
				blob.server_Heal(5.0f);

				if (this.get_u8("food_amount") <= 1) this.server_Die();
				else
				{
					this.set_u8("food_amount", this.get_u8("food_amount") - 1);
					this.Sync("food_amount", true);
				}
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}
