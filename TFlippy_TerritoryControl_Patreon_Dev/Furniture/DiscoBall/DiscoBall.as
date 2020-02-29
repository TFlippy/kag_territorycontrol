
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
	this.Tag("builder always hit");
	
	this.getShape().SetRotationsAllowed(true);
	this.Tag("place norotate");
	this.SetLightRadius(118.0f);

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Caramell.ogg");
	sprite.SetEmitSoundVolume(2.0f);
	sprite.SetEmitSoundSpeed(1.0f);
	sprite.SetEmitSoundPaused(false);

	if(!this.hasTag("placed"))
	{
		sprite.SetEmitSoundPaused(true);
		this.SetLight(false);
		this.SetLightColor(SColor(255, 255, 240, 171));
		sprite.getAnimation("default").loop = false;
	}

	for (int i = 0; i < beam_count; i++)
	{
		CSpriteLayer@ beam = sprite.addSpriteLayer("beam_" + i, "Discoball_Beam.png", 128, 6);
		if (beam !is null)
		{
			Animation@ anim = beam.addAnimation("default", 0, false);
			anim.AddFrame(0);
			beam.SetVisible(false);
			beam.setRenderStyle(RenderStyle::additive);
			beam.SetRelativeZ(-2.0f);
			beam.SetLighting(false);
		}
	}
}

const int beam_count = 6;

void onTick(CBlob@ this)
{
	if (this.hasTag("placed"))
	{	
		u32 time = getGameTime();
	
		CMap@ map = getMap();
		for (int i = 0; i < beam_count; i++)
		{
			Vec2f dir = getRandomVelocity(((time + (360 / beam_count * i)) % 360) + (Maths::Sin(time * 0.04f * i) * 0.50f) * 60, 128, 0);
			Vec2f hit_position = this.getPosition() + dir;
			
			map.rayCastSolid(this.getPosition(), hit_position, hit_position);
			
			UpdateBeam(this, i, hit_position, colors[(getGameTime() + i) % colors.size()]);
		}
	
		if (time % 10 == 0) 
		{
			const SColor color = colors[getGameTime() % colors.size()];
			this.SetLightColor(color);
			
			if (isClient())
			{
				CBlob@ localBlob = getLocalPlayerBlob();
				if (localBlob !is null)
				{
					if (this.getDistanceTo(localBlob) < 128)
					{
						SetScreenFlash(10, color.getRed(), color.getGreen(), color.getBlue(), 0.20f);
					}
				}
			}
		}
	}
}

void UpdateBeam(CBlob@ this, int index, Vec2f target, SColor color)
{
	CSpriteLayer@ beam = this.getSprite().getSpriteLayer("beam_" + index);
	if (beam !is null)	
	{
		Vec2f dir = target - this.getPosition();
		f32 length = dir.getLength();
		f32 angle = -dir.getAngle();
	
		f32 scale = length / 64.00f;
		f32 translate = length * 0.50f;
	
		beam.SetVisible(true);
		beam.ResetTransform();
		beam.ScaleBy(Vec2f(scale * 0.50f, 1));
		beam.TranslateBy(Vec2f(translate, 0));
		beam.RotateBy(angle, Vec2f());
		beam.SetColor(SColor(255, color.getRed() * brightness, color.getGreen() * brightness, color.getBlue() * brightness));
		beam.SetFacingLeft(true);
	}
}

f32 brightness = 0.50f;

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();

	if(isStatic) // has just been placed
	{
		this.getSprite().getAnimation("default").loop = true;
		this.SetLight(true);
		this.Tag("placed");
		sprite.RewindEmitSound();
		sprite.SetEmitSoundPaused(false);
	}
	else // has been picked up or something
	{
		this.getSprite().getAnimation("default").loop = false;
		this.SetLight(false);
		this.Untag("placed");
		sprite.SetEmitSoundPaused(true);
	}
	
	for (int i = 0; i < beam_count; i++)
	{
		CSpriteLayer@ beam = this.getSprite().getSpriteLayer("beam_" + i);
		if (beam !is null)	
		{
			beam.SetVisible(isStatic);
		}
	}
}