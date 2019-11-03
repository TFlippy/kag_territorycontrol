// FallOnNoSupport.as

void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 17;
}

void onTick(CBlob@ this)
{
	if (!isServer() || getGameTime() < 60) return;

	if (this.getShape().getCurrentSupport() < 0.001f)
	{
		this.server_Die();
		this.getSprite().Gib();
	}
}
