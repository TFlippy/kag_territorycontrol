#include "Hitters.as";
#include "Explosion.as";
#include "MakeDustParticle.as";
#include "FireParticle.as";

// const Vec2f arm_offset = Vec2f(-2, -4);

// const u8 explosions_max = 25;

// f32 sound_delay;

void onInit(CBlob@ this)
{
	// this.Tag("map_damage_dirt");
	// this.set_string("custom_explosion_sound", "KegExplosion");
	
	this.getShape().SetStatic(true);
	
	// SetScreenFlash(255, 255, 255, 255);
	
	// if (isClient())
	// {
		// Vec2f pos = getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos());
		// f32 distance = Maths::Abs(this.getPosition().x - pos.x) / 8;
		// sound_delay = (Maths::Abs(this.getPosition().x - pos.x) / 8) / (340 * 0.4f);
		
		// print("delay: " + sound_delay);
	// }
	
	// this.SetLight(true);
	// this.SetLightColor(SColor(255, 255, 255, 255));
	// this.SetLightRadius(1024.5f);
	
	this.Tag("map_damage_dirt");
	this.set_f32("map_damage_radius", 16);
	// this.set_f32("map_damage_ratio", 0.25f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "");
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("FireWave_EarRape.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(1.5f);
	
	
	this.getCurrentScript().tickFrequency = 5;
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	bool server = isServer();
	bool client = isClient();
	
	Vec2f top = Vec2f(this.getPosition().x, 0);
	Vec2f bottom = Vec2f(this.getPosition().x, map.tilemapheight * 8);
	Vec2f pos;
		
	if (map.rayCastSolid(top, bottom, pos))
	{
		if (server)
		{
			Explode(this, 32.0f, 1.0f);
		
			if (XORRandom(100) < 75)
			{
				CBlob@ flame = server_CreateBlob("flame", this.getTeamNum(), pos);
				flame.server_SetTimeToDie(3 + XORRandom(10));
			}
		}
	}
	
	if (server)
	{
		if (top.x > (map.tilemapwidth * 8) - 8) this.server_Die();
	
		CBlob@[] blobs;
		if (map.getBlobsInBox(Vec2f(top.x - 64, top.y), Vec2f(pos.x, pos.y), blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{
				if (blobs[i] is null) continue;
				CBlob@ blob = blobs[i];
				
				this.server_Hit(blob, blob.getPosition(), Vec2f(), 80.00f, Hitters::fire, true);
			}
		}
	}
	
	for (int i = 0; i < pos.y; i += 8)
	{
		Vec2f p =  Vec2f(pos.x + 10 - XORRandom(20), i);
	
		if (server && i % 16 == 0) 
		{
			if (map.isTileWood(map.getTile(p).type)) map.server_setFireWorldspace(p, true);
		}
		if (client) makeSteamParticle(this, p, Vec2f(), XORRandom(100) < 30 ? ("LargeSmoke" + (1 + XORRandom(2))) : "Explosion" + (1 + XORRandom(3)));
	}
	
	if (client) ShakeScreen(256, 64, pos);
	
	this.setPosition(pos + Vec2f(6, 0));
}

void makeSteamParticle(CBlob@ this, Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(filename, pos + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

// void DoExplosion(CBlob@ this)
// {
	// ShakeScreen(512, 64, this.getPosition());
	// // SetScreenFlash(255 * (1.00f - (f32(this.get_u8("boom_start")) / f32(explosions_max))), 255, 255, 255);
	
	// f32 modifier = f32(this.get_u8("boom_start")) / f32(explosions_max);
	
	// this.set_f32("map_damage_radius", 256.0f * modifier);
	
	// this.set_Vec2f("explosion_offset", Vec2f(0, 0));
	// Explode(this, 128.0f * modifier, 16.0f * (1 - modifier));
	
	// for (int i = 0; i < 2; i++)
	// {
		// this.set_Vec2f("explosion_offset", Vec2f((100 - XORRandom(200)) / 50.0f, (100 - XORRandom(200)) / 400.0f) * 128 * modifier);
		// Explode(this, 128.0f * modifier, 16.0f * (1 - modifier));
	// }
	
	// if (isServer())
	// {
		// for (int i = 0; i < 3; i++)
		// {
			// CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			// blob.server_SetQuantity(15 + XORRandom(150) * (1 - modifier));
			// blob.setVelocity(Vec2f(30 - XORRandom(60), -10 - XORRandom(20)) * (0.5f + modifier));
		// }
	// }
// }

// void onTick(CBlob@ this)
// {
	// if (this.get_u8("boom_start") == explosions_max) 
	// {
		// if (isServer()) this.server_Die();
		// this.Tag("dead");
		
		// return;
	// }
	
	// if (this.hasTag("dead")) return;

	// u32 ticks = this.getTickSinceCreated();
	
	// if (getGameTime() % 2 == 0 && this.get_u8("boom_start") < explosions_max)
	// {
		// DoExplosion(this);
		// this.set_u8("boom_start", this.get_u8("boom_start") + 1);
		
		// f32 modifier = 1.00f - (float(this.get_u8("boom_start")) / float(explosions_max));
		
		// this.SetLightRadius(1024.5f * modifier);
	// }
	
	// if (isServer())
	// {
		// if (ticks == 2)
		// {
			// CBlob@[] blobs;
		
			// if (this.getMap().getBlobsInRadius(this.getPosition(), 2000, @blobs))
			// {
				// print("" + blobs.length);
			
				// for (int i = 0; i < blobs.length; i++)
				// {
					// CBlob@ blob = blobs[i];
				
					// if (!this.getMap().rayCastSolidNoBlobs(blob.getPosition(), this.getPosition()))
					// {
						// this.server_Hit(blob, blob.getPosition(), Vec2f(), 10.0f, Hitters::fire, true);
					// }
				// }
			// }
		// }	
	// }
		
	// if (isClient())
	// {
		// if (ticks > (sound_delay * 30) && !this.hasTag("sound_played"))
		// {
			// this.Tag("sound_played");
		
			// f32 modifier = 1.00f - (sound_delay / 3.0f);
			// print("modifier: " + modifier);
			
			// if (modifier > 0.01f)
			// {	
				// Sound::Play("Nuke_Kaboom_Big.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), 1.0f - (0.7f * (1 - modifier)), modifier);
			// }
		// }
	// }
// }