u32 next_rain = 0;

void onInit(CRules@ this)
{	
	this.set_bool("raining", false);
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
	if (getNet().isServer())
	{
		u32 time = getGameTime();
		if (time >= next_rain)
		{
			u32 length = 200 + XORRandom(250);

			if (!this.get_bool("raining"))
			{
				CBlob@ rain = server_CreateBlob("rain", 255, Vec2f(0, 0));
				rain.server_SetTimeToDie(length);
			}
			
			next_rain = time + length + 9000 + XORRandom(20000);
			// print("Rain start: " + start_rain + "; Length: " + (end_rain - start_rain));
		}
	}
}
