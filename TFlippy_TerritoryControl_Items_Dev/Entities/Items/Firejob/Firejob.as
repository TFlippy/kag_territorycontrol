#include "Hitters.as";
#include "Explosion.as";
#include "Knocked.as";

string[] particles = 
{
	"SmallExplosion1.png"
	"SmallExplosion2.png",
	"SmallExplosion3.png",
};

const u32 fuel_timer_max = 30 * 1;
const f32 inp_ratio = 0.50f;

void onInit(CBlob@ this)
{
	// this.Tag("aerial");
	this.Tag("explosive");

	this.set_f32("bomb angle", 90);
	this.addCommandID("offblast");

	this.set_f32("map_damage_ratio", 0.5f);
	this.set_f32("map_damage_radius", 96.0f);

	this.Tag("map_damage_dirt");
	this.Tag("map_destroy_ground");
	this.Tag("no explosion particles");

	this.set_string("custom_explosion_sound", "");
	if (!this.exists("split_chance")) this.set_f32("split_chance", 1.00f);

	// this.set_u32("no_explosion_timer", 0);
	// this.set_u32("fuel_timer", 0);
	if (!this.exists("velocity")) this.set_f32("velocity", 0.0f);
	if (!this.exists("direction")) this.set_Vec2f("direction", Vec2f(0, -1));

	this.getShape().SetRotationsAllowed(true);
}

void onTick(CBlob@ this)
{
	if (this.hasTag("offblast"))
	{
		Vec2f dir = Vec2f((XORRandom(200) - 100) / 100.00f, (XORRandom(200) - 100) / 100.00f);
		const f32 ratio = 0.10f;

		Vec2f nDir = (this.get_Vec2f("direction") * (1.00f - ratio)) + (dir * ratio);
		nDir.Normalize();

		this.SetFacingLeft(false);

		this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.1f, 5.0f));
		this.setAngleDegrees(-nDir.getAngleDegrees() + 90);
		this.setVelocity(nDir * this.get_f32("velocity"));
		this.set_Vec2f("direction", nDir);

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point !is null){
			CBlob@ holder = point.getOccupied();

			if (holder !is null)
			{
				holder.setVelocity(nDir * this.get_f32("velocity"));
			}
		}

		if (isServer())
		{
			if (getGameTime() >= this.get_u32("explosion_timer") || this.getPosition().y < 64) 
			{
				this.server_Die();
			}
		}
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return false;
}

const u32[] teamcolours = {0xff0000ff, 0xffff0000, 0xff00ff00, 0xffff00ff, 0xffff6600, 0xff00ffff, 0xff6600ff, 0xff647160};

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

	Explode(this, 100.0f + random, 8.0f);

	for (int i = 0; i < 4 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();

		LinearExplosion(this, dir, 8.0f + XORRandom(16) + (modifier * 8), 8 + XORRandom(24), 3, 0.125f, Hitters::explosion);
	}

	Vec2f pos = this.getPosition();
	CMap@ map = getMap();

	CBlob@[] blobs;
	if (map.getBlobsInRadius(pos, push_radius, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = @blobs[i];
			if (blob !is null && !blob.getShape().isStatic()) 
			{
				Vec2f dir = blob.getPosition() - pos;
				f32 dist = dir.Length();
				dir.Normalize();

				f32 mod = Maths::Sqrt(Maths::Clamp(dist / push_radius, 0, 1));
				blob.AddForce(dir * blob.getRadius() * 75 * mod);
			}
		}
	}

	if (isServer())
	{

		f32 chance = this.get_f32("split_chance");
		if (XORRandom(100) <= (chance * 100))
		{
			for (int i = 0; i < 2; i++)
			{
				CBlob@ blob = @server_CreateBlobNoInit("firejob");
				if (blob is null) { continue; }
				blob.setPosition(this.getPosition() + getRandomVelocity(0, XORRandom(16), 360));
				blob.set_f32("velocity", XORRandom(100) / 50.00f);
				blob.set_Vec2f("direction", getRandomVelocity(0, 1, 360));
				blob.Tag("offblast");
				blob.set_u32("explosion_timer", getGameTime() + 15 + XORRandom(45));
				blob.set_f32("split_chance", chance * 0.25f);
				blob.server_setTeamNum(this.getTeamNum());
				blob.Init();
			}
		}

		for (int i = 0; i < 3; i++)
		{
			CBlob@ blob = @server_CreateBlob("flame", -1, this.getPosition());
			if (blob is null) { continue; }

			blob.setVelocity(getRandomVelocity(0, XORRandom(8), 360));
			blob.server_SetTimeToDie(3 + XORRandom(5));
		}
	}

	if (isClient())
	{
		CBlob@ local = getLocalPlayerBlob();
		if (local !is null)
		{
			f32 dmod = 1.00f - ((local.getPosition() - pos).getLength() / 500.00f);
			Sound::Play("Firejob_Boom.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), 2.0f - (0.2f * (1 - dmod)), 0.50f + dmod);
		}
	}

	this.Tag("dead");
	this.getSprite().Gib();
}

const f32 push_radius = 175.00f;

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(0, 16).RotateBy(this.getAngleDegrees());
	ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer() && this.getOldVelocity().y < -6 && this.hasTag("offblast") && blob is null && solid) this.server_Die();
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!this.hasTag("offblast"))
	{
		if (this.isOverlapping(caller) || this.isAttachedTo(caller))
		{
			CBitStream params;
			caller.CreateGenericButton(11, Vec2f(0.0f, 0.0f), this, this.getCommandID("offblast"), "Off blast!", params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("offblast"))
	{
		if (this.hasTag("offblast")) return;

		// this.setPosition(this.getPosition() + Vec2f(0, -32)); // Hack
		this.setAngleDegrees(0);
		Vec2f pos = this.getPosition();

		this.Tag("projectile");
		this.Tag("offblast");
		this.set_u32("explosion_timer", getGameTime() + 90 + XORRandom(15));
		// this.set_u32("fuel_timer", getGameTime() + fuel_timer_max);

		CSprite@ sprite = this.getSprite();
		// sprite.SetEmitSound("Rocket_Idle.ogg");
		// sprite.SetEmitSoundSpeed(1.9f);
		// sprite.SetEmitSoundVolume(0.2f);
		// sprite.SetEmitSoundPaused(false);
		sprite.PlaySound("Rocket_Idle.ogg", 1.00f, 1.80f);

		this.SetLight(true);
		this.SetLightRadius(128.0f);
		this.SetLightColor(SColor(255, 255, 100, 0));
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("offblast");
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return !this.hasTag("offblast");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.hasTag("offblast"))
	{
		damage = 0;
	}

	return damage;
}
