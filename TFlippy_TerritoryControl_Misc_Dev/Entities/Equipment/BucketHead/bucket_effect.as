void onInit(CBlob@ this)
{
    if(this.get_string("reload_script") != "bucket")
        UpdateScript(this);
}

void UpdateScript(CBlob@ this)
{
    
}
 
void onTick(CBlob@ this)
{
    if(this.get_string("reload_script") == "bucket")
    {
        UpdateScript(this);
        this.set_string("reload_script", "");
    }
   
    if(this.get_f32("bucket_health") >= 5.0f)
    {
        this.getSprite().PlaySound("woodheavyhit1");
        this.set_string("equipment_head", "");
        this.set_f32("bucket_health", 0.0f);
        this.RemoveScript("bucket_effect.as");
    }
    
	// print("helmet: "+this.get_f32("mh_health"));
}
 
void onDie(CBlob@ this)
{
    if (isServer())
    {
        CBlob@ item = server_CreateBlob("bucket", this.getTeamNum(), this.getPosition());
        if(item !is null) item.set_f32("health", this.get_f32("bucket_health"));
    }
    this.RemoveScript("bucket_effect.as");
}