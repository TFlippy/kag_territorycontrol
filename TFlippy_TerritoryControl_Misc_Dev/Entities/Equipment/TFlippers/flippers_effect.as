#include "RunnerCommon.as"

void onInit(CBlob@ this)
{
	if (this.get_string("reload_script") != "flippers")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this) // the same as onInit, works one time when get equiped
{
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.swimspeed += 10.0f;
	}
}

void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "flippers")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}
	
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 0.7f;
		moveVars.jumpFactor *= 0.7f;
	}	
}