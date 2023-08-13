
void onInit(CBlob@ this)
{
	//this.set_u16("ReturningMod Target");
	this.getCurrentScript().tickFrequency = 30;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	CBlob@ target = getBlobByNetworkID(this.get_u16("ReturningMod Target"));

	if(target != null && !target.hasTag("dead")) //No target no moving
	{
		Vec2f direction = target.getPosition() - this.getPosition();
		direction.Normalize();
		direction += Vec2f(0, -2.0f);
		//print("Test");
		this.AddForce(direction * this.getMass() * 2.0f);
		MakeParticle(this, -direction * 0.2f, "SmallSteam");
		//this.getSprite().PlaySound("/Jetpack_Offblast.ogg"); too loud
	}
	else
	{
		this.RemoveScript("ReturningMod.as");
	}
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(filename, this.getPosition() + random, vel, float(XORRandom(360)), 1.0f, 1 + XORRandom(2), -0.005f, true);
}
