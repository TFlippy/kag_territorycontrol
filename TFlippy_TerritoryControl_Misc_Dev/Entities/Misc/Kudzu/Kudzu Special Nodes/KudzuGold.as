#include "KudzuCommon.as"
#include "MakeMat.as";

void onInit(CBlob @ this)
{
	this.SetLight(true);
	this.SetLightRadius(30.0f);
	this.SetLightColor(SColor(255, 155, 255, 0));
}

void onDie(CBlob@ this)
{
	MakeMat(this, this.getPosition(), "mat_gold", 25 + XORRandom(75));	
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}