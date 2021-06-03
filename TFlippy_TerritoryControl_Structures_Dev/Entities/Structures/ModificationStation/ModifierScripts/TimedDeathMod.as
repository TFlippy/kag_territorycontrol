#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.set_u16("Death Time Mod", getGameTime() + 900);
}

void onTick(CBlob@ this)
{
	if (getGameTime() > this.get_u16("Death Time Mod"))
	{
		this.Tag("DoExplode");
		this.server_Die();
		//print("Death??");
	}
}
