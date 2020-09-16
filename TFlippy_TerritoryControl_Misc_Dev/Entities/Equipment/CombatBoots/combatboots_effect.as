#include "RunnerCommon.as"

void onInit(CBlob@ this)
{
	if(this.get_string("reload_script") != "combatboots")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this) // the same as onInit, works one time when get equiped
{
	
}

void onTick(CBlob@ this)
{
    if(this.get_string("reload_script") == "combatboots")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}
	
	RunnerMoveVars@ moveVars;
	if(this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 1.2f;
	}
	
	if(this.get_f32("cb_health") >= 10.0f)
    {
        this.getSprite().PlaySound("ricochet_" + XORRandom(3));
        this.set_string("equipment_boots", "");
        this.set_f32("cb_health", 0.0f);
        this.RemoveScript("combatboots_effect.as");
    }
}


