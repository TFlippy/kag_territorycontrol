void onInit(CBlob@ this)
{
	if(this.get_string("reload_script") != "scubagear")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this) // the same as onInit, works one time when get equiped
{
	this.getCurrentScript().tickFrequency = 30;

    this.set_u8("breath timer", 1);
    this.set_bool("inhale", false);
}

void onTick(CBlob@ this)
{
    if(this.get_string("reload_script") == "scubagear")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}

	if(isClient() && this.get_u8("breath timer") == 2)
    {
        bool inhale = this.get_bool("inhale");
        this.getSprite().PlaySound("Sounds/gasp.ogg", 0.75f, inhale ? 0.8f : 0.75f);
        this.set_bool("inhale", !inhale);
    }

    this.set_u8("breath timer", (this.get_u8("breath timer") % 2) + 1);
}