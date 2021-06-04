
void onInit(CBlob@ this)
{
	//this.set_u16("ReturningMod Target");
	this.getCurrentScript().tickFrequency = 30;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	CBlob@ target = getBlobByNetworkID(this.get_u16("ReturningMod Target"));

	if(target != null) //No target no paying for stuff
	{
		Vec2f direction = target.getPosition() - this.getPosition();
		direction.Normalize();
		direction += Vec2f(0, -2.0f);
		print("Test");
		this.AddForce(direction * this.getMass() * 2.0f);
	}
}
