void onInit(CBlob@ this)
{
	this.Tag("torso");
	
	if (this.getName() == "suicidevest")
	{
		this.Tag("explosive");
	}
}