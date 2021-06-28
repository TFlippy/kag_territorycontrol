#include "Hitters.as";
#include "Explosion.as";
#include "GunCommon.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

const f32 radius = 32.00f;

void onInit(CBlob@ this)
{
	GunSettings settings = GunSettings();

	//General
	//settings.CLIP = 0; //Amount of ammunition in the gun at creation
	settings.TOTAL = 3; //Max amount of ammo that can be in a clip
	settings.FIRE_INTERVAL = 5; //Time in between shots
	settings.RELOAD_TIME = 15; //Time it takes to reload (in ticks)
	settings.AMMO_BLOB = "mat_rifleammo"; //Ammunition the gun takes

	//Bullet
	settings.B_PER_SHOT = 4; //Shots per bullet | CHANGE B_SPREAD, otherwise both bullets will come out together
	settings.B_SPREAD = 1; //the higher the value, the more 'uncontrollable' bullets get
	settings.B_GRAV = Vec2f(0, 0.001); //Bullet gravity drop
	settings.B_SPEED = 80; //Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
	settings.B_TTL = 15; //TTL = 'Time To Live' which determines the time the bullet lasts before despawning
	settings.B_DAMAGE = 3.0f; //1 is 1 heart
	settings.B_TYPE = HittersTC::bullet_high_cal; //Type of bullet the gun shoots | hitter

	//Recoil
	settings.G_RECOIL = -17; //0 is default, adds recoil aiming up
	settings.G_RANDOMX = true; //Should we randomly move x
	settings.G_RANDOMY = false; //Should we randomly move y, it ignores g_recoil
	settings.G_RECOILT = 7; //How long should recoil last, 10 is default, 30 = 1 second (like ticks)
	settings.G_BACK_T = 1; //Should we recoil the arm back time? (aim goes up, then back down with this, if > 0, how long should it last)

	//Sound
	settings.FIRE_SOUND = "MLG_Shoot.ogg"; //Sound when shooting
	settings.RELOAD_SOUND = "LeverRifle_Load.ogg"; //Sound when reloading

	//Offset
	settings.MUZZLE_OFFSET = Vec2f(-22, -2); //Where the muzzle flash appears

	this.set("gun_settings", @settings);

	//Custom
	this.Tag("CustomShotgunReload");
	this.Tag("CustomSemiAuto");
	this.set_f32("scope_zoom", 0.35f);
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
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
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}

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

	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();

		for (int i = 0; i < 8; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(32) - 16, XORRandom(40) - 30), getRandomVelocity(-angle, XORRandom(120) * 0.01f, 90), particles[XORRandom(particles.length)]);
		}

		this.Tag("exploded");
		//this.getSprite().Gib();
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
