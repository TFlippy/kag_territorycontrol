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
	u8 heal_amount = 4; // things that might've been missed
	if (name == "heart") heal_amount = 1;
	else if (name == "cake") 		heal_amount = 3;
	else if (name == "food") 		heal_amount = 4;
	else if (name == "foodcan") 	heal_amount = 20;
	else if (name == "grain") 		heal_amount = 2;
	else if (name == "ratfood") 	heal_amount = 2;
	else if (name == "ratburger") 	heal_amount = 3;
	else if (name == "pumpkin") 	heal_amount = 7;
	else if (name == "steak") 		heal_amount = 4;
	else if (name == "icecream") 	heal_amount = 3;
	else if (name == "doritos") 	heal_amount = 8;
	return heal_amount;
}

void Heal(CBlob@ this, CBlob@ food)
{
	bool exists = getBlobByNetworkID(food.getNetworkID()) !is null;
	if (getNet().isServer() && this.hasTag("player") && this.getHealth() < this.getInitialHealth() && !food.hasTag("healed") && exists)
	{
		CBitStream params;
		params.write_u16(this.getNetworkID());
		params.write_u8(getHealingAmount(food));
		food.SendCommand(food.getCommandID(heal_id), params);

		this.Tag("healed");
	}
}
