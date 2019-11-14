
void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);

	// CSprite@ sprite = this.getSprite();
	// sprite.SetEmitSound("FireWave_EarRape.ogg");
	// sprite.SetEmitSoundPaused(false);
	// sprite.SetEmitSoundVolume(1.5f);
	
	this.set_s32("progress", 0);
	
	this.getCurrentScript().tickFrequency = 1;
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	bool server = isServer();
	bool client = isClient();
	
	Vec2f top = Vec2f(this.getPosition().x, 0);
	Vec2f bottom = Vec2f(this.getPosition().x, map.tilemapheight * 8);
	
	s32 progress = this.get_s32("progress");
	
	DoStuff(this, +progress, 1.00f);
	DoStuff(this, -progress, 1.00f);
	
	this.set_s32("progress", progress + 1);
	
	// Vec2f pos;
		
	// if (map.rayCastSolid(top, bottom, pos))
	// {
		// if (server)
		// {
			// Explode(this, 32.0f, 1.0f);
		
			// if (XORRandom(100) < 75)
			// {
				// CBlob@ flame = server_CreateBlob("flame", this.getTeamNum(), pos);
				// flame.server_SetTimeToDie(3 + XORRandom(10));
			// }
		// }
	// }
	
	// if (server)
	// {
		// if (top.x > (map.tilemapwidth * 8) - 8) this.server_Die();
	
		// CBlob@[] blobs;
		// if (map.getBlobsInBox(Vec2f(top.x - 64, top.y), Vec2f(pos.x, pos.y), blobs))
		// {
			// for (int i = 0; i < blobs.length; i++)
			// {
				// if (blobs[i] is null) continue;
				// CBlob@ blob = blobs[i];
				
				// this.server_Hit(blob, blob.getPosition(), Vec2f(), 80.00f, Hitters::fire, true);
			// }
		// }
	// }
	
	// for (int i = 0; i < pos.y; i += 8)
	// {
		// Vec2f p =  Vec2f(pos.x + 10 - XORRandom(20), i);
	
		// if (server && i % 16 == 0) 
		// {
			// if (map.isTileWood(map.getTile(p).type)) map.server_setFireWorldspace(p, true);
		// }
		// if (client) makeSteamParticle(this, p, Vec2f(), XORRandom(100) < 30 ? ("LargeSmoke" + (1 + XORRandom(2))) : "Explosion" + (1 + XORRandom(3)));
	// }
	
	// if (client) ShakeScreen(256, 64, pos);
	
	// this.setPosition(pos + Vec2f(6, 0));
}

void DoStuff(CBlob@ this, f32 offset, f32 power, f32 ratio = 0.10f)
{
	CMap@ map = getMap();

	Vec2f pos_origin = this.getPosition();
	Vec2f pos = pos_origin + Vec2f(offset * 8.00f, 0);
	
	s32 height = map.tilemapheight;
	
	s32 tile_count = height;
	for (int i = 0; i < tile_count; i++)
	{
		Vec2f tpos = Vec2f(pos.x, i * 8.00f);
		Tile tile = map.getTile(tpos);
	
		if (tile.type != CMap::tile_empty)
		{
			MakeParticle(this, tpos, 1.00f, 1.00f, 0);
			map.server_DestroyTile(tpos, 0.125f);
		}
	}
	
	
	
	// 
	
	
	
	// ParticlePixel(pos, Vec2f(0, 0), SColor(255, 0, 0, 0), false, 119);
}

void MakeParticle(CBlob@ this, const Vec2f pos, const f32 time, const f32 size, const f32 growth, const string filename = "AntimatterLightning.png")
{
	if (isClient())
	{
		CParticle@ p = ParticleAnimated(filename, pos, Vec2f(0, 0), XORRandom(360), size, RenderStyle::additive, 0, Vec2f(32, 32), 1, 0, true);
		if (p !is null)
		{
			p.Z = 200;
			p.animated = time;
			p.growth = growth;
			p.setRenderStyle(RenderStyle::additive);
		}
	}
}