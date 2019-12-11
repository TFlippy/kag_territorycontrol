
void onTick(CBlob@ this)
{
	if (XORRandom(500) == 0)
	{
		u32 fly_time = Maths::Ceil(this.get_f32("fly_time"));
		for (int i = 0; i < fly_time; i++)
		{
			this.set_f32("fly_time", this.get_f32("fly_time") + 4);
		}
	}
} 