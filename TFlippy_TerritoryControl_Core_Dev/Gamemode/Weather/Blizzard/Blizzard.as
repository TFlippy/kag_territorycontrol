#include "Hitters.as";
#include "Explosion.as";
#include "MakeDustParticle.as";
#include "FireParticle.as";
#include "canGrow.as";
#include "MakeSeed.as";
#include "CustomBlocks.as";

void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	this.getCurrentScript().tickFrequency = 1;
	
	this.getShape().SetRotationsAllowed(true);

	getMap().CreateSkyGradient("skygradient_blizzard.png");

	if (isServer())
	{
		this.server_SetTimeToDie(300);
	}

	if (isClient())
	{
		Render::addBlobScript(Render::layer_postworld, this, "Blizzard.as", "RenderBlizzard");
		if(!Texture::exists("BLIZZARD")) Texture::createFromFile("BLIZZARD", "blizzard.png");
		if(!Texture::exists("FOG")) Texture::createFromFile("FOG", "pixel.png");
	}
	
	getRules().set_bool("raining", true);
	client_AddToChat("A blizzard has formed! Heavy wind will now blow away aerial vehicles and promote snow growth.", SColor(255, 255, 0, 0));
}

const int spritesize = 128;
f32 uvs;
Vertex[] Blizzard_vs;
Vertex[] Fog_vs;

void onInit(CSprite@ this)
{
	this.getConsts().accurateLighting = false;
	Setup(this);
}

void onReload(CBlob@ this)
{
	Setup(this.getSprite());
}

void Setup(CSprite@ this)
{
	if (isClient())
	{
		this.SetEmitSound("Blizzard_Loop.ogg");
		this.SetEmitSoundPaused(false);
		CMap@ map = getMap();
		uvs = 2048.0f/f32(spritesize);
		
		Vertex[] BigQuad = 
		{
			Vertex(-1024,	-1024, 	-800,	0,		0,		0x90ffffff),
			Vertex(1024,	-1024,	-800,	uvs,	0,		0x90ffffff),
			Vertex(1024,	1024,	-800,	uvs,	uvs,	0x90ffffff),
			Vertex(-1024,	1024,	-800,	0,		uvs,	0x90ffffff)
		};
		
		Blizzard_vs = BigQuad;
		BigQuad[0].z = BigQuad[1].z = BigQuad[2].z = BigQuad[3].z = 1500;
		Fog_vs = BigQuad;
	}
}

f32 windTarget = 0;	
f32 wind = 0;	
u32 nextWindShift = 0;

f32 fog = 0;
f32 fogTarget = 0;

f32 modifier = 1;
f32 modifierTarget = 1;

f32 fogHeightModifier = 0;
f32 fogDarkness = 0;

Vec2f blizzardpos = Vec2f(0,0);
f32 uvMove = 0;

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	if (getGameTime() >= nextWindShift)
	{
		windTarget = 50 + XORRandom(200);
		nextWindShift = getGameTime() + 30 + XORRandom(300);
		
		fogTarget = 50 + XORRandom(150);
	}
	
	wind = Lerp(wind, windTarget, 0.02f);
	fog = Lerp(fog, fogTarget, 0.01f);
		
	Vec2f dir = Vec2f(0, 1).RotateBy(70);
	
	CBlob@[] vehicles;
	getBlobsByTag("aerial", @vehicles);
	for (u32 i = 0; i < vehicles.length; i++)
	{
		CBlob@ blob = vehicles[i];
		if (blob !is null)
		{
			Vec2f pos = blob.getPosition();
			if (map.rayCastSolidNoBlobs(Vec2f(pos.x, 0), pos)) continue;
		
			blob.AddForce(dir * blob.getRadius() * wind * 0.01f);
		}
	}

	if (isClient())
	{	
		CCamera@ cam = getCamera();
		fogHeightModifier = 0.00f;
		
		if (cam !is null && uvs > 0)
		{
			Vec2f cam_pos = cam.getPosition();
			blizzardpos = Vec2f(int(cam_pos.x / spritesize) * spritesize + (spritesize/2), int(cam_pos.y / spritesize) * spritesize + (spritesize/2));
			this.setPosition(cam_pos);
			uvMove = (uvMove - 0.09f) % uvs;
			
			// if (XORRandom(500) == 0)
			// {
				// Sound::Play("thunder_distant" + XORRandom(4));
				// SetScreenFlash(XORRandom(100), 255, 255, 255);
			// }
			
			Vec2f hit;
			if (getMap().rayCastSolidNoBlobs(Vec2f(cam_pos.x, 0), cam_pos, hit))
			{
				f32 depth = Maths::Abs(cam_pos.y - hit.y) / 8.0f;
				modifierTarget = 1.0f - Maths::Clamp(depth / 8.0f, 0.00f, 1);
			}
			else
			{
				modifierTarget = 1;
			}
			
			modifier = Lerp(modifier, modifierTarget, 0.10f);
			fogHeightModifier = 1.00f - (cam_pos.y / (map.tilemapheight * map.tilesize));
			
			if (getGameTime() % 5 == 0) ShakeScreen(Maths::Abs(wind) * 0.03f * modifier, 90, cam_pos);
			
			this.getSprite().SetEmitSoundSpeed(0.5f + modifier * 0.5f);
			this.getSprite().SetEmitSoundVolume(0.30f + 0.10f * modifier);
		}
		
		fogDarkness = Maths::Clamp(130 + (fog * 0.10f), 0, 255);
	}
	
	Snow(this);
}

const int max_snow_difference = 4;

void Snow(CBlob@ this)
{
	if (isServer())
	{
		CMap@ map = getMap();
		Vec2f dir = Vec2f(0, 1); //.RotateBy(10);
		
		for (int i = 0; i < 5; i++)
		{
			Vec2f start_pos = Vec2f(XORRandom(map.tilemapwidth) * 8, XORRandom(map.tilemapheight * 0.75f) * 8);
			Vec2f end_pos = start_pos + (dir * 10000);
			Vec2f hit_pos;
			
			if (map.rayCastSolidNoBlobs(start_pos, end_pos, hit_pos))
			{
				Vec2f pos_c = hit_pos + Vec2f(+0.00f, -8.00f);
				if (!map.isInWater(pos_c))
				{
					Vec2f pos_l = pos_c + Vec2f(-8.00f, 0.00f);
					Vec2f pos_r = pos_c + Vec2f(+8.00f, 0.00f);
					
					const Tile tile_c = map.getTile(pos_c);
					const Tile tile_l = map.getTile(pos_l);
					const Tile tile_r = map.getTile(pos_r);
					
					const TileType tileType_c = tile_c.type;
					const TileType tileType_l = tile_l.type;
					const TileType tileType_r = tile_r.type;
					
					if (tileType_c == CMap::tile_empty || map.isTileGrass(tileType_c))
					{
						map.server_SetTile(pos_c, CMap::tile_snow_pile_v5);
					}
					else 
					{
						const bool valid_l = (isTileSnowPile(tileType_l) && Maths::Abs(tileType_l - tileType_c + 1) < max_snow_difference) || (tile_l.flags & Tile::SOLID != 0);
						const bool valid_r = (isTileSnowPile(tileType_r) && Maths::Abs(tileType_r - tileType_c + 1) < max_snow_difference) || (tile_r.flags & Tile::SOLID != 0);
					
						if (isTileSnowPile(tileType_c - 1) && (valid_l && valid_r))
						{
							map.server_SetTile(pos_c, tileType_c - 1);
						}
						else if (tileType_c == CMap::tile_snow_pile) 
						{
							map.server_SetTile(pos_c, CMap::tile_snow);
						}
					}
				}
				
				// if (tile_c == CMap::tile_empty || map.isTileGrass(tile_c)) map.server_SetTile(pos_c, CMap::tile_snow_pile_v5);
				// else if (isTileSnowPile(tile_c - 1)) map.server_SetTile(pos_c, tile_c - 1);
				// else if (tile_c == CMap::tile_snow_pile) map.server_SetTile(pos_c, CMap::tile_snow);
			}
		}
	}
}

void RenderBlizzard(CBlob@ this, int id)
{
	if (Blizzard_vs.size() > 0)
	{
		Render::SetTransformWorldspace();
		Render::SetAlphaBlend(true);
		Blizzard_vs[0].v = Blizzard_vs[1].v = uvMove;
		Blizzard_vs[2].v = Blizzard_vs[3].v = uvMove + uvs;
		float[] model;
		Matrix::MakeIdentity(model);
		Matrix::SetRotationDegrees(model, 0.00f, 0.00f, 70.0f);
		Matrix::SetTranslation(model, blizzardpos.x, blizzardpos.y, 0.00f);
		Render::SetModelTransform(model);
		Render::RawQuads("BLIZZARD", Blizzard_vs);
		f32 alpha = Maths::Clamp(Maths::Max(fog, 255 * fogHeightModifier * 1.20f) * modifier, 0, 190);
		Fog_vs[0].col = Fog_vs[1].col = Fog_vs[2].col = Fog_vs[3].col = SColor(alpha, fogDarkness, fogDarkness, fogDarkness);
		Render::RawQuads("FOG", Fog_vs);
	}
}

f32 Lerp(f32 v0, f32 v1, f32 t) 
{
	return v0 + t * (v1 - v0);
}

void onDie(CBlob@ this)
{
	getRules().set_bool("raining", false);
	CBlob@ jungle = getBlobByName('info_jungle');

	if (jungle !is null)
	{
		getMap().CreateSkyGradient("skygradient_jungle.png");
	}
	else 
	{
		getMap().CreateSkyGradient("skygradient.png");
	}
}