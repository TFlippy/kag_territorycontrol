void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "pumpkin")
        this.set_string("reload_script", "");
   
    if (this.get_f32("pumpkin_health") >= 5.0f)
    {
        this.getSprite().PlaySound("wetfall1.ogg");
        this.set_string("equipment_head", "");
        this.set_f32("pumpkin_health", 4.9f);
        this.RemoveScript("pumpkin_effect.as");
    }
    
	// print("helmet: "+this.get_f32("mh_health"));
}