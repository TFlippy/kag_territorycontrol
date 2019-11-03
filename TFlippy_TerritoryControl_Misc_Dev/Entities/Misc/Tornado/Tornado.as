#include "Hitters.as";
#include "Explosion.as";
#include "MakeDustParticle.as";
#include "FireParticle.as";

// const Vec2f arm_offset = Vec2f(-2, -4);

// const u8 explosions_max = 25;

// f32 sound_delay;

string[] particles = 
{
	"dust.png",
	"dust2.png",
	"DustSmall.png",
	// "Smoke.png"
};

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
		
			// if (XORRandom(100) < 75)
			// {
				// CBlob@ flame = server_CreateBlob("flame", this.getTeamNum(), pos);
				// flame.server_SetTimeToDie(3 + XORRandom(10));
			// }
		}
	}
	
	if (server)
	{
		if (top.x > (map.tilemapwidth * 8) - 8) this.server_Die();
	
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
	}
	
	for (int i = 0; i < 24; i++)
	{
		f32 width = (i * 2);
		Vec2f p =  Vec2f(pos.x + (XORRandom(width * 2) - width), pos.y - (i * 8));
	
		// if (server && i % 16 == 0) 
		// {
			// if (map.isTileWood(map.getTile(p).type)) map.server_setFireWorldspace(p, true);
		// }
		if (client) makeSteamParticle(this, p, particles[XORRandom(particles.length)]);
	}
	
	if (client) ShakeScreen(128, 32, pos);
	
	this.setPosition(pos + Vec2f(XORRandom(32) - 16, 0));
}

void makeSteamParticle(CBlob@ this, Vec2f pos, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(filename, pos + random, Vec2f(0, 0), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -XORRandom(100) / 400.00f, false);
}