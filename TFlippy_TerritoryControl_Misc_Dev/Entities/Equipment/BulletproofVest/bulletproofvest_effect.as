void onInit(CBlob@ this)
{
	if(this.get_string("reload_script") != "bulletproofvest")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this)
{
	
}

void onTick(CBlob@ this)
{
    if(this.get_string("reload_script") == "bulletproofvest")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}
	
	//print("hp: "+this.get_f32("bpv_health"));
	
	if(this.get_f32("bpv_health") >= 25.0f)
	{
		// this.getSprite().PlaySound("ricochet_" + XORRandom(3));
		this.set_string("equipment_torso", "");
		this.set_f32("bpv_health", 0.0f);
		this.RemoveScript("bulletproofvest_effect.as");
	}
	// print("torso: "+this.get_f32("bpv_health"));
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ item = server_CreateBlob("bulletproofvest", this.getTeamNum(), this.getPosition());
		if(item !is null) item.set_f32("health", this.get_f32("bpv_health"));
	}
	this.RemoveScript("bulletproofvest_effect.as");
}
//all stuff for damage located in FleshHit.as