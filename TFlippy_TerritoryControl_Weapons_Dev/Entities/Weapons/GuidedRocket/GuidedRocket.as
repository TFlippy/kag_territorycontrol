#include "Hitters.as";
#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

const u32 fuel_timer_max = 30 * 8;
const f32 inp_ratio = 0.50f;

void onInit(CBlob@ this)
{
	this.set_f32("bomb angle", 90);
	this.addCommandID("offblast");

	this.set_f32("map_damage_ratio", 0.5f);
	this.set_f32("map_damage_radius", 48.0f);
	this.Tag("map_damage_dirt");
	this.set_string("custom_explosion_sound", "Missile_Explode.ogg");
	this.Tag("medium weight");

	this.set_u32("no_explosion_timer", 0);
	this.set_u32("fuel_timer", 0);
	this.set_f32("velocity", 10.0f);
	this.set_Vec2f("direction", Vec2f(0, -1));

	this.getShape().SetRotationsAllowed(true);
}

void onTick(CBlob@ this)
{
	if (this.hasTag("offblast"))
	{
		Vec2f dir;

		if (this.get_u32("fuel_timer") > getGameTime())
		{
			// Not as hardcore shitcode anymore, but still shitcode
			if (this.get_f32("velocity") > 12)
			{
				CBlob@[] blobs;
				getBlobsByTag("aerial", @blobs);

				f32 distance = 90000.0f;
				u32 index = 0;

				const Vec2f mypos = this.getPosition();
				Vec2f target;

				if (blobs.length > 0)
				{
					for (int i = 0; i < blobs.length; i++)
					{
						if (blobs[i].getTeamNum() == this.getTeamNum() || blobs[i] is this) continue;

						f32 bdist = (blobs[i].getPosition() - mypos).Length();

						if (bdist < distance)
						{
							distance = bdist;
							index = i;
						}
					}

					target = blobs[index].getPosition();

					dir = (target - mypos);
					dir.Normalize();
				}
				else
				{
					dir = Vec2f(0, -1);
				}

				if (isServer())
				{
					if (distance < 8) this.server_Die();
				}
			}
			else
			{
				dir = Vec2f(0, -1);
			}

			const f32 ratio = 0.25f;

			// Vec2f nDir = (this.get_Vec2f("direction") * (1.00f - inp_ratio)) + (dir * inp_ratio);
			Vec2f nDir = (this.get_Vec2f("direction") * (1.00f - ratio)) + (dir * ratio);
			nDir.Normalize();

			this.SetFacingLeft(false);

			this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.2f, 15.0f));
			this.setAngleDegrees(-nDir.getAngleDegrees() + 90);
			this.setVelocity(nDir * this.get_f32("velocity"));

			this.set_Vec2f("direction", nDir);

			if(isClient())
			{
				MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
			}
		}
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return blob.getTeamNum() != this.getTeamNum(); // && blob.isCollidable();
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}

	if (this.hasTag("dead")) return;

	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (40.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);

	Explode(this, 40.0f + random, 16.0f);

	for (int i = 0; i < 4 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();

		LinearExplosion(this, dir, 8.0f + XORRandom(16) + (modifier * 8), 8 + XORRandom(24), 3, 0.125f, Hitters::explosion);
	}

	if(isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();

		for (int i = 0; i < 35; i++)
		{
			MakeExplosionParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(220) * 0.01f, 90), particles[XORRandom(particles.length)]);
		}

		this.Tag("dead");
		this.getSprite().Gib();
	}
}

void MakeExplosionParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(8), 0, true);
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(0, 16).RotateBy(this.getAngleDegrees());
	ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onDie(CBlob@ this)
{
	// if (this.hasTag("offblast")) DoExplosion(this, Vec2f(0, 0));
	DoExplosion(this);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	// if ((blob !is null ? !blob.isCollidable() : !solid)) return;

	if (isServer() && this.hasTag("offblast") && this.get_u32("no_explosion_timer") < getGameTime()) this.server_Die();
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.hasTag("offblast")) return;

	if (caller.isAttached() ? caller.isAttachedToPoint("PILOT") || caller.isAttachedToPoint("FLYER") : true)
	{
		CBitStream params;
		caller.CreateGenericButton(11, Vec2f(0.0f, 0.0f), this, this.getCommandID("offblast"), "Off blast!", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("offblast"))
	{
		if (this.hasTag("offblast")) return;

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point !is null && point.getOccupied() !is null)
		{
			this.server_DetachFromAll();
		}

		// this.setPosition(this.getPosition() + Vec2f(0, -32)); // Hack
		this.setAngleDegrees(0);
		Vec2f pos = this.getPosition();

		this.Tag("offblast");
		this.Tag("aerial");
		this.Tag("projectile");
		this.set_u32("no_explosion_timer", getGameTime() + 30);
		this.set_u32("fuel_timer", getGameTime() + fuel_timer_max);

		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSound("Rocket_Idle.ogg");
			sprite.SetEmitSoundSpeed(1.9f);
			sprite.SetEmitSoundVolume(0.2f);
			sprite.SetEmitSoundPaused(false);
			sprite.PlaySound("Missile_Launch.ogg", 1.00f, 1.00f);

			this.SetLight(true);
			this.SetLightRadius(128.0f);
			this.SetLightColor(SColor(255, 255, 100, 0));
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("offblast");
}
