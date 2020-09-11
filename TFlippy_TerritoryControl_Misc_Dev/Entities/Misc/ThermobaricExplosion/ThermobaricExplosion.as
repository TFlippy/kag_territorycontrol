#include "Hitters.as";
#include "Explosion.as";
#include "CustomBlocks.as";

f32 sound_delay;

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png",
};

void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	
	if (!this.exists("boom_frequency")) this.set_u8("boom_frequency", 1);
	if (!this.exists("boom_size")) this.set_f32("boom_size", 0);
	if (!this.exists("boom_end")) this.set_f32("boom_end", 256);
	if (!this.exists("boom_delay")) this.set_u32("boom_delay", 15);
	if (!this.exists("boom_increment")) this.set_f32("boom_increment", 4.00f);
	if (!this.exists("custom_explosion_sound")) this.set_string("custom_explosion_sound", "ThermobaricExplosion");
	
	if (isClient())
	{
		Vec2f pos = getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos());
		f32 distance = Maths::Abs(this.getPosition().x - pos.x) / 8;
		sound_delay = (Maths::Abs(this.getPosition().x - pos.x) / 8) / (340 * 0.4f);
		
		MakeFuelParticle(this, Vec2f(0, 0), this.get_u32("boom_delay") / 2.00f, (XORRandom(200) * 0.01f), Maths::Min((this.get_f32("boom_end") / 32) * 0.25f, 0.15f));
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
		
	DestroyStuff(this, boom_size, 3 + (5 * modifier), this.getPosition());
}

void DestroyStuff(CBlob@ this, f32 radius, u32 count, Vec2f pos)
{
	const bool server = isServer();
	const bool client = isClient();

	CMap@ map = getMap();
	
	f32 boom_size = this.get_f32("boom_size") * 1.25f;
	f32 boom_size_sqr = boom_size * boom_size;
	f32 boom_size_max = this.get_f32("boom_end");
	f32 boom_progress = boom_size / boom_size_max;
	
	if (server)
	{
		f32 force_sign = boom_progress < 0.60f ? 1.00f : -0.50f;
	
		CBlob@[] blobs;
		if (map.getBlobsInRadius(pos, boom_size * 2.00f, @blobs))
		{
			for (u32 i = 0; i < blobs.length; i++)
			{
				CBlob@ blob = blobs[i];
				if (blob !is null && blob !is this)
				{
					Vec2f bpos = blob.getPosition();
					Vec2f dir = bpos - pos;
					f32 lenSqr = dir.LengthSquared();
					dir.Normalize();
				
					if (lenSqr < (boom_size_sqr * 0.50f) && !blob.hasTag("invincible"))
					{
						map.server_setFireWorldspace(bpos, true);
						blob.server_Hit(blob, bpos, Vec2f(0, 0), 8.0f, Hitters::fire);
					}
				
					if (!map.rayCastSolid(pos, bpos))
					{
						blob.AddForce(dir * Maths::Min(1000.0f, blob.getMass() * 1.50f) * force_sign);
						blob.server_Hit(blob, bpos, Vec2f(0, 0), 0.125f, Hitters::crush);
					}
				}
			}
		}
	}
	
	if (boom_progress < 0.70f)
	{
		for (u32 i = 0; i < count; i++)
		{
			f32 angle = XORRandom(360);

			Vec2f dir = Vec2f(Maths::Cos(angle), Maths::Sin(angle));
			Vec2f start_pos = pos;
			Vec2f target_pos = pos + dir * (radius + XORRandom(32));
			Vec2f a_pos = target_pos;
		
			map.rayCastSolidNoBlobs(start_pos, target_pos, a_pos);

			for (u32 j = 0; j < 10; j++)
			{
				Vec2f b_pos = a_pos + Vec2f(16 - XORRandom(32), 16 - XORRandom(32));
				
				if (server)
				{
					TileType t = map.getTile(b_pos).type;
					bool hit = true;
					
					if (XORRandom(100) > 10)
					{
						switch (t)
						{
							case CMap::tile_castle_d0:
							case CMap::tile_ground_d0:
							case CMap::tile_plasteel_d14:
							case CMap::tile_bplasteel_d14:
							case CMap::tile_biron_d8:
							case CMap::tile_iron_d8:
							case CMap::tile_rustyiron_d4:
							case CMap::tile_reinforcedconcrete_d15:
							case CMap::tile_concrete_d7:
							case CMap::tile_mossyconcrete_d4:
							case CMap::tile_bconcrete_d7:
							case CMap::tile_mossybconcrete_d4:
								hit = false;
							break;						
						}
					}
					
					if (hit)
					{
						map.server_DestroyTile(b_pos, 1, this);
						map.server_setFireWorldspace(b_pos, true);
					}
					
					
					// if (t != CMap::tile_castle_d0 && t != CMap::tile_ground_d0 && (XORRandom(100) < 50 ? true : t != CMap::tile_ground_d1))
					// {
						// map.server_DestroyTile(b_pos, 1, this);
					// }
					// else
					// {
						// map.server_setFireWorldspace(b_pos, true);
					// }
				}
				
				if (client)
				{
					if (j == 0 && XORRandom(100) < 25) MakeExplosionParticle(this, b_pos, Vec2f(0, 0), 5 + XORRandom(3), particles[XORRandom(particles.length)]);
				}
			}
		}
	}
}

void onTick(CBlob@ this)
{
	if (this.get_f32("boom_size") >= this.get_f32("boom_end")) 
	{
		if (isServer()) this.server_Die();
		this.Tag("dead");
		
		return;
	}
	
	if (this.hasTag("dead")) return;
	
	const f32 boom_size = this.get_f32("boom_size");
	const f32 boom_end = this.get_f32("boom_end");
	const u32 ticks = this.getTickSinceCreated();
	const f32 modifier = boom_size / boom_end;
	const f32 invModifier = 1.00f - modifier;
	
	if (isClient())
	{
		/*for (int i = 0; i < Maths::Pow(boom_size / 32, 2) * 0.01f; i++)
		{
			// Vec2f offset = getRandomVelocity(0, boom_size + ((boom_size - XORRandom(boom_size * 2)) * 0.125f), 360);
			
			// f32 dist = (offset - this.getPosition()).getLength();
			// f32 dist_mod = 1.00f - (dist / boom_end);
			
			// MakeExplosionParticle(this, offset + getRandomVelocity(0, XORRandom(48), 360), Vec2f(0, 0), 5 + XORRandom(3), particles[XORRandom(particles.length)]);
		}*/
			
		CBlob@ localBlob = getLocalPlayerBlob();
		if (localBlob !is null)
		{
			f32 dist = (localBlob.getPosition() - this.getPosition()).getLength();
			dist = Maths::Max(dist - boom_size, 0);
			
			ShakeScreen(256, 128, this.getPosition());
			
			if (ticks % 10 == 0)
			{
				const f32 sound_distance = Maths::Sqrt(boom_size * 5000);
				// print("" + dist + "/" + sound_distance);
				
				if (dist <= sound_distance && sound_distance > 0)
				{
					f32 modifier = 1.00f - Maths::Sqrt(dist / sound_distance);
					
					if (modifier > 0.01f)
					{	
						Sound::Play("ThermobaricExplosion", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), 2.0f - (0.2f * (1 - modifier)), modifier);
					}
				}
			}
		}

		
		if (ticks > (sound_delay * 30) && !this.hasTag("sound_played"))
		{
			this.Tag("sound_played");
		
			f32 modifier = 1.00f - (sound_delay / 3.0f);
			if (modifier > 0.01f)
			{	
				Sound::Play("Missile_Explode", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), 2.0f - (0.2f * (1 - modifier)), modifier);
			}
		}
	}
		
	if (ticks >= this.get_u32("boom_delay") && ticks % this.get_u8("boom_frequency") == 0 && this.get_f32("boom_size") < this.get_f32("boom_end"))
	{
		DoExplosion(this);
		this.add_f32("boom_size", this.get_f32("boom_increment"));
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

void MakeFuelParticle(CBlob@ this, const Vec2f pos, const f32 time, const f32 size, const f32 growth, const string filename = "FuelGas.png")
{
	if(!isClient()){return;}
	CParticle@ p = ParticleAnimated(filename, this.getPosition() + pos, Vec2f(0, 0), XORRandom(360), size, RenderStyle::additive, 0, Vec2f(32, 32), 1, 0, true);
	if (p !is null)
	{
		p.Z = 200;
		p.animated = time;
		p.growth = growth;
		p.setRenderStyle(RenderStyle::additive);
	}
}