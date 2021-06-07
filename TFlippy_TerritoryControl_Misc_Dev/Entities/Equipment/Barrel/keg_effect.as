void onInit(CBlob@ this)
{
	if(this.get_string("reload_script") != "keg")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this)
{
	CSpriteLayer@ barrel = this.getSprite().addSpriteLayer("keg", "KegTorso.png", 16, 16);

	if (barrel !is null)
	{
		barrel.SetVisible(true);
		barrel.SetRelativeZ(3);
		barrel.SetOffset(Vec2f(0, 2));
		
		if(this.getSprite().isFacingLeft())
			barrel.SetFacingLeft(true);
	}
}

void onTick(CBlob@ this)
{
    if(this.get_string("reload_script") == "keg")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}
}