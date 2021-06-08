void onInit(CBlob@ this)
{
	if (this.get_string("reload_script") != "backpack")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this)
{
	CSpriteLayer@ backpack = this.getSprite().addSpriteLayer("backpack", "Backpack.png", 16, 16);

	if (backpack !is null)
	{
		backpack.SetVisible(true);
		backpack.SetRelativeZ(-2);
		backpack.SetOffset(Vec2f(4, -2));
		
		if (this.getSprite().isFacingLeft())
			backpack.SetFacingLeft(true);
	}
	
	CBlob@ backpackblob = server_CreateBlobNoInit("backpackblob");
	if (backpackblob !is null)
	{
		backpackblob.setPosition(this.getPosition());
		backpackblob.server_setTeamNum(-1);
		backpackblob.set_u16("holder_id", this.getNetworkID());
		backpackblob.Init();
		
		this.set_u16("backpack_id", backpackblob.getNetworkID());
	}
}

void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "backpack")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}
}

void onDie(CBlob@ this)
{
    if (isServer())
	{
		CBlob@ backpack = getBlobByNetworkID(this.get_u16("backpack_id"));
		backpack.server_Die();
	}
}