// Princess brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";
#include "MaterialCommon.as";
#include "Requirements.as";
#include "MakeDustParticle.as";

void onInit( CBrain@ this )
{
	if (isServer())
	{
		InitBrain( this );
		this.server_SetActive( true ); // always running
	}
}

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -10.0f);

	this.set_u32("nextAttack", 0);

	this.set_f32("minDistance", 8);
	this.set_f32("chaseDistance", 300);
	this.set_f32("maxDistance", 600);

	this.set_f32("inaccuracy", 0.01f);
	this.set_u8("reactionTime", 20);
	this.set_u8("attackDelay", 0);

	this.SetDamageOwnerPlayer(null);

	this.Tag("can open door");
	// this.Tag("npc");
	// infinite ammo
	this.Tag("player");
	this.Tag("flesh");
	this.Tag("dangerous");
	this.Tag("map_damage_dirt");

	this.set_f32("map_damage_ratio", 0.3f);
	this.set_f32("map_damage_radius", 32.0f);
	this.set_bool("map_damage_raycast", true);

	this.SetLight(true);
	this.SetLightRadius(16.0f);
	this.SetLightColor(SColor(255, 25, 255, 100));

	this.set_f32("voice pitch", 0.40f);

	this.server_setTeamNum(230);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			this.getSprite().PlaySound("Cuck_Idle_" + XORRandom(4) + ".ogg", 0.7f, 0.5f);
			this.set_u32("next sound", getGameTime() + 350);
		}
	}

	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 0.90f;
		moveVars.jumpFactor *= 1.50f;
	}

	if (this.isKeyPressed(key_action1) && getGameTime() > this.get_u32("next attack"))
	{
		Vec2f dir = this.getAimPos() - this.getPosition();
		dir.Normalize();

		MegaHit(this, this.getPosition() + Vec2f(this.isFacingLeft() ? -16 : 16, XORRandom(16) - 8), dir, 4, Hitters::crush);
		this.set_u32("next attack", getGameTime() + 30);
	}
}

void onDie(CBlob@ this)
{
	this.getSprite().Gib();

	Explode(this, 16.0f, 8.0f);

	if (!isServer()) return;

	for (int i = 0; i < 8; i++)
	{
		CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());

		if (blob !is null)
		{
			blob.server_SetQuantity(10 + XORRandom(40));
			blob.setVelocity(Vec2f(XORRandom(4) - 2, -2 - XORRandom(4)));
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case HittersTC::radiation:
			return 0;
			break;
	}

	if (!this.hasTag("dead"))
	{
		if (isClient())
		{
			if (getGameTime() > this.get_u32("next sound") - 130)
			{
				this.getSprite().PlaySound("Cuck_Pain_" + XORRandom(3) + ".ogg", 1, 0.8f);
				this.set_u32("next sound", getGameTime() + 150);
			}
		}

		if (isServer())
		{
			CBrain@ brain = this.getBrain();

			if (brain !is null && hitterBlob !is null)
			{
				if (hitterBlob.getTeamNum() != this.getTeamNum()) brain.SetTarget(hitterBlob);
			}
		}
	}

	return damage;
}

void MegaHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	bool client = isClient();
	bool server = isServer();

	Vec2f dir = worldPoint - this.getPosition();
	f32 len = dir.getLength();
	dir.Normalize();
	f32 angle = dir.Angle();

	int count = 10.00f;

	for (int i = 0; i < count; i++)
	{
		Vec2f pos = worldPoint + getRandomVelocity(0, XORRandom(24), 90);

		if (client && XORRandom(100) < 50)
		{
			MakeDustParticle(pos, "dust2.png");
		}

		if (server)
		{
			 getMap().server_DestroyTile(pos, damage);
			// this.server_HitMap(pos, dir, damage, Hitters::crush);
		}
	}

	if (client)
	{
		f32 magnitude = damage;
		this.getSprite().PlaySound("FallBig" + (XORRandom(5) + 1), 1.00f, 1.00f);
		ShakeScreen(magnitude * 10.0f, magnitude * 8.0f, this.getPosition());
	}

	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(worldPoint + (dir * Maths::Min(len, 24)), 24, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ hitBlob = blobsInRadius[i];
			if (hitBlob !is null && hitBlob !is this)
			{
				if (server) this.server_Hit(hitBlob, worldPoint, velocity, 0.50f, customData, true);
				if (client) this.getSprite().PlaySound("nightstick_hit" + (1 + XORRandom(3)) + ".ogg", 0.9f, 0.65f);

				f32 mass = hitBlob.getMass();
				hitBlob.AddForce(dir * Maths::Min(400.0f, mass * 5.00f));
			}
		}
	}
}
