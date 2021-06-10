#include "RunnerCommon.as"

void onTick(CBlob@ this)
{
    if(this.get_string("reload_script") == "combatboots")
        this.set_string("reload_script", "");
    
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

void onDie(CBlob@ this)
{
    if (isServer())
    {
        CBlob@ item = server_CreateBlob("combatboots", this.getTeamNum(), this.getPosition());
        if (item !is null) item.set_f32("health", this.get_f32("cb_health"));
    }
    this.RemoveScript("combatboots_effect.as");//
}