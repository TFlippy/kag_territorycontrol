#include "MakeSeed.as";

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		if (this.hasTag("has pumpkin"))
		{
			CBlob@ pumpkin = server_CreateBlob("pumpkin", this.getTeamNum(), this.getPosition());
			if (pumpkin !is null)
			{
				server_MakeSeed(this.getPosition(), "pumpkin_plant");
			}
		}
	}
}

