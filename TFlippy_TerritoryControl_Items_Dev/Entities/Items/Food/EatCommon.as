const string heal_id = "heal command";

bool canEat(CBlob@ blob)
{
	return blob.exists("eat sound");
}

// returns the healing amount of a certain food (in quarter hearts) or 0 for non-food
u8 getHealingAmount(CBlob@ food)
{
	if (!canEat(food))
	{
		return 0;
	}

	string name = food.getName();
	const int hash = name.getHash();
	u8
		heal_amount = 4; // things that might've been missed

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
	return heal_amount;
}

void Heal(CBlob@ this, CBlob@ food)
{
	bool exists = getBlobByNetworkID(food.getNetworkID()) !is null;
	if (isServer() && this.hasTag("player") && this.getHealth() < this.getInitialHealth() && !food.hasTag("healed") && exists)
	{
		CBitStream params;
		params.write_u16(this.getNetworkID());
		params.write_u8(getHealingAmount(food));
		food.SendCommand(food.getCommandID(heal_id), params);

		this.Tag("healed");
	}
}
