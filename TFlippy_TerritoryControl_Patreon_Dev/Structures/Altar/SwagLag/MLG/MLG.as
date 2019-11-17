#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";
#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};


Vec2f raycast_offset = Vec2f(0.0f, -2.0f);
const f32 radius = 32.00f;

void onInit(CBlob@ this)
{
	GunInitRaycast
	(
		this,
		false,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		4.00f,				//Weapon damage / projectile blob name
		1000.0f,			//Weapon raycast range
		5,					//Weapon fire delay, in ticks
		3,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		15,					//Weapon reload time
		true,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		1,					// Bullet count - for shotguns
		0.0f,				// Bullet Jitter
		"mat_rifleammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("MLG_Shoot", 1, 1.0f, 1.0f),	//Sound to play when firing
		SoundInfo("LeverRifle_Load", 1, 1.0f, 0.8f),//Sound to play when reloading
		SoundInfo(),							//Sound to play some time after firing
		0,					//Delay for the delayed sound, in ticks
		raycast_offset	//Visual offset for raycast bullets
	);

	this.set_u8("gun_hitter", HittersTC::bullet_high_cal);
	this.set_f32("scope_zoom", 0.35f);
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		GunTick(this);
		
		// Shitcode ahead
		CControls@ controls = getControls();
		Driver@ driver = getDriver();
		
		Vec2f wpos = controls.getMouseWorldPos();
		const u8 team = this.getTeamNum();
		
		f32 dist = 1337.00f;
		u16 closest_id = 0;
		
		CBlob@[] blobs;
		if (this.getMap().getBlobsInRadius(wpos, radius, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];
				f32 d = (b.getPosition() - wpos).getLength();
				
				if (d < dist && b.getTeamNum() != team && b.isCollidable() && (b.hasTag("flesh") || b.hasTag("npc") || b.hasTag("vehicle") || b.hasTag("explosive") || b.hasTag("projectile")) && !b.hasTag("invincible") && !b.hasTag("dead"))
				{
					closest_id = b.getNetworkID();
					dist = d;
				}
			}
				
			if (closest_id > 0)
			{
				CBlob@ blob = getBlobByNetworkID(closest_id);
				if (blob !is null)
				{
					Vec2f bpos = blob.getPosition();
					Vec2f dir = (bpos - this.getPosition());
				
					f32 factor = dist / radius;
				
					AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
					if(point !is null)
					{
						CBlob@ holder = point.getOccupied();
						if (holder !is null)
						{
							CPlayer@ ply = holder.getPlayer();
							if (ply !is null && ply.isMyPlayer())
							{
								Vec2f spos = driver.getScreenPosFromWorldPos(bpos);
								Vec2f sdir = (controls.getMouseScreenPos() - spos);
							
								controls.setMousePosition(controls.getMouseScreenPos() - (sdir * 0.75f));
							}
						}
					}
				}
			}
		}
		this.set_u16("mlg_target", closest_id);
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point !is null)
	{
		CBlob@ holder = point.getOccupied();
		if (holder !is null)
		{
			if (holder is getLocalPlayerBlob())
			{
				Sound::Play("MLG_Hit");
				
				CParticle@ particle = ParticleAnimated("HitMarker", worldPoint, Vec2f((100 - XORRandom(200)) * 0.03f, -4), 0, 0.50f, 60, 0.40f, false);
				if (particle !is null)
				{
					particle.growth = -0.01f;
				}
			}
			
			if (holder.get_f32("dew_effect") > 0)
			{
				ShakeScreen(200.0f, 20.0f, hitBlob.getPosition());
				hitBlob.getSprite().PlaySound("bombita_explode", 2.00f, 1.00f);
				DoExplosion(hitBlob);
			}
		}
	}
}

void DoExplosion(CBlob@ this)
{
	f32 random = XORRandom(16);
	f32 modifier = 1;
	f32 angle = -this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (16.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.10f);
	
	Explode(this, 16.0f + random, 2.0f);
	
	for (int i = 0; i < 4 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();
		
		LinearExplosion(this, dir, 1.0f + XORRandom(8) + (modifier * 4), 4 + XORRandom(12), 2, 0.10f, Hitters::explosion);
	}
	
	if(isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		for (int i = 0; i < 8; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(32) - 16, XORRandom(40) - 30), getRandomVelocity(-angle, XORRandom(120) * 0.01f, 90), particles[XORRandom(particles.length)]);
		}
		
		this.Tag("exploded");
		this.getSprite().Gib();
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}

bool isVisible(CBlob@ blob, CBlob@ target)
{
	Vec2f col;
	return !getMap().rayCastSolidNoBlobs(blob.getPosition(), target.getPosition(), col);
}
