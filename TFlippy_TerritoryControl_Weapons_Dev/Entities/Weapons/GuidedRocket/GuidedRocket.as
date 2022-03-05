#include "Hitters.as";
#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

const u32 fuel_timer_max = 30 * 4;
const f32 inp_ratio = 0.50f;

void onInit(CBlob@ this)
{
	this.set_f32("bomb angle", 90);
	this.addCommandID("offblast");

	this.set_f32("map_damage_ratio", 1.0f);
	this.set_f32("map_damage_radius", 48.0f);
	this.Tag("map_damage_dirt");
	this.set_string("custom_explosion_sound", "Missile_Explode.ogg");
	this.Tag("medium weight");

	this.set_u32("no_explosion_timer", 0);
	this.set_u32("fuel_timer", 0);
	this.set_f32("max_velocity", 10.0f);
	this.set_u16("controller_blob_netid", 0);
	this.set_u16("controller_player_netid", 0);


	this.getShape().SetRotationsAllowed(true);
}

void onTick(CBlob@ this)
{
	if (this.hasTag("offblast"))
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point !is null && point.getOccupied() !is null)
		{
			this.server_DetachFromAll();
		}

		Vec2f dir;

		if (this.get_u32("fuel_timer") > getGameTime())
		{
			CPlayer@ controller = this.getPlayer();
			this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.3f, this.get_f32("max_velocity")));

			CBlob@ blob = getBlobByNetworkID(this.get_u16("controller_blob_netid"));
			bool isControlled = blob !is null && !blob.hasTag("dead");

			if (!isControlled || controller is null || this.get_f32("velocity") < this.get_f32("max_velocity") * 0.75f)
			{
				dir = Vec2f(0, 1);
				dir.RotateBy(this.getAngleDegrees());
			}
			else
			{
				dir = (this.getPosition() - this.getAimPos());
				dir.Normalize();
			}

			// print(this.getAimPos().x + " " + this.getAimPos().y);

			const f32 ratio = 0.20f;

			Vec2f nDir = (this.get_Vec2f("direction") * (1.00f - ratio)) + (dir * ratio);
			nDir.Normalize();

			//this.SetFacingLeft(false); //causes bugs with sprite for some odd reason

			this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.75f, 15.0f));
			this.set_Vec2f("direction", nDir);

			this.setAngleDegrees(-nDir.getAngleDegrees() + 90 + 180);
			this.setVelocity(-nDir * this.get_f32("velocity"));

			MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
		}
		else
		{
			this.setAngleDegrees(-this.getVelocity().Angle() + 90);
			//this.getSprite().SetEmitSoundPaused(true);

			if(isClient())
			{
				CSprite@ sprite = this.getSprite();
				f32 modifier = Maths::Max(0, this.getVelocity().y * 0.04f);
				sprite.SetEmitSound("Shell_Whistle.ogg");
				sprite.SetEmitSoundPaused(false);
				sprite.SetEmitSoundVolume(Maths::Max(0, modifier));
			}
		}

		if (this.isKeyJustPressed(key_action1) || this.getHealth() <= 0.0f)
		{
			if (isServer())
			{
				ResetPlayer(this);
				this.server_Die();
				return;
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
	this.set_f32("map_damage_ratio", 1.0f);

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
	if (isServer())
	{
		if ((blob !is null ? !blob.isCollidable() : !solid)) return;
		if (this.hasTag("offblast") && this.get_u32("no_explosion_timer") < getGameTime()) 
		{
			ResetPlayer(this);
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
	if (point is null) return true;

	CBlob@ controller = point.getOccupied();
	if (controller is null) return true;
	else return false;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.hasTag("offblast")) return;

	CPlayer@ ply = caller.getPlayer();
	if (ply !is null)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(ply.getNetworkID());

		caller.CreateGenericButton(11, Vec2f(0.0f, -5.0f), this, this.getCommandID("offblast"), "Off blast!", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("offblast"))
	{
		const u16 caller_netid = params.read_u16();
		const u16 player_netid = params.read_u16();

		CPlayer@ caller = getPlayerByNetworkId(caller_netid);
		CPlayer@ ply = getPlayerByNetworkId(player_netid);

		if (this.hasTag("offblast")) return;

		this.Tag("aerial");
		this.Tag("projectile");
		this.Tag("offblast");

		this.set_u32("no_explosion_timer", getGameTime() + 10);
		this.set_u32("fuel_timer", getGameTime() + fuel_timer_max);

		this.set_u16("controller_blob_netid", caller_netid);
		this.set_u16("controller_player_netid", player_netid);

		if (isServer() && ply !is null)
		{
			this.server_SetPlayer(ply);
		}

		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSound("Rocket_Idle.ogg");
			sprite.SetEmitSoundSpeed(1.0f);
			sprite.SetEmitSoundVolume(0.3f);
			sprite.SetEmitSoundPaused(false);
			sprite.PlaySound("Missile_Launch.ogg", 2.00f, 1.00f);

			this.SetLight(true);
			this.SetLightRadius(128.0f);
			this.SetLightColor(SColor(255, 255, 100, 0));
		}
	}
}

void ResetPlayer(CBlob@ this)
{
	if (isServer())
	{
		CPlayer@ ply = getPlayerByNetworkId(this.get_u16("controller_player_netid"));
		CBlob@ blob = getBlobByNetworkID(this.get_u16("controller_blob_netid"));
		if (blob !is null && ply !is null && !blob.hasTag("dead"))
		{
			blob.server_SetPlayer(ply);
		}

		this.server_Die();
	}
}
