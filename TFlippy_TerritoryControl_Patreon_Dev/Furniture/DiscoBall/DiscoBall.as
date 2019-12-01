
const SColor[] colors = 
{
	0xFF4F9B7F,
	0xFFD5543F,
	0xFF4149F0,
	0xFF9DCA22,
	0xFFFFC64B,
	0xFFD379E0
};

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.Tag("place norotate");
	this.SetLightRadius(128.0f);

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("caramell.ogg");
	sprite.SetEmitSoundVolume(1.0f);
	sprite.SetEmitSoundSpeed(1.0f);
	sprite.SetEmitSoundPaused(false);

	if(!this.hasTag("placed"))
	{
		sprite.SetEmitSoundPaused(true);
		this.SetLight(false);
		this.SetLightColor(SColor(255, 255, 240, 171));
		sprite.getAnimation("default").loop = false;
	}
}

void onTick(CBlob@ this)
{
	if(this.hasTag("placed"))
	{
		if (getGameTime() % 10 == 0) 
		{
			const SColor color = colors[getGameTime() % colors.length()];
			this.SetLightColor(color);
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if(isStatic) // has just been placed
	{
		this.getSprite().getAnimation("default").loop = true;
		this.SetLight(true);
		this.Tag("placed");
		this.getSprite().SetEmitSoundPaused(false);
	}
	else // has been picked up or something
	{
		this.getSprite().getAnimation("default").loop = false;
		this.SetLight(false);
		this.Untag("placed");
		this.getSprite().SetEmitSoundPaused(true);
	}
}