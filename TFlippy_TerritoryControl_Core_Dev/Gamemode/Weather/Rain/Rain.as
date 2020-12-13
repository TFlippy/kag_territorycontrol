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

	getMap().CreateSkyGradient("skygradient_rain.png");

	if (isServer())
	{
		this.server_SetTimeToDie(150 + XORRandom(300));
	}
	
	if (isClient())
	{
		Render::addBlobScript(Render::layer_postworld, this, "Rain.as", "RenderRain");
		if(!Texture::exists("RAIN"))
			Texture::createFromFile("RAIN", "rain.png");
		if(!Texture::exists("FOG"))
			Texture::createFromFile("FOG", "pixel.png");

		client_AddToChat("A rainstorm has formed! Heavy wind will now blow away aerial vehicles and promote plant growth.", SColor(255, 255, 0, 0));

		CSprite@ sprite = this.getSprite();
		sprite.getConsts().accurateLighting = false;
		sprite.SetEmitSound("rain_loop.ogg");
		sprite.SetEmitSoundPaused(false);
		CMap@ map = getMap();
		uvs = 2048.0f/f32(spritesize);
		
		Vertex[] BigQuad = 
		{
			Vertex(-1024,	-1024, 	-800,	0,		0,		0x90ffffff),
			Vertex(1024,	-1024,	-800,	uvs,	0,		0x90ffffff),
			Vertex(1024,	1024,	-800,	uvs,	uvs,	0x90ffffff),
			Vertex(-1024,	1024,	-800,	0,		uvs,	0x90ffffff)
		};
		
		Rain_vs = BigQuad;
		BigQuad[0].z = BigQuad[1].z = BigQuad[2].z = BigQuad[3].z = 1500;
		Fog_vs = BigQuad;
	}
	
	getRules().set_bool("raining", true);
}

const int spritesize = 512;
f32 uvs;
Vertex[] Rain_vs;
Vertex[] Fog_vs;

f32 sine;

f32 windTarget = 0;	
f32 wind = 0;	
u32 nextWindShift = 0;

f32 fog = 0;
f32 fogTarget = 0;

f32 modifier = 1;
f32 modifierTarget = 1;

f32 fogHeightModifier = 0;
f32 fogDarkness = 0;

Vec2f rainpos = Vec2f(0,0);
f32 uvMove = 0;
f32 last_uvMove = 0;
f32 lastFrameTime = 0;

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	if (getGameTime() >= nextWindShift)
	{
		windTarget = XORRandom(1000) - 500;
		nextWindShift = getGameTime() + 30 + XORRandom(300);
		
		fogTarget = 50 + XORRandom(150);
	}
	
	wind = Maths::Lerp(wind, windTarget, 0.02f);
	fog = Maths::Lerp(fog, fogTarget, 0.01f);
		
	sine = (Maths::Sin((getGameTime() * 0.0125f)) * 8.0f);
	Vec2f sineDir = Vec2f(0, 1).RotateBy(sine * 20);
	
	CBlob@[] vehicles;
	getBlobsByTag("aerial", @vehicles);
	for (u32 i = 0; i < vehicles.length; i++)
	{
		CBlob@ blob = vehicles[i];
		if (blob !is null)
		{
			Vec2f pos = blob.getPosition();
			if (map.rayCastSolidNoBlobs(Vec2f(pos.x, 0), pos)) continue;
		
			blob.AddForce(sineDir * blob.getRadius() * wind * 0.01f);
		}
	}

	if (isClient())
	{	
		lastFrameTime = 0;
		CCamera@ cam = getCamera();
		fogHeightModifier = 0.00f;
		
		if (cam !is null && uvs > 0)
		{
			Vec2f cam_pos = cam.getPosition();
			rainpos = Vec2f(int(cam_pos.x / spritesize) * spritesize + (spritesize/2), int(cam_pos.y / spritesize) * spritesize + (spritesize/2));
			this.setPosition(cam_pos);

			uvMove -= 0.05f;
			if (XORRandom(500) == 0)
			{
				Sound::Play("thunder_distant" + XORRandom(4));
				SetScreenFlash(XORRandom(100), 255, 255, 255);
			}
			
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
			
			modifier = Maths::Lerp(modifier, modifierTarget, 0.10f);
			fogHeightModifier = 1.00f - ((cam_pos.y*2) / (map.tilemapheight * map.tilesize));
			
			//if (getGameTime() % 5 == 0) ShakeScreen(Maths::Abs(wind) * 0.03f * modifier, 90, cam_pos);
			
			this.getSprite().SetEmitSoundSpeed(0.5f + modifier * 0.5f);
			this.getSprite().SetEmitSoundVolume(0.30f + 0.10f * modifier);
		}
		
		
		
		fogDarkness = Maths::Clamp(50 + (fog * 0.10f), 0, 150);
		//if (modifier > 0.01f) SetScreenFlash(Maths::Clamp(Maths::Max(fog, 255 * fogHeightModifier * 1.20f) * modifier, 0, 190), fogDarkness, fogDarkness, fogDarkness);
		
		// print("" + modifier);
		
		// print("" + (fog * modifier));
		
		//this.getShape().SetAngleDegrees(10 + sine);
	}
	
	if (isServer())
	{
		CMap@ map = getMap();
		u32 rand = XORRandom(1000);
		
		if (rand == 0)
		{
			f32 x = XORRandom(map.tilemapwidth);
			Vec2f pos = Vec2f(x, map.getLandYAtX(x)) * 8;
			
			CBlob@ blob = server_CreateBlob("lightningbolt", -1, pos);
		}	
		
		if (XORRandom(25) == 0)
		{
			CBlob@[] blobs;
			getBlobsByTag("gas", @blobs);
			
			if (blobs.length > 0)
			{
				CBlob@ b = blobs[XORRandom(blobs.length - 1)];
				if (b !is null)
				{
					Vec2f pos = b.getPosition();
					if (!map.rayCastSolidNoBlobs(Vec2f(pos.x, 0), pos))
					{
						b.server_Die();
					}
				}
			}
		}
		
		if (getGameTime() % 10 == 0) DecayStuff();
	}
}

void RenderRain(CBlob@ this, int id)
{
	Render::SetTransformWorldspace();
	Render::SetAlphaBlend(true);
	
	lastFrameTime += getRenderDeltaTime() * getTicksASecond();  // We are using this because ApproximateCorrectionFactor is lerped

	last_uvMove = Maths::Lerp(last_uvMove, uvMove, lastFrameTime);

	Rain_vs[0].v = Rain_vs[1].v = last_uvMove;
	Rain_vs[2].v = Rain_vs[3].v = last_uvMove + uvs;
	float[] model;
	Matrix::MakeIdentity(model);
	Matrix::SetRotationDegrees(model,
		0,
		0,
		10.0f + sine
	);
	Matrix::SetTranslation(model,
		rainpos.x,
		rainpos.y,
		0
	);
	Render::SetModelTransform(model);
	Render::RawQuads("RAIN", Rain_vs);
	f32 alpha = Maths::Clamp(Maths::Max(fog, 255 * fogHeightModifier * 1.20f) * modifier, 0, 190);
	Fog_vs[0].col = Fog_vs[1].col = Fog_vs[2].col = Fog_vs[3].col = SColor(alpha,fogDarkness,fogDarkness,fogDarkness);
	Render::RawQuads("FOG", Fog_vs);
}


void onCommand(CBlob@ this,u8 cmd,CBitStream @params)
{
	if(cmd==this.getCommandID("removeAwootism")) 
	{
		u16 blob1,player1;

		if(!params.saferead_u16(blob1)) {
			return;
		}
		if(!params.saferead_u16(player1)) {
			return;
		}

		CBlob@ ourBlob = getBlobByNetworkID(blob1);
		CPlayer@ player = getPlayerByNetworkId(player1);

		player.Untag("awootism");
		player.Sync("awootism",false);
		ourBlob.Tag("infectOver");
		ourBlob.Sync("infectOver",false);
	}
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

const string[] seeds =
{
	"tree_pine",
	"tree_bushy",
	"bush",
	"grain_plant",
	"flowers"
};

void DecayStuff()
{
	CMap@ map = getMap();
	
	{
		Vec2f pos = Vec2f(XORRandom(map.tilemapwidth * map.tilesize), 0);
		Vec2f hit;
		
		if (map.rayCastSolidNoBlobs(pos, Vec2f(pos.x, map.tilemapheight * map.tilesize), hit))
		{
			TileType tile = map.getTile(hit).type;

			switch(tile)
			{
				case CMap::tile_castle:
					map.server_SetTile(hit, CMap::tile_castle_moss);
				break;

				case CMap::tile_castle_back:
					map.server_SetTile(hit, CMap::tile_castle_back_moss);
				break;

				default:
				{
					if (isTileConcrete(tile))
					{
						map.server_SetTile(hit, CMap::tile_mossyconcrete + XORRandom(2));
					}
					else if (isTileBConcrete(tile))
					{
						map.server_SetTile(hit, CMap::tile_mossybconcrete + XORRandom(2));
					}
					else if (isTileIron(tile))
					{
						map.server_SetTile(hit, CMap::tile_rustyiron + XORRandom(2));
					}
				}
				break;
			}	

			for (int j = 0; j < 4 + XORRandom(4); j++)
			{
				pos = Vec2f(XORRandom(map.tilemapwidth * map.tilesize), 0);
				
				if (map.rayCastSolidNoBlobs(pos, Vec2f(pos.x, map.tilemapheight * map.tilesize), hit))
				{
					TileType tile = map.getTile(hit).type;
					switch(tile)
					{
						case CMap::tile_castle_back:
						{
							if (XORRandom(5) == 0) map.server_SetTile(hit, CMap::tile_castle_back_moss); 
							else
							{
								map.server_SetTile(hit, 76 + XORRandom(2)); 
							}
						}
						break;

						case CMap::tile_castle:
						{
							if (XORRandom(5) == 0) map.server_SetTile(hit, CMap::tile_castle_moss);
							else
							{
								map.server_SetTile(hit, 58 + XORRandom(6)); 
							}
						}
						break;

						case CMap::tile_castle_back_moss:
						{
							if (XORRandom(8) == 0)
							{
								if (map.isTileSolid(map.getTile(hit + Vec2f(0, 8)).type))
								{
									if (getTaggedBlobsInRadius(map, hit, 24, "nature") < 3) 
									{
										server_MakeSeed(hit, seeds[XORRandom(seeds.length)]);
									}
								}
								else if (map.isTileSolid(map.getTile(hit + Vec2f(0, -8)).type))
								{
									if (getTaggedBlobsInRadius(map, hit, 12, "nature") == 0) 
									{
										server_CreateBlob("ivy", -1, hit + Vec2f(0, 16));
									}
								}
								else
								{
									if (getTaggedBlobsInRadius(map, hit, 24, "nature") == 0) 
									{
										server_CreateBlob("bush", -1, hit);
										
										for (int k = 0; k < XORRandom(8); k++)
										{
											map.server_DestroyTile(Vec2f(hit.x + (XORRandom(4) - 2) * 8, hit.y + (XORRandom(4) - 2) * 8), 0.5f);
										}
									}
								}
							}
						}
						break;

						case CMap::tile_wood_back:
						{
							if (XORRandom(8) == 0)
							{
								if (map.isTileSolid(map.getTile(hit + Vec2f(0, 8)).type))
								{ 
									if (getTaggedBlobsInRadius(map, hit, 24, "nature") < 4) 
									{
										server_CreateBlob("bush", -1, hit);
										
										for (int k = 0; k < XORRandom(8); k++)
										{
											map.server_DestroyTile(Vec2f(hit.x + (XORRandom(4) - 2) * 8, hit.y + (XORRandom(4) - 2) * 8), 0.5f);
										}
									}
								}
								else if (map.isTileSolid(map.getTile(hit + Vec2f(0, -8)).type))
								{
									if (getTaggedBlobsInRadius(map, hit, 12, "nature") == 0) 
									{
										server_CreateBlob("ivy", -1, hit + Vec2f(0, 16));
										
										for (int k = 0; k < XORRandom(8); k++)
										{
											map.server_DestroyTile(Vec2f(hit.x + (XORRandom(4) - 2) * 8, hit.y + (XORRandom(4) - 2) * 8), 0.5f);
										}
									}
								}
								else
								{
									if (getTaggedBlobsInRadius(map, hit, 24, "nature") == 0) 
									{
										server_CreateBlob("bush", -1, hit);
										
										for (int k = 0; k < XORRandom(8); k++)
										{
											map.server_DestroyTile(Vec2f(hit.x + (XORRandom(4) - 2) * 8, hit.y + (XORRandom(4) - 2) * 8), 0.5f);
										}
									}
								}
							}
						}
						break;

						case CMap::tile_wood:
						{
							for (int j = 0; j < XORRandom(8); j++)
							{
								map.server_DestroyTile(Vec2f(hit.x + (XORRandom(4) - 2) * 8, hit.y + (XORRandom(4) - 2) * 8), 0.5f);
							}
						}
						break;


						default:
						{
							if (isTileConcrete(tile))
							{
								if (XORRandom(5) == 0) map.server_SetTile(hit, CMap::tile_concrete_d0 + XORRandom(3));
								else
								{
									map.server_SetTile(hit, CMap::tile_mossyconcrete + XORRandom(2)); 
								}
							}
							else if (isTileBConcrete(tile))
							{
								if (XORRandom(5) == 0) map.server_SetTile(hit,CMap::tile_bconcrete_d0 + XORRandom(3));
								else
								{
									map.server_SetTile(hit, CMap::tile_mossybconcrete + XORRandom(2)); 
								}
							}
							else if(isTileMossyBConcrete(tile))
							{
								if (XORRandom(8) == 0)
								{
									if (map.isTileSolid(map.getTile(hit + Vec2f(0, 8)).type))
									{
										if (getTaggedBlobsInRadius(map, hit, 24, "nature") < 3) 
										{
											server_MakeSeed(hit, seeds[XORRandom(seeds.length)]);
										}
									}
									else if (map.isTileSolid(map.getTile(hit + Vec2f(0, -8)).type))
									{
										if (getTaggedBlobsInRadius(map, hit, 12, "nature") == 0) 
										{
											server_CreateBlob("ivy", -1, hit + Vec2f(0, 16));
										}
									}
									else
									{
										if (getTaggedBlobsInRadius(map, hit, 24, "nature") == 0) 
										{
											server_CreateBlob("bush", -1, hit);
											
											for (int k = 0; k < XORRandom(8); k++)
											{
												map.server_DestroyTile(Vec2f(hit.x + (XORRandom(4) - 2) * 8, hit.y + (XORRandom(4) - 2) * 8), 0.5f);
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	CBlob@[] plants;
	getBlobsByTag("nature", @plants);
	
	if (plants !is null && plants.length > 0)
	{
		// u32 count = Maths::Ceil(plants.length * 0.5f); // lolz
		u32 count = Maths::Ceil(plants.length * 0.035f); // lolz
		//if (getGameTime() % 150 == 0) print("rain iteration count: " + count + "/" + plants.length);
				
		for (int i = 0; i < count; i++)
		{
			CBlob@ plant = plants[XORRandom(plants.length)];
			
			Vec2f pos = plant.getPosition();
			Vec2f tilePos = Vec2f(pos.x, pos.y + 8);
			uint16 tile = map.getTile(tilePos).type;
						
			Vec2f grassPos = Vec2f(tilePos.x + ((5 - XORRandom(10)) * 8), tilePos.y + ((4 - XORRandom(8)) * 8));
			TileType grassTileType = map.getTile(grassPos).type;

			Vec2f underGrassPos = Vec2f(grassPos.x, grassPos.y + 8);
			TileType underGrassTileType = map.getTile(underGrassPos).type;
			
			if (map.isTileSolid(underGrassTileType) && (map.isTileGround(underGrassTileType) || underGrassTileType == CMap::tile_castle_moss || isTileMossyConcrete(underGrassTileType)))
			{
				if (grassTileType == CMap::tile_empty)
				{
					map.server_SetTile(grassPos, CMap::tile_grass + XORRandom(3));
				}
				else if (map.isTileGrass(grassTileType))
				{
					CBlob@[] blobs;
					map.getBlobsInRadius(grassPos, 12, @blobs);
				
					if (blobs.length < 3) 
					{
						server_MakeSeed(grassPos, seeds[XORRandom(seeds.length)]);
					}
				}
			}
		}
	}
}

u32 getTaggedBlobsInRadius(CMap@ map, const Vec2f pos, const f32 radius, const string tag)
{
	CBlob@[] blobs;
	map.getBlobsInRadius(pos, radius, @blobs);

	u32 counter = 0;
	
	for (int i = 0; i < blobs.length; i++)
	{
		if (blobs[i].hasTag(tag)) counter++;
	}

	return counter;
}
