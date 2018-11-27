uint start_rain = 0;
uint end_rain = 0;

void onInit(CRules@ this)
{	
	// print("Rain start: " + start_rain + "; Length: " + (end_rain - start_rain));
	this.set_bool("raining", false);
}

void onRestart(CRules@ this)
{
	this.set_bool("raining", false);

	u32 time = getGameTime();
	
	start_rain = time + 3000 + XORRandom(50000);
	end_rain = start_rain + 1800 + XORRandom(6000);
	print("Rain start: " + start_rain + "; Length: " + (end_rain - start_rain));
}

void onTick(CRules@ this)
{
	if (getNet().isServer())
	{
		u32 time = getGameTime();
				
		if (time == start_rain)
		{
			if (!this.get_bool("raining"))
			{
				CBlob@ rain = server_CreateBlobNoInit("rain");
				rain.Init();
				rain.server_SetTimeToDie((end_rain - start_rain) / 30);
			}
			
			end_rain = time + 1800 + XORRandom(6000);
			start_rain = end_rain + 1800 + XORRandom(50000);
			print("Rain start: " + start_rain + "; Length: " + (end_rain - start_rain));
		}
	}
}

// void onRender(CRules@ this)
// {
	
// }