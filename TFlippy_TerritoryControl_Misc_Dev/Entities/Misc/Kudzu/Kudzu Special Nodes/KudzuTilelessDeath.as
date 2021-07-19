#include "FireCommon.as"
#include "KudzuCommon.as"

void onInit(CBlob @ this)
{
	this.getCurrentScript().tickFrequency = 300;
}

void onTick(CBlob@ this)
{
	if (isDead(Vec2f(this.getPosition().x, this.getPosition().y), getMap()))
	{
		this.server_Die();
	}
}