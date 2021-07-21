#include "FireCommon.as"
#include "KudzuCommon.as"

void onDie(CBlob@ this)
{
	if (this.hasTag("Mut_Explosive") && XORRandom(3) == 1)
	{
		server_CreateBlob("badgerbomb", 0, this.getPosition());
	}
	else
	{
		server_CreateBlob("badger", 0, this.getPosition());
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}