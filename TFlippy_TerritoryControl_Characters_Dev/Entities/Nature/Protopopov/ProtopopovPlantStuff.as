#include "MakeSeed.as";
#include "MakeMat.as";

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		if (this.hasTag("has bulb"))
		{
			CBlob@ bulb = server_CreateBlob("protopopovbulb", this.getTeamNum(), this.getPosition() + Vec2f(0, -12));
			if (bulb !is null)
			{
				bulb.setVelocity(Vec2f(XORRandom(5) - 2.5f, XORRandom(5) - 2.5f));
			}
				
			MakeMat(this, this.getPosition() + Vec2f(0, -3), "mat_protopopov", 10 + XORRandom(30));	
				
			for (int i = 0; i < 2 + XORRandom(4); i++)
			{
				CBlob@ seed = server_MakeSeed(this.getPosition() + Vec2f(0, -32), "protopopov_plant");
				if (seed !is null)
				{
					seed.setVelocity(Vec2f(XORRandom(12) - 6.0f, XORRandom(12) - 6.0f));
				}
			}
		}
	}
}

