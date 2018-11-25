#include "Hitters.as";
#include "Explosion.as";
#include "MakeDustParticle.as";
#include "FireParticle.as";
#include "canGrow.as";
#include "MakeSeed.as";

// const Vec2f arm_offset = Vec2f(-2, -4);

// const u8 explosions_max = 25;

// f32 sound_delay;

void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	this.getCurrentScript().tickFrequency = 1;
	
	this.getShape().SetRotationsAllowed(true);
	
	getMap().CreateSkyGradient("skygradient_rain.png");
	
	if (getNet().isServer())
	{
		this.server_SetTimeToDie(300);
	}
	
	getRules().set_bool("raining", true);
	client_AddToChat("A rainstorm has formed! Heavy wind will now blow away aerial vehicles and promote plant growth.", SColor(255, 255, 0, 0));
}

const int spritesize = 128;

void onInit(CSprite@ this)
{
	this.getConsts().accurateLighting = false;
	
	if (getNet().isClient())
	{
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		// int[] frames = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
		// int[] frames = {15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0};

		Vec2f size = Vec2f(10, 7);
		
		for (int y = 0; y < size.y; y++)
		{
			for (int x = 0; x < size.x; x++)
			{
				CSpriteLayer@ l = this.addSpriteLayer("l_x" + x + "y" + y, "rain.png", spritesize, spritesize, this.getBlob().getTeamNum(), 0);
				l.SetOffset(Vec2f(x * spritesize, y * spritesize) - (Vec2f(size.x * spritesize, size.y * spritesize) / 2));
				l.SetLighting(false);
				l.SetRelativeZ(-600);
				l.setRenderStyle(RenderStyle::shadow);
				
				Animation@ anim = l.addAnimation("default", 1, true);
				anim.AddFrames(frames);
			}
		}
		
		this.SetEmitSound("rain_loop.ogg");
		this.SetEmitSoundPaused(false);
	}
}

// f32 Lerp(f32 a, f32 b, f32 time)
// {
	// return a + (b-a) * Maths::Min(1.0,Maths::Max(0.0,time));
// }

f32 windTarget = 0;	
f32 wind = 0;	
u32 nextWindShift = 0;

f32 fog = 0;
f32 fogTarget = 0;

f32 modifier = 1;
f32 modifierTarget = 1;

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	
	if (getGameTime() >= nextWindShift)
	{
		windTarget = XORRandom(1000) - 500;
		nextWindShift = getGameTime() + 30 + XORRandom(300);
		
		fogTarget = 50 + XORRandom(150);
	}
	
	wind = Lerp(wind, windTarget, 0.02f);
	fog = Lerp(fog, fogTarget, 0.01f);
	// print("current wind: " + wind);
		
	f32 sine = (Maths::Sin((getGameTime() * 0.0125f)) * 8.0f);
	Vec2f sineDir = Vec2f(0, 1).RotateBy(sine * 20);
	
	CBlob@[] blobs;
	getBlobsByTag("aerial", @blobs);
	for(u32 i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (blob !is null)
		{
			Vec2f pos = blob.getPosition();
			if (map.rayCastSolidNoBlobs(Vec2f(pos.x, 0), pos)) continue;
		
			blob.AddForce(sineDir * blob.getRadius() * wind * 0.01f);
		}
	}
	
	if (getNet().isClient())
	{	
		CBlob@ blob = getLocalPlayerBlob();
		if (blob !is null)
		{
			Vec2f bpos = blob.getPosition();
			Vec2f pos = Vec2f(int(bpos.x / spritesize) * spritesize, int(bpos.y / spritesize) * spritesize); 
		
			this.setPosition(pos);
			
			if (XORRandom(500) == 0)
			{
				Sound::Play("thunder_distant" + XORRandom(4));
				SetScreenFlash(XORRandom(100), 255, 255, 255);
			}
			
			Vec2f hit;
			if (getMap().rayCastSolidNoBlobs(Vec2f(bpos.x, 0), bpos, hit))
			{
				f32 depth = Maths::Abs(bpos.y - hit.y) / 8.0f;
				modifierTarget = 1.0f - Maths::Clamp(depth / 8.0f, 0.00f, 1);
				
				// print("underground: " + modifier);
			}
			else
			{
				modifierTarget = 1;
			}
			
			modifier = Lerp(modifier, modifierTarget, 0.10f);
			
			// print("" + modifier);
			
			if (getGameTime() % 5 == 0) ShakeScreen(Maths::Abs(wind) * 0.03f * modifier, 90, bpos);
			
			this.getSprite().SetEmitSoundSpeed(0.5f + modifier * 0.5f);
			this.getSprite().SetEmitSoundVolume(0.30f + 0.10f * modifier);
		}
		
		
		f32 fogDarkness = Maths::Clamp(50 + (fog * 0.10f), 0, 255);
		if (modifier > 0.01f) SetScreenFlash(Maths::Clamp(fog * modifier, 0, 255), fogDarkness, fogDarkness, fogDarkness);
		
		// print("" + modifier);
		
		// print("" + (fog * modifier));
		
		this.getShape().SetAngleDegrees(10 + sine);
	}
	
	if (getNet().isServer())
	{
		CMap@ map = getMap();
		u32 rand = XORRandom(1000);
		
		if (rand == 0)
		{
			f32 x = XORRandom(map.tilemapwidth);
			Vec2f pos = Vec2f(x, map.getLandYAtX(x)) * 8;
			
			CBlob@ blob = server_CreateBlob("lightningbolt", -1, pos);
		}	
		
		if (XORRandom(500) == 0)
		{
			CBlob@[] blobs;
			getBlobsByName("falloutgas", @blobs);
			
			if (blobs.length > 0)
			{
				CBlob@ b = blobs[XORRandom(blobs.length - 1)];
				if (b !is null)
				{
					b.server_Die();
				}
			}
		}
		
		DecayStuff();
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
	
	CBlob@[] plants;
	getBlobsByTag("nature", @plants);
	
	if (plants !is null && plants.length > 0)
	{
		// print("" + plants.length);
		
		u32 count = Maths::Ceil(plants.length * 0.01f);
		if (getGameTime() % 150 == 0) print("rain iteration count: " + count + "/" + plants.length);
		
		for (int i = 0; i < count; i++)
		{
			CBlob@ plant = plants[XORRandom(plants.length)];
			
			Vec2f pos = plant.getPosition();
			Vec2f tilePos = Vec2f(pos.x, pos.y + 8);
			// Vec2f offsetPos = Vec2f(tilePos.x + (XORRandom(10) - 5) * 8, tilePos.y + (XORRandom(6) - 3) * 8);
			
			// if (!map.isInWater(tilePos + Vec2f(0, -8))) return;
			
			uint16 tile = map.getTile(tilePos).type;
			// uint16 offsetTile = map.getTile(offsetPos).type;
						
			if (true)
			{
				// print("ye" + tilePos.x);
						
				// Vec2f grassPos = tilePos + Vec2f(((3 - XORRandom(6)) * 8), ((3 - XORRandom(6)) * 8) - 8);
				Vec2f grassPos = Vec2f(tilePos.x + ((5 - XORRandom(10)) * 8), tilePos.y + ((4 - XORRandom(8)) * 8));
				TileType grassTileType = map.getTile(grassPos).type;

				// Vec2f underGrassPos = grassPos + Vec2f(0, 8);
				Vec2f underGrassPos = Vec2f(grassPos.x, grassPos.y + 8);
				TileType underGrassTileType = map.getTile(underGrassPos).type;
				
				if (map.isTileSolid(underGrassTileType) && (map.isTileGround(underGrassTileType) || underGrassTileType == CMap::tile_castle_moss))
				{
					if (grassTileType == CMap::tile_empty)
					{
						// print("grew grass");
						map.server_SetTile(grassPos, CMap::tile_grass + XORRandom(3));
						// if (XORRandom(2) == 0 && blobs.length < 4) server_MakeSeed(tilePos + Vec2f(0, -8), seeds[XORRandom(seeds.length)]);
					}
					else if (map.isTileGrass(grassTileType))
					{
						CBlob@[] blobs;
						map.getBlobsInRadius(grassPos, 12, @blobs);
					
						if (blobs.length < 3) 
						{
							// print("grew seed");
							// print("pos: [" + pos.x + ", " + pos.y + "]" + " grassPos: [" + grassPos.x + ", " + grassPos.y + "]" + " underGrassPos: [" + underGrassPos.x + ", " + underGrassPos.y + "]");
							server_MakeSeed(grassPos, seeds[XORRandom(seeds.length)]);
						}
					}
				}
				
				Vec2f offsetChainPos = Vec2f(grassPos.x + (XORRandom(2) - 1) * 8, grassPos.y + (XORRandom(2) - 1) * 8);
				TileType offsetChainTileType = map.getTile(offsetChainPos).type;
				
				if (offsetChainTileType == CMap::tile_castle || offsetChainTileType == CMap::tile_castle_back)
				{
					if (map.isTileSolid(offsetChainTileType))
					{
						map.server_SetTile(offsetChainPos, CMap::tile_castle_moss);
					}
					else
					{
						map.server_SetTile(offsetChainPos, CMap::tile_castle_back_moss);
					}
				}
				// else if (map.isTileWood(offsetChainTileType))
				// {
					// map.server_DestroyTile(offsetChainPos, 0.5f);
				// }
				
				for (int j = 0; j < 5 + XORRandom(3); j++)
				{
					offsetChainPos = Vec2f(offsetChainPos.x + (XORRandom(4) - 2) * 8, offsetChainPos.y + (XORRandom(4) - 2) * 8);
					offsetChainTileType = map.getTile(offsetChainPos).type;
				
					if (offsetChainTileType == CMap::tile_castle_back)
					{
						if (XORRandom(3) == 0) map.server_SetTile(offsetChainPos, CMap::tile_castle_back_moss); 
						else
						{
							map.server_SetTile(offsetChainPos, 76 + XORRandom(2)); 
						
							// map.server_DestroyTile(offsetChainPos, XORRandom(10));
							// print("" + offsetChainTileType = map.getTile(offsetChainPos).type);
							// print("" + CMap::tile_castle_back);
						}
					}
					else if (offsetChainTileType == CMap::tile_castle)
					{
						if (XORRandom(3) == 0) map.server_SetTile(offsetChainPos, CMap::tile_castle_moss);
						else
						{
							map.server_SetTile(offsetChainPos, 58 + XORRandom(6)); 
						
							// map.server_DestroyTile(offsetChainPos, XORRandom(10));
							// print("" + offsetChainTileType = map.getTile(offsetChainPos).type);
							// print("" + CMap::tile_castle);
						}
					}
					else if (offsetChainTileType == CMap::tile_castle_back_moss)
					{
						if (XORRandom(5) == 0)
						{
							if (map.isTileSolid(map.getTile(offsetChainPos + Vec2f(0, 8)).type))
							{
								CBlob@[] blobs;
								map.getBlobsInRadius(offsetChainPos, 24, @blobs);
							
								if (blobs.length < 3) 
								{
									server_MakeSeed(offsetChainPos, seeds[XORRandom(seeds.length)]);
								}
							}
							else if (map.isTileSolid(map.getTile(offsetChainPos + Vec2f(0, -8)).type))
							{
								CBlob@[] blobs;
								map.getBlobsInRadius(offsetChainPos, 12, @blobs);
							
								if (blobs.length == 0) 
								{
									server_CreateBlob("ivy", -1, offsetChainPos + Vec2f(0, 16));
								}
							}
						}
					}
					else if (offsetChainTileType == CMap::tile_wood_back)
					{
						if (XORRandom(6) == 0)
						{
							if (map.isTileSolid(map.getTile(offsetChainPos + Vec2f(0, 8)).type))
							{
								CBlob@[] blobs;
								map.getBlobsInRadius(offsetChainPos, 24, @blobs);
							
								if (blobs.length < 4) 
								{
									server_CreateBlob("bush", -1, offsetChainPos);
									
									for (int k = 0; k < XORRandom(8); k++)
									{
										map.server_DestroyTile(Vec2f(offsetChainPos.x + (XORRandom(4) - 2) * 8, offsetChainPos.y + (XORRandom(4) - 2) * 8), 0.5f);
									}
								}
							}
							else if (map.isTileSolid(map.getTile(offsetChainPos + Vec2f(0, -8)).type))
							{
								CBlob@[] blobs;
								map.getBlobsInRadius(offsetChainPos, 12, @blobs);
							
								if (blobs.length == 0) 
								{
									server_CreateBlob("ivy", -1, offsetChainPos + Vec2f(0, 16));
									
									for (int k = 0; k < XORRandom(8); k++)
									{
										map.server_DestroyTile(Vec2f(offsetChainPos.x + (XORRandom(4) - 2) * 8, offsetChainPos.y + (XORRandom(4) - 2) * 8), 0.5f);
									}
								}
							}
							else
							{
								CBlob@[] blobs;
								map.getBlobsInRadius(offsetChainPos, 24, @blobs);
							
								if (blobs.length == 0) 
								{
									server_CreateBlob("bush", -1, offsetChainPos);
									
									for (int k = 0; k < XORRandom(8); k++)
									{
										map.server_DestroyTile(Vec2f(offsetChainPos.x + (XORRandom(4) - 2) * 8, offsetChainPos.y + (XORRandom(4) - 2) * 8), 0.5f);
									}
								}
							}
						}
					}
					else if (offsetChainTileType == CMap::tile_wood)
					{
						for (int j = 0; j < XORRandom(8); j++)
						{
							map.server_DestroyTile(Vec2f(offsetChainPos.x + (XORRandom(4) - 2) * 8, offsetChainPos.y + (XORRandom(4) - 2) * 8), 0.5f);
						}
					}
					
					// else if (!map.isTileGround(offsetChainTileType) && !map.isTileCastle(offsetChainTileType) && !map.isTileGrass(offsetChainTileType))
					// {
						// map.server_DestroyTile(offsetChainPos, 0.50f);
					// }
				}
			}
			else
			{
				return;
			}
		}
	}
}