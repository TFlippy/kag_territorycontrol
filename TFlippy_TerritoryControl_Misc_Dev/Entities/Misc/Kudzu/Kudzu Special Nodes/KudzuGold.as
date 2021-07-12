#include "KudzuCommon.as"
#include "MakeMat.as";

void onDie(CBlob@ this)
{
	MakeMat(this, this.getPosition(), "mat_gold", 25 + XORRandom(25));	
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}