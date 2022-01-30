
const string heal_id = "heal command";

void onInit(CBlob@ this)
{
	if (!this.exists("eat sound"))
	{
		this.set_string("eat sound", "/Eat.ogg");
	}

	string name = this.getName();
	const int hash = name.getHash();
	switch(hash)
	{
		// heart
		case 246031843:	
			this.maxQuantity = 2;
			break;
		// cake
		case -1964341159:
			this.maxQuantity = 1;
			break;
		// food
		case 1028682697:
			this.maxQuantity = 2;
			break;
		// foodcan
		case 1260223417:
			this.maxQuantity = 4;
			break;
		// grain
		case -1788840884:
			this.maxQuantity = 20;
			break;
		// ratfood
		case 1197821324:
			this.maxQuantity = 2;
			break;
		// ratburger
		case -527037763:
			this.maxQuantity = 1;
			break;
		// pumpkin
		case -642166209:
			this.maxQuantity = 2;
			break;
		// steak
		case 336243301:	
			this.maxQuantity = 2;
			break;
		// icecream
		case 258075966:	
			this.maxQuantity = 2;
			break;
		// doritos
		case 739538537:	
			this.maxQuantity = 6;
			break;
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

		string name = this.getName();
		const int hash = name.getHash();
		u8 heal_amount = 4; // things that might've been missed

		switch(hash)
		{
			// heart
			case 246031843:	
				heal_amount = 1;
				break;
			// cake
			case -1964341159:
				heal_amount = 3;
				break;
			// food
			case 1028682697:
				heal_amount = 4;
				break;
			// foodcan
			case 1260223417:
				heal_amount = 12;
				break;
			// grain
			case -1788840884:
				heal_amount = 2;
				break;
			// ratfood
			case 1197821324:
				heal_amount = 2;
				break;
			// ratburger
			case -527037763:
				heal_amount = 3;
				break;
			// pumpkin
			case -642166209:
				heal_amount = 7;
				break;
			// steak
			case 336243301:	
				heal_amount = 4;
				break;
			// icecream
			case 258075966:	
				heal_amount = 3;
				break;
			// doritos
			case 739538537:	
				heal_amount = 8;
				break;
		}

		params.write_u8(heal_amount);
		this.Tag("healed");
		
		this.SendCommand(this.getCommandID(heal_id), params);
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

				int remain = this.getQuantity() - 1;
				if (remain > 0)
				{
					this.server_SetQuantity(remain);
				}
				else
				{
					this.Tag("dead");
					this.server_Die();
				}
				this.Untag("healed");
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
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
