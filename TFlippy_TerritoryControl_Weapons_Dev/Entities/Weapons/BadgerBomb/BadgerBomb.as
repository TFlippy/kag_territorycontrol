#include "Hitters.as";
#include "Explosion.as";

string[] particles =
{
	"SmallSmoke1.png",
	"SmallSmoke2.png",
	"SmallExplosion1.png",
	"SmallExplosion2.png"
};

void onInit(CBlob@ this)
{
	this.set_bool("started",false);
	this.addCommandID("start");
}

void onTick(CSprite@ this)
{

	CBlob@ blob = this.getBlob();
	if(blob !is null && blob.get_bool("started"))
	{
		u16 grenadeTimer = blob.get_u16("grenade timer");
		sparks(blob.getPosition() - (blob.isFacingLeft() ? Vec2f(-12,2) : Vec2f(12,2)), blob.isFacingLeft() ? 90.0f : 270.0f,
		 3.5f + (XORRandom(10) / 5.0f), SColor(255, 255, 110 - (-grenadeTimer), 0));
	}
}

void onTick(CBlob@ this)
{
	if(!this.get_bool("started"))
	{
		if(this.getHealth() < 5.0f)
		{
			this.set_bool("started",true);
			this.SendCommand(this.getCommandID("start"));
		}
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null){return;}
		CBlob@ holder = point.getOccupied();

		if(holder !is null && this !is null)
		{
			if(holder.isKeyPressed(key_action1) || holder.isKeyJustPressed(key_action1))
			{
				
				this.set_bool("started",true);
				this.SendCommand(this.getCommandID("start"));
			}	
		}
		return;
	}

	u16 grenadeTimer = this.get_u16("grenade timer");

	if(grenadeTimer == 0)
	{
		this.server_Die();
	}

	if(grenadeTimer >= 0)
	{
		this.set_u16("grenade timer", grenadeTimer - 1);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("start"))
	{
		this.addCommandID("offblast");

		this.set_f32("map_damage_ratio", 0.3f);
		this.set_f32("map_damage_radius", 62.0f);
		this.set_string("custom_explosion_sound", "Keg.ogg");

		this.set_u16("grenade timer", 120);
		this.Tag("map_damage_dirt");
		this.Tag("projectile");
		this.getSprite().SetEmitSound("Sparkle.ogg");

		this.getSprite().SetEmitSoundPaused(false);
		this.SetLight(true);
		this.SetLightRadius(48.0f);
	}
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum() && blob.isCollidable() ;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (solid)
	{
		this.Tag("grenade collided");
		if (getNet().isClient() && !this.hasTag("dead") && this.getOldVelocity().Length() > 2.0f) this.getSprite().PlaySound("launcher_boing" + XORRandom(2), 0.2f, 1.0f);

		if (blob !is null && doesCollideWithBlob(this, blob) && (blob.hasTag("flesh") || blob.hasTag("vehicle"))) this.server_Die();
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

void DoExplosion(CBlob@ this)
{

	f32 random = XORRandom(10);
	f32 modifier = 3;
	f32 angle = -this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (24.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);

	Explode(this, 35.0f + random, 8.0f);

	for (int i = 0; i < 4 * modifier; i++)
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();

		LinearExplosion(this, dir, 8.0f + XORRandom(8) + (modifier * 8), 8 + XORRandom(24), 2, 0.125f, Hitters::explosion);
	}

	Vec2f pos = this.getPosition();
	CMap@ map = getMap();

	for (int i = 0; i < 35; i++)
	{
		MakeParticle(this, Vec2f( XORRandom(32) - 16, XORRandom(40) - 20), getRandomVelocity(0, XORRandom(300) * 0.01f, 360), particles[XORRandom(particles.length)]);
	}

	this.getSprite().Gib();
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + pos, vel, float(XORRandom(360)), 1.0f + XORRandom(100) * 0.01f, 2 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}

void sparks(Vec2f at, f32 angle, f32 speed, SColor color)
{
	Vec2f vel = getRandomVelocity(angle + 90.0f, speed, 25.0f);
	at.y -= 2.5f;
	ParticlePixel(at, vel, color, true, 119);
}