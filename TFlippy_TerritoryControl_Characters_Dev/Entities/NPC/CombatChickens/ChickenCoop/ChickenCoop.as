void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.Tag("builder always hit");
	this.Tag("upf_base");
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	this.getCurrentScript().tickFrequency = 1800;
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("ChickenMarch.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(0.3f);
	
	this.Tag("minimap_small");
	this.set_u8("minimap_index", 27);
	
	if (isServer())
	{	
		this.server_setTeamNum(250);
	
		for (int i = 0; i < (1 + XORRandom(2)); i++)
		{
			server_CreateBlob("commanderchicken", -1, this.getPosition() + Vec2f(64 - XORRandom(32), 0));
		}
		
		CBlob@[] blobs;
		getMap().getBlobsInRadius(this.getPosition(), 256.0f, @blobs);
		u8 myTeam = this.getTeamNum();
		
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			
			if (b.hasTag("door"))
			{
				b.server_setTeamNum(250);
			}
		}
	}
}

void onTick(CBlob@ this)
{
	SetMinimap(this);
	
	if (isServer())
	{
		if(getGameTime() % 10 == 0)
		{
			CBlob@[] chickens;
			getBlobsByTag("combat chicken", @chickens);
			
			if (chickens.length < 16)
			{
				CBlob@ blob = server_CreateBlob((XORRandom(100) < 20 ? "soldierchicken" : "scoutchicken"), -1, this.getPosition() + Vec2f(16 - XORRandom(32), 0));
			}
		}
	}
}

void SetMinimap(CBlob@ this)
{
	this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
		
	if (this.hasTag("minimap_large")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(16, 8));
	else if (this.hasTag("minimap_small")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(8, 8));

	this.SetMinimapRenderAlways(true);
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		server_DropCoins(this.getPosition(), 1000 + XORRandom(1500));
	}
}