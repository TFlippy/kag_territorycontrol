#include "MakeSeed.as";
bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		if (this.hasTag("has grain"))
		{			
			CBlob@ grain = server_CreateBlob("grain", this.getTeamNum(), this.getPosition());
			if (grain !is null)
			{
				server_MakeSeed(this.getPosition(), "grain_plant", 300, 1, 4);
			}
		}
	}
}
