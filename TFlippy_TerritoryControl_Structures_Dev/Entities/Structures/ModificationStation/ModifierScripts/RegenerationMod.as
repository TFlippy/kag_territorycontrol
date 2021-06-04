
void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 60;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	this.server_Heal(0.25f);
}
