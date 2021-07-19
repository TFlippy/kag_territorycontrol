void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "bucket")
    	this.set_string("reload_script", "");
   
    if (this.get_f32("bucket_health") >= 10.0f)
    {
        this.getSprite().PlaySound("woodheavyhit1");
        this.set_string("equipment_head", "");
        this.set_f32("bucket_health", 9.9f);
        this.RemoveScript("bucket_effect.as");
    }
    
	// print("helmet: "+this.get_f32("mh_health"));
}