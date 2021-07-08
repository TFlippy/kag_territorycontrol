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
		if (this.hasTag("has leaves"))
		{
			CBlob@ leaves = server_CreateBlob("tealeaf", this.getTeamNum(), this.getPosition() + Vec2f(0, -12));
			if (leaves !is null)
			{
				leaves.setVelocity(Vec2f(XORRandom(3) - 2.5f, XORRandom(3) - 2.5f));
			}
				
			for (int i = 0; i < 1 + XORRandom(1); i++)
			{
				CBlob@ seed = server_MakeSeed(this.getPosition(), "tea_plant");
				if (seed !is null)
				{
					MakeMat(this, this.getPosition() + Vec2f(0, -3), "mat_tealeaf", Maths::Ceil(XORRandom(6)));
					seed.setVelocity(Vec2f(XORRandom(6) - 3.0f, XORRandom(6) - 3.0f));
					seed.Tag("gas immune");
				}
			}
		}
	}
}
