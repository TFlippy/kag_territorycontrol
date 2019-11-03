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
				blob.server_Heal(2.0f);
				
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



// void Heal(CBlob@ this, CBlob@ blob)
// {
	// bool exists = getBlobByNetworkID(this.getNetworkID()) !is null;
	// if (isServer() && blob.hasTag("player") && blob.getHealth() < blob.getInitialHealth() && !this.hasTag("healed") && exists)
	// {
		// CBitStream params;
		// params.write_u16(blob.getNetworkID());

		// u8 heal_amount = 255; //in quarter hearts, 255 means full hp

		// if (this.getName() == "heart")	    // HACK
		// {
			// heal_amount = 4;
		// }
		// else if (this.getName() == "ratburger") heal_amount = 8;
		// else if (this.getName() == "ratfood") heal_amount = 6;
		// else if (this.getName() == "food") heal_amount = 16;
		// else if (this.getName() == "cake") heal_amount = 10;
		// else if (this.getName() == "foodcan") heal_amount = 20;

		// params.write_u8(heal_amount);

		// this.SendCommand(this.getCommandID(heal_id), params);

		// this.Tag("healed");
	// }
// }

// void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
// {
	// if (cmd == this.getCommandID(heal_id))
	// {
		// this.getSprite().PlaySound(this.get_string("eat sound"));

		// if (isServer())
		// {
			// u16 blob_id;
			// if (!params.saferead_u16(blob_id)) return;

			// CBlob@ theBlob = getBlobByNetworkID(blob_id);
			// if (theBlob !is null)
			// {
				// u8 heal_amount;
				// if (!params.saferead_u8(heal_amount)) return;

				// if (heal_amount == 255)
				// {
					// theBlob.server_SetHealth(theBlob.getInitialHealth());
				// }
				// else
				// {
					// theBlob.server_Heal(f32(heal_amount) * 0.25f);
				// }

			// }

			// this.server_Die();
		// }
	// }
// }

// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// if (blob is null)
	// {
		// return;
	// }

	// if (isServer() && !blob.hasTag("dead"))
	// {
		// Heal(this, blob);
	// }
// }

// void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
// {
	// if (isServer())
	// {
		// Heal(this, attached);
	// }
// }

// void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint)
// {
	// if (isServer())
	// {
		// Heal(this, detached);
	// }
// }

