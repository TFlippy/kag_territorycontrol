#define SERVER_ONLY
u32 next_rain = 1000;

void onInit(CRules@ this)
{
	this.set_bool("raining", false);
	
	u32 time = getGameTime();
	next_rain = time + 2500 + XORRandom(40000);
}

void onRestart(CRules@ this)
{
	this.set_bool("raining", false);

	u32 time = getGameTime();
	next_rain = time + 2500 + XORRandom(40000);

	// print("Rain start: " + start_rain + "; Length: " + (end_rain - start_rain));
}

void onTick(CRules@ this)
{
	u32 time = getGameTime();
	if (time >= next_rain)
	{
		u32 length = (30 * 60 * 1) + XORRandom(30 * 60 * 5);

		if (!this.get_bool("raining"))
		{
			CBlob@ rain = server_CreateBlob("rain", 255, Vec2f(0, 0));
			rain.server_SetTimeToDie(length / 30.00f);
		}

		next_rain = time + length + 10000 + XORRandom(75000);
		// print("Rain start: " + start_rain + "; Length: " + (end_rain - start_rain));
	}
}
