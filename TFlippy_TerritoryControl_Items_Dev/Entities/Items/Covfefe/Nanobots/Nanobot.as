#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";
#include "CustomBlocks.as";

const f32 reproduce_threshold = 500.0f;

void onInit(CBlob@ this)
{
	this.Tag("invincible");
	this.getShape().SetGravityScale(0);
	this.getSprite().SetZ(10.0f);
	
	this.set_f32("fill", reproduce_threshold / 2);
	this.set_u16("target", 0);

	// this.server_SetTimeToDie(60);
	// this.getShape().getConsts().mapCollisions = false;
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("/Nanobot_Loop.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundSpeed(1.0f);
	sprite.SetEmitSoundVolume(1.0f);
	
	this.Tag("nanobot_ignore");
}

const f32 max_distance = 256;

CBlob@ GetTarget(CBlob@ this)
{
	CBlob@[] blobs;
	if (this.getMap().getBlobsInRadius(this.getPosition(), max_distance, @blobs))
	{
		f32 dist = max_distance * max_distance;
		int index = -1;
	
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			f32 d = (blob.getPosition() - this.getPosition()).Length();
			
			if (d <= dist && !blob.exists("nanobot_netid") && !blob.hasTag("nanobot_ignore"))
			{
				dist = d;
				index = i;
			}
		}
		
		if (index >= 0)
		{
			return blobs[index];
		}
		else
		{
			CBlob@[] allBlobs;
			getBlobs(allBlobs);
			
			for (int i = 0; i < 4; i++)
			{
				CBlob@ blob = allBlobs[XORRandom(allBlobs.size())];
				if ((blob.getPosition() - this.getPosition()).Length() < (max_distance * max_distance * 8.00f) && !blob.exists("nanobot_netid") && !blob.hasTag("nanobot_ignore") && !blob.isInInventory())
				{
					return blob;
				}
			}
		}
		
	}
	
	return null;
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();
	u32 tick = this.getTickSinceCreated();

	if(isClient())
	{
		MakeParticle(this, "Nanobot.png");
		
		if (tick % 10 == 0)
		{
			f32 vellen = this.getVelocity().getLength();
			
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSoundSpeed(0.25f + Maths::Min(vellen * 0.10f, 0.80f) + (XORRandom(100) * 0.01f));
			sprite.SetEmitSoundVolume(0.25f + vellen);
		}
	}

	CBlob@ remote = getBlobByNetworkID(this.get_u16("remote_netid"));
	if (remote !is null)
	{
		Vec2f dir = this.get_Vec2f("target_position") - pos;
		f32 len = dir.Length();
		dir.Normalize();
		
		this.setVelocity(dir * Maths::Clamp(len * 0.125f, -8, 8));
	}
	else
	{
		CBlob@ target = getBlobByNetworkID(this.get_u16("target"));	
		if (target !is null)
		{
			if (target.exists("nanobot_netid") && target.get_u16("nanobot_netid") == this.getNetworkID() && !target.hasTag("nanobot_ignore"))
			{
				Vec2f dir = target.getPosition() - pos;
				f32 len = dir.Length();
				dir.Normalize();
				
				this.setVelocity(dir * Maths::Clamp(len * 0.125f, -8, 8));
				this.set_u8("mode", 0);
				
				if (this.get_f32("fill") >= reproduce_threshold)
				{
					if (isServer())
					{
						server_CreateBlob("nanobot", -1, pos);
					}
					
					if (isClient())
					{
						this.getSprite().PlaySound("Nanobot_Ping_Split", 1.00f, 1.00f);
					}
					
					this.set_f32("fill", this.get_f32("fill") - reproduce_threshold);
				}
			}
			else
			{
				this.set_u16("target", 0);
				target.Tag("nanobot_ignore");
			}
		}
		else if (XORRandom(50) == 0)
		{
			CBlob@ target = GetTarget(this);
			if (target !is null) 
			{
				this.set_u16("target", target.getNetworkID());
				target.set_u16("nanobot_netid", this.getNetworkID());
				this.Sync("target", true);
				
				if (isClient()) this.getSprite().PlaySound("Nanobot_Ping_Found", 1.00f, 1.00f);
			}
			else
			{
				if (isClient()) this.getSprite().PlaySound("Nanobot_Ping_Searching", 1.00f, 1.00f);
			}
		}
	}

	const u8 mode = this.get_u8("mode");	
	switch (mode)
	{
		case 0:
		{
			if (tick % 3 == 0)
			{
				bool hit = false;
			
				CBlob@[] blobs;
				if (map.getBlobsInRadius(pos, 8.0f, @blobs))
				{
					for (int i = 0; i < blobs.length; i++)
					{
						CBlob@ blob = blobs[i];
						if (blob !is null)
						{
							if (!blob.hasTag("nanobot_ignore"))
							{
								f32 damage = blob.getInitialHealth() / 5.0f;
							
								if (isServer()) 
								{
									f32 health = blob.getHealth();
									this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), damage * (blob.hasTag("flesh") ? 4.00f : 1.00f), HittersTC::nanobot, true);
									
									if (blob.getHealth() == health)
									{
										blob.Tag("nanobot_ignore");
									}
								}
								
								hit = true;
								this.add_f32("fill", damage);
							}
						}
					}
				}
			
				for (int x = 0; x < 4; x++)
				{
					Vec2f tpos = pos + (Vec2f(3 - XORRandom(6), 3 -XORRandom(6)) * 8.00f);
					Tile tile = map.getTile(tpos);
					if (tile.type != CMap::tile_empty)
					{
						if (isServer()) map.server_DestroyTile(tpos, 0.125f);
						hit = true;
					}
				}
				
				if (isClient())
				{
					if (hit)
					{
						this.getSprite().PlaySound("Nanobot_Attack.ogg", 0.50f, 0.25f + XORRandom(100) * 0.01f);
					}
				}
			}
		}
		break;
	
		case 1:
		{
		
		}
		break;
	}
}

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("/Nanobot_Die.ogg", 0.75f, 0.50f + XORRandom(100) * 0.01f);
	this.getSprite().Gib();
	 
	Explode(this, 32.0f, 2.0f);
	 
	if (isServer())
	{
		for (int i = 0; i < (5 + XORRandom(15)); i++)
		{
			CBlob@ blob = server_CreateBlob("mat_matter", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(XORRandom(4));
			blob.setVelocity(getRandomVelocity(0, XORRandom(24), 360));
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	// return blob.getName() == "nanobot";
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}

void MakeParticle(CBlob@ this, const string filename = "LargeSmoke")
{
	CParticle@ particle = ParticleAnimated(filename, this.getPosition() + getRandomVelocity(0, XORRandom(24), 360), this.getOldVelocity() * 0.25f, float(XORRandom(360)), 1.00f, 2, 0.00f, false);
	if (particle !is null) 
	{
		particle.fastcollision = true;
		particle.setRenderStyle(RenderStyle::normal);
	}
	
	// normal
	// light
	// outline
	// outline_front
	// additive
	// subtractive
	// shadow
	// solid
}
