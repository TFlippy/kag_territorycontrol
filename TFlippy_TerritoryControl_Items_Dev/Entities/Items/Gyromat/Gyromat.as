
void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());
	f32 acceleration = 1.00f + (Maths::Pow(rand.NextFloat(), 5) * 3.00f);
	
	this.Tag("heavy weight");
	this.set_f32("gyromat_value", acceleration);
	
	this.setInventoryName("Accelerated Gyromat\n+" + Maths::Round(acceleration * 100.00f) + "% speed");
	
	Animation@ animation = this.getSprite().getAnimation("default");
	if (animation !is null)
	{
		animation.time = 6.00f / acceleration;
	}
}

