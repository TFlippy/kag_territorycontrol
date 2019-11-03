
void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());
	f32 acceleration = 1.00f + (Maths::Pow(rand.NextFloat(), 5) * 3.00f);
	
	this.Tag("heavy weight");
	this.set_f32("gyromat_value", acceleration);
	
	this.setInventoryName("Accelerated Gyromat\n+" + Maths::Round(acceleration * 100.00f) + "% speed");
	
	CSprite@ sprite = this.getSprite();
	sprite.RewindEmitSound();
	sprite.SetEmitSound("Gyromat_Loop.ogg");
	sprite.SetEmitSoundSpeed(Maths::Clamp(0.50f + acceleration / 4.00f, 0.50f, 2.00f));
	sprite.SetEmitSoundVolume(0.15f * acceleration);
	sprite.SetEmitSoundPaused(false);
	
	Animation@ animation = sprite.getAnimation("default");
	if (animation !is null)
	{
		animation.time = 6.00f / acceleration;
	}
}

