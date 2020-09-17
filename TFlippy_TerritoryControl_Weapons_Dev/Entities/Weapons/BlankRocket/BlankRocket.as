#include "Hitters.as";
#include "Explosion.as";
#include "Knocked.as";

const u32 fuel_timer_max = 30 * 0.50f;

void onInit(CBlob@ this)
{
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_f32("map_damage_radius", 32.0f);
	this.set_string("custom_explosion_sound", "Keg.ogg");
		
	this.set_u32("fuel_timer", 0);
	this.set_f32("velocity", 10.0f);
	
	this.getShape().SetRotationsAllowed(true);
	
	this.set_u32("fuel_timer", getGameTime() + fuel_timer_max + XORRandom(15));
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Rocket_Idle.ogg");
	sprite.SetEmitSoundSpeed(2.0f);
	sprite.SetEmitSoundPaused(false);
	
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 100, 0));
}

void onTick(CBlob@ this)
{
	if (this.get_u32("fuel_timer") > getGameTime())
	{
		this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.15f, 15.0f));
		
		Vec2f dir = Vec2f(0, 1);
		dir.RotateBy(this.getAngleDegrees());
					
		this.setVelocity(dir * -this.get_f32("velocity") + Vec2f(0, this.getTickSinceCreated() > 5 ? XORRandom(50) / 100.0f : 0));
		
		if(isClient())
		{
			MakeParticle(this, -dir, "Smoke" );
		}
		
		
		this.setAngleDegrees(-this.getVelocity().Angle() + 90);
	}
	else
	{
		this.setAngleDegrees(-this.getVelocity().Angle() + 90);
		this.getSprite().SetEmitSoundPaused(true);
	}		
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(0, 4).RotateBy(this.getAngleDegrees());
	ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void DoExplosion(CBlob@ this, Vec2f velocity)
{
	if (this.hasTag("dead")) return;
	this.Tag("dead");

	this.server_Die();
	this.getSprite().Gib();

	CPlayer@ p = this.getDamageOwnerPlayer();
	if (p is null) { return; }

	CBlob@ blob = p.getBlob();
	if (blob is null) { return; }

	Vec2f dir = blob.getPosition() - this.getPosition();
	f32 dist = dir.Length();

	if (dist > 50) { return; }

	dir.Normalize();
	
	f32 mod = Maths::Clamp(1.00f - (dist / 192.00f), 0, 1);
	f32 force = Maths::Clamp(blob.getRadius() * 70 * mod * 3, 0, blob.getMass() * 50);
	
	blob.AddForce(dir * (force / 2));
	//SetKnocked(blob, 150 * mod);


}

void onDie(CBlob@ this)
{
	DoExplosion(this, Vec2f(0, 0));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTickSinceCreated() > 5 && this.getTeamNum() != blob.getTeamNum() && blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (this.getTickSinceCreated() > 10 && (solid ? true : (blob !is null && blob.isCollidable())))
		{
			this.server_Die();
		}
	}
}

// void GetButtonsFor(CBlob@ this, CBlob@ caller)
// {
	// AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	// if (point is null) return;

	// if (point.getOccupied() is null)
	// {
		// CBitStream params;
		// caller.CreateGenericButton(11, Vec2f(0.0f, 0.0f), this, this.getCommandID("offblast"), "Off blast!", params);
	// }
// }

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
	// AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
	// if (point is null) return true;
		
	// CBlob@ holder = point.getOccupied();
	// if (holder is null) return true;
	// else return false;
}