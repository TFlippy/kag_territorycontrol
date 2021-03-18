void TakeFuel(CBlob@ this, f32 amount)
{
	f32 max_fuel = this.get_f32("max_fuel");
	this.set_f32("fuel_count", Maths::Max(0, Maths::Min(max_fuel, this.get_f32("fuel_count") - amount)));
	this.Sync("fuel_count", true);
}

f32 GiveFuel(CBlob@ this, f32 amount, f32 modifier)
{
	f32 max_fuel = this.get_f32("max_fuel");
	s32 fuel_consumed = (s32(max_fuel) - s32(this.get_f32("fuel_count"))) / modifier;
	f32 remain = Maths::Max(0, s32(amount) - fuel_consumed);

	this.set_f32("fuel_count", Maths::Max(0, Maths::Min(max_fuel, this.get_f32("fuel_count") + ((amount - remain) * modifier))));
	
	// print("A: " + amount + "; R: " + remain);
	return remain;
}

f32 GetFuel(CBlob@ this)
{
	return this.get_f32("fuel_count");
}

f32 GetFuelModifier(string fuel_name, bool &out isValid, int fuellevel)
{
	f32 fuel_modifier = 1.00f;
	isValid = false;
	
	if(fuellevel <= 0)
	{
		if (fuel_name == "mat_wood")
		{
			fuel_modifier = 1.00f;
			isValid = true;
		}
		else if (fuel_name == "mat_coal")
		{
			fuel_modifier = 4.00f * 5.00f; // More coal than oil in a drum
			isValid = true;
		}
	}
	
	if(fuellevel <= 1)
	{
		if (fuel_name == "mat_oil")
		{
			fuel_modifier = 3.00f * 5.00f;
			isValid = true;
		}
		else if (fuel_name == "mat_methane")
		{
			fuel_modifier = 15.00f;
			isValid = true;
		}
	}
	
	if (fuel_name == "mat_fuel")
	{
		fuel_modifier = 100.00f;
		isValid = true;
	}
	
	return fuel_modifier;
}
