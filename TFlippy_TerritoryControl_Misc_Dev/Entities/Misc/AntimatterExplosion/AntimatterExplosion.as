#include "Hitters.as";
#include "Explosion.as";

f32 sound_delay;

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png",
};

void onInit(CBlob@ this)
{
	// this.Tag("map_damage_dirt");
	// this.Tag("no explosion particles");
	
	this.getShape().SetStatic(true);
	// this.set_f32("map_damage_ratio", 0.125f);
	
	if (!this.exists("boom_frequency")) this.set_u8("boom_frequency", 7);
	if (!this.exists("boom_size")) this.set_f32("boom_size", 0);
	if (!this.exists("boom_end")) this.set_f32("boom_end", 1024);
	if (!this.exists("boom_delay")) this.set_u32("boom_delay", 10);
	if (!this.exists("boom_increment")) this.set_f32("boom_increment", 2.00f);
	if (!this.exists("flash_delay")) this.set_u32("flash_delay", 0);
	if (!this.exists("flash_distance")) this.set_f32("flash_distance", 2500);
	if (!this.exists("custom_explosion_sound")) this.set_string("custom_explosion_sound", "Antimatter_Kaboom_Big");
	
	if (isClient())
	{
		Vec2f pos = getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos());
		f32 distance = Maths::Abs(this.getPosition().x - pos.x) / 8;
		sound_delay = (Maths::Abs(this.getPosition().x - pos.x) / 8) / (340 * 0.4f);
		
		f32 length = Maths::Abs(this.get_f32("boom_size") - this.get_f32("boom_end")) / this.get_f32("boom_increment");
		for (int i = 0; i < (this.get_f32("boom_end") / 32); i++)
		{
			MakeLightningParticle(this, this.getPosition() + getRandomVelocity(0, XORRandom(100) * 0.01f, 360), Maths::Min(1 + length, 8), (XORRandom(200) * 0.01f), Maths::Min((this.get_f32("boom_end") / 32) * 0.25f, (XORRandom(50) * 0.01f) * 0.50f));
		}
		
		// MakePulseParticle(this, Vec2f(0, 0), 1, 1 + (this.get_f32("boom_size") * 0.40f), 0.5f);
	}

	this.getCurrentScript().tickFrequency = 1;
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}
	
	const f32 boom_size = this.get_f32("boom_size");
	const f32 modifier = boom_size / this.get_f32("boom_end");
	const f32 invModifier = 1.00f - modifier;
		
	if (isServer())
	{			
		server_DestroyStuff(this, boom_size, 10 + (25 * modifier), this.getPosition());
	
		if (!this.hasTag("no flash"))
		{		
			CMap@ map = this.getMap();
			const f32 flash_distance = this.get_f32("flash_distance");
		
			for (int i = 0; i < 30; i++)
			{
				Vec2f dir = Vec2f(XORRandom(200) - 100, XORRandom(200) - 100);
				dir.Normalize();
				
				Vec2f hit;
				
				if (map.rayCastSolidNoBlobs(this.getPosition(), this.getPosition() + (dir * flash_distance), hit))
				{
					Vec2f tp = hit + (dir * 0.25f);
					map.server_DestroyTile(tp, 10.0f);
					map.server_setFireWorldspace(tp + Vec2f(8 - XORRandom(24), 8 - XORRandom(24)), true);
				}
			}
		}
	}
}

void server_DestroyStuff(CBlob@ this, f32 radius, u32 count, Vec2f pos)
{
	CMap@ map = getMap();
	for (u32 i = 0; i < count; i++)
	{
		f32 angle = XORRandom(360);
		Vec2f a_pos = pos + Vec2f(Maths::Cos(angle), Maths::Sin(angle)) * (radius + XORRandom(32));
		// a_pos = pos + Vec2f(a_pos.x, a_pos.y * 0.50f);
		
		CBlob@[] blobs;
		if (map.getBlobsInRadius(a_pos, 64, @blobs))
		{
			for (u32 i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];
				if (b !is this)
				{
					b.server_Die();
				}
			}
		}
		
		for (u32 j = 0; j < 10; j++)
		{
			Vec2f b_pos = a_pos + Vec2f(32 - XORRandom(64), 32 - XORRandom(64));
			// map.server_SetTile(b_pos, CMap::tile_empty);
			map.server_DestroyTile(b_pos, 100);
			// map.server_setFloodWaterWorldspace(b_pos, false);
			
			// CParticle@ p = ParticlePixel(b_pos, Vec2f(0, 0), SColor(255, 255, 0, 0), true);
			// if (p !is null)
			// {
				// p.gravity = Vec2f(0, 0);
			// }
			
		}
	}
}

const u32 pulse_ticks = 90;

void onTick(CBlob@ this)
{
	const u32 ticks = this.getTickSinceCreated();

	if (this.get_f32("boom_size") >= this.get_f32("boom_end")) 
	{
		if (isServer() && ticks > 150) this.server_Die();
		this.Tag("dead");
	}
	
	const bool dead = this.hasTag("dead");
	
	if (isClient())
	{
		if (ticks > (sound_delay * 30) && !this.hasTag("sound_played"))
		{
			this.Tag("sound_played");
		
			f32 modifier = Maths::Clamp(1.00f - (sound_delay / 3.0f), 0.10f, 0.80f);
			// print("modifier: " + modifier);
			
			if (modifier > 0.01f)
			{	
				Sound::Play("Nuke_Kaboom_Big.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), 2.0f - (0.2f * (1 - modifier)), Maths::Max(modifier * 0.90f, 0.10f));
			}
		}
	}
	
	if (dead) return;
	
	CMap@ map = getMap();
	const f32 boom_size = this.get_f32("boom_size");
	const f32 boom_end = this.get_f32("boom_end");
	const f32 modifier = boom_size / boom_end;
	const f32 invModifier = 1.00f - modifier;
	
	if (isClient())
	{
		const f32 fx_count = Maths::Pow(boom_size / 32, 2) * 0.01f;
		const s32 max_width = map.tilemapwidth * map.tilesize;
		const s32 max_height = map.tilemapheight * map.tilesize;
		
		for (int i = 0; i < fx_count; i++)
		{
			// Vec2f offset = getRandomVelocity(0, XORRandom(boom_size), 360);
			
			Vec2f offset = this.getPosition() + getRandomVelocity(0, boom_size + ((boom_size - XORRandom(boom_size * 2)) * 0.125f), 360);
			// print("" + offset.x + "; " + offset.y);
			
			// if (offset.x > 0 && offset.y > 0 && offset.x < max_width && offset.y < max_height)
			if (offset.x > 0 && offset.y > 0 && offset.x < max_width && offset.y < max_height)
			{
				f32 dist = (offset - this.getPosition()).getLength();
				f32 dist_mod = 1.00f - (dist / boom_end);
				
				MakeLightningParticle(this, offset + getRandomVelocity(0, 32 - XORRandom(64), 360), 4, Maths::Sqrt(boom_size / 32.00f), 0.20f);
				MakeExplosionParticle(this, offset + getRandomVelocity(0, XORRandom(48), 360), Vec2f(0, 0), 5 + XORRandom(3), particles[XORRandom(particles.length)]);
			}
		}
		
		
		if (ticks % pulse_ticks == 0)
		{
			MakePulseParticle(this, Vec2f(0, 0), 1, 1 + (boom_size * 0.40f), modifier * 0.5f);
		}
		
		if (pulseParticle !is null)
		{
			f32 pulseMod = 1.00f - ((ticks % pulse_ticks) / f32(pulse_ticks));
			u32 color = 255 * Maths::Pow(pulseMod, 1.25f);
			
			// print("" + color);
			pulseParticle.colour = SColor(255, color, color, color);
		}
	
		CBlob@ localBlob = getLocalPlayerBlob();
		if (localBlob !is null)
		{
			f32 dist = (localBlob.getPosition() - this.getPosition()).getLength();
			dist = Maths::Max(dist - boom_size, 0);
			
			const f32 flash_distance = Maths::Min(this.get_f32("flash_distance"), 256);
			
			
			// print("" + dist + " / " + flash_distance);
			
			if (dist <= flash_distance)
			{
				f32 flashMod = Maths::Sqrt(1.00f - (dist / flash_distance));
				// print("" + flashMod);
				SetScreenFlash(255 * flashMod, 255, 255, 255, 1);
			}
			
			ShakeScreen(256, 128, this.getPosition());
			
			if (ticks % 10 == 0)
			{
				const f32 sound_distance = Maths::Sqrt(boom_size * 5000);
				// print("" + dist + "/" + sound_distance);
				
				if (dist <= sound_distance)
				{
					f32 modifier = Maths::Clamp(Maths::Sqrt(dist / sound_distance), 0.10f, 1.00f);
					// print("" + modifier);
					
					if (modifier > 0.01f)
					{	
						// print("" + modifier);
						
						f32 volume = Maths::Clamp(2.0f - (0.60f * (1 - modifier)), 0.25f, 0.70f);
						f32 pitch = Maths::Clamp((modifier * 0.50f) - (XORRandom(100) * 0.003f), 0.50f, 1.00f);
						
						// print("volume: " + volume + "; pitch: " + pitch);
						
						Sound::Play("Antimatter_Kaboom.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), volume, pitch);
					}
				}
			}
		}
	}
	
	if (isClient() && !this.hasTag("no flash") && ticks == this.get_u32("flash_delay")) 
	{
		CBlob@ localBlob = getLocalPlayerBlob();
		if (localBlob !is null)
		{
			const f32 dist = (localBlob.getPosition() - this.getPosition()).getLength();
			const f32 flash_distance = this.get_f32("flash_distance") * 5;

			if (dist <= flash_distance)
			{
				f32 flashMod = Maths::Sqrt(1.00f - (dist / flash_distance));
				// print("" + flashMod);
				SetScreenFlash(255 * Maths::Min(flashMod * 2, 1), 255, 255, 255, 5 * flashMod);
			}
		}
	}
	
	if (ticks >= this.get_u32("boom_delay") && ticks % this.get_u8("boom_frequency") == 0 && this.get_f32("boom_size") < this.get_f32("boom_end"))
	{
		DoExplosion(this);
		this.add_f32("boom_size", this.get_f32("boom_increment"));
		
		// f32 modifier = 1.00f - (float(this.get_u8("boom_size")) / float(this.get_u8("boom_end")));
		// this.SetLightRadius(1024.5f * modifier);
	}
	
	if (!this.hasTag("no flash"))
	{
		if (isServer())
		{
			if (ticks == 2)
			{		
				CBlob@[] blobs;
				if (this.getMap().getBlobsInRadius(this.getPosition(), this.get_f32("flash_distance"), @blobs))
				{
					for (int i = 0; i < blobs.length; i++)
					{
						CBlob@ blob = blobs[i];
						
						if (!this.getMap().rayCastSolidNoBlobs(blob.getPosition(), this.getPosition()))
						{
							this.server_Hit(blob, blob.getPosition(), Vec2f(), 350.00f, Hitters::fire, true);
						}
					}
				}
			}	
		}
	}
}

CParticle@ pulseParticle;

void MakePulseParticle(CBlob@ this, const Vec2f pos, const f32 time, const f32 size, const f32 growth)
{
	if(!isClient()){return;}
	
	CParticle@ p = ParticleAnimated("AntimatterFlash.png", this.getPosition() + pos, Vec2f(0, 0), 0, 0, 0, 0, true);
	if (p !is null)
	{
		p.Z = 100;
		p.animated = pulse_ticks;
		p.growth = growth;
		p.setRenderStyle(RenderStyle::additive);
		p.colour = SColor(255, 255, 255, 255);
		
		@pulseParticle = p;
	}
	else 
	{
		// print("null");
	}
}

void MakeLightningParticle(CBlob@ this, const Vec2f pos, const f32 time, const f32 size, const f32 growth, const string filename = "AntimatterLightning.png")
{
	if(!isClient()){return;}
	CParticle@ p = ParticleAnimated(filename, pos, Vec2f(0, 0), XORRandom(360), size, RenderStyle::additive, 0, Vec2f(32, 32), 1, 0, true);
	if (p !is null)
	{
		p.Z = 200;
		p.animated = time;
		p.growth = growth;
		p.setRenderStyle(RenderStyle::additive);
	}
}

void MakeExplosionParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const f32 time, const string filename = "SmallSteam")
{
	if(!isClient()){return;}
	CParticle@ p = ParticleAnimated(filename, pos, vel, float(XORRandom(360)), 2.8f + XORRandom(200) * 0.01f, time, XORRandom(100) * -0.00005f, true);
	if (p !is null)
	{
		p.Z = 300;
	}
}