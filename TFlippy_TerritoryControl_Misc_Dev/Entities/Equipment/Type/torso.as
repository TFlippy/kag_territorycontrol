void onInit(CBlob@ this)
{
	this.Tag("torso");
	
	if (this.getConfig() == "suicidevest")
	{
		this.Tag("explosive");
	}
}