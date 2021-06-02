void onInit(CBlob@ this)
{
	this.Tag("ignore extractor");
	this.Tag("builder always hit");
	this.Tag("upf_base");
	
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getCurrentScript().tickFrequency = 600;
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	this.Tag("minimap_small");
	this.set_u8("minimap_index", 26);
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("ChickenMarch.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(0.3f);
	
	if (isServer())
	{
		server_CreateBlob("commanderchicken", -1, this.getPosition() + Vec2f(16 - XORRandom(32), 0));
	}
}

void onTick(CBlob@ this)
{
	SetMinimap(this);

	if (isServer())
	{
		if(getGameTime() % 30 == 0)
		{
			if (XORRandom(10) < 4)
			{
				CBlob@[] chickens;
				getBlobsByTag("combat chicken", @chickens);
				
				if (chickens.length < 8)
				{
					CBlob@ blob = server_CreateBlob((XORRandom(100) < 72 ? "scoutchicken" : "soldierchicken"), -1, this.getPosition() + Vec2f(16 - XORRandom(32), 0));
				}
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
		server_DropCoins(this.getPosition(), 100 + XORRandom(250));
	}
}