#include "FireCommon.as"
#include "KudzuCommon.as"

void onDie(CBlob@ this)
{
	server_CreateBlob("badger", 0, this.getPosition());
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}