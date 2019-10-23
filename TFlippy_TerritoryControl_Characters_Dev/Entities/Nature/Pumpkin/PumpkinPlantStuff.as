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
			CBlob@ pumpkin = server_CreateBlob("pumpkin", this.getTeamNum(), this.getPosition() + Vec2f(0, -12));
			if (pumpkin !is null)
			{
				pumpkin.setVelocity(Vec2f(XORRandom(5) - 2.5f, XORRandom(5) - 2.5f));
			}
				
			for (int i = 0; i < 1 + XORRandom(2); i++)
			{
				CBlob@ seed = server_MakeSeed(this.getPosition(), "pumpkin_plant");
				if (seed !is null)
				{
					seed.setVelocity(Vec2f(XORRandom(6) - 3.0f, XORRandom(6) - 3.0f));
				}
			}
		}
	}
}

