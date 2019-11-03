


SColor HSVToRGB(f32 hue, f32 saturation, f32 value)
{
	f32 hh = hue / 60.0f;
	u32 i = hh;
	f32 ff = hh - i;

	f32 p = (1.0f - saturation);
	f32 q =	(1.0f - (saturation * ff));
	f32 t = (1.0f - (saturation * (1.0f - ff)));

	f32 r;
	f32 g;
	f32 b;

	if(i == 0)
	{
		r = value;
		g = t;
		b = p;
	}
	else if(i == 1)
	{
		r = q;
		g = value;
		b = p;
	}
	else if(i == 2)
	{
		r = p;
		g = value;
		b = t;
	}
	else if(i == 3)
	{
		r = p;
		g = q;
		b = value;
	}
	else if(i == 4)
	{
		r = t;
		g = p;
		b = value;
	}
	else
	{
		r = value;
		g = p;
		b = q;
	}

	return SColor(255, uint(r * 255.0f), uint(g * 255.0f), uint(b * 255.0f));
}


SColor RedToBlack(s16 time, f32 speed)
{
	float red = 0;
	if(time > 255)
	{
		red = 255;
		float rm = time * speed % 255;
		red -= rm;
	}
	else
	{
		red = time * speed;
	}
	

	return SColor(255,red,0,0);
}
