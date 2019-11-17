
const string heal_id = "heal command";

void onInit(CBlob@ this)
{
	if (!this.exists("eat sound"))
	{
		this.set_string("eat sound", "/Eat.ogg");
	}
	
	this.Tag("food");
	this.Tag("hopperable");

	this.addCommandID(heal_id);
}

void Heal(CBlob@ this, CBlob@ blob)
{
	bool exists = getBlobByNetworkID(this.getNetworkID()) !is null;
	if (isServer() && blob.hasTag("player") && blob.getHealth() < blob.getInitialHealth() && !this.hasTag("healed") && exists)
	{
		CBitStream params;
		params.write_u16(blob.getNetworkID());

		u8 heal_amount = 255; //in quarter hearts, 255 means full hp
		string name = this.getName();

		if (name == "heart") heal_amount = 1;
		else if (name == "ratburger") heal_amount = 3;
		else if (name == "ratfood") heal_amount = 2;
		else if (name == "food") heal_amount = 4;
		else if (name == "cake") heal_amount = 3;
		else if (name == "foodcan") heal_amount = 20;
		else if (name == "pumpkin") heal_amount = 7;
		else if (name == "icecream") heal_amount = 2;
		else if (name == "doritos") heal_amount = 8;

		params.write_u8(heal_amount);

		this.SendCommand(this.getCommandID(heal_id), params);

		this.Tag("healed");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID(heal_id))
	{
		this.getSprite().PlaySound(this.get_string("eat sound"));

		if (isServer())
		{
			u16 blob_id;
			if (!params.saferead_u16(blob_id)) return;

			CBlob@ theBlob = getBlobByNetworkID(blob_id);
			if (theBlob !is null)
			{
				u8 heal_amount;
				if (!params.saferead_u8(heal_amount)) return;

				if (heal_amount == 255)
				{
					theBlob.server_SetHealth(theBlob.getInitialHealth());
				}
				else
				{
					theBlob.server_Heal(heal_amount);
				}

			}

			this.server_Die();
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null)
	{
		return;
	}

	if (isServer() && !blob.hasTag("dead"))
	{
		Heal(this, blob);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (isServer())
	{
		Heal(this, attached);
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint)
{
	if (isServer())
	{
		Heal(this, detached);
	}
}

