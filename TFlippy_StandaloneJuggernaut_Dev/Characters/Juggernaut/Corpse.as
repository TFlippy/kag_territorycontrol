#include "Hitters.as";
#include "HittersTC.as";
#include "RunnerCommon.as";
#include "Knocked.as"

void onInit(CBlob@ this)
{
	this.Tag("medium weight");

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null)
	{
		if (solid || blob.hasTag("vehicle") || (solid || blob.hasTag("flesh")) && blob.getTeamNum() == this.getTeamNum())
		{
			Vec2f hitvel = this.getOldVelocity();
			f32 vellen = hitvel.Length();

			if (this.hasTag("dead")) return;

			//get the dmg required
			hitvel.Normalize();

			//hurt
			if (isServer())
			{
				blob.AddForce(hitvel * 400.0f);
				this.server_Hit(blob, point1, hitvel, 3.0f, Hitters::fall, true);
				SetKnocked(blob, 90);
				KillThis(this, point1);
			}
		}
	}
	else KillThis(this, point1);
}

void KillThis(CBlob@ this,Vec2f worldPoint)
{
	if (isServer())
	{
		CPlayer@ player = this.getPlayer();
		if (player !is null)
		{
			CPlayer@ owner = this.getDamageOwnerPlayer();
			if (owner !is null) getRules().server_PlayerDie(player, owner, Hitters::crush);
		}

		this.server_Die();
	}
}

void onDie(CBlob@ this)
{
	this.getShape().SetVelocity(Vec2f(0.0f, -1.5f));
	if (isClient())
	{
		for (int i = 0; i < 5; i++)
		{
			Vec2f pos = Vec2f(XORRandom(16) - 8, XORRandom(16) - 8);
			if (pos.Length() >= 8.0f)
			{
				pos.Normalize();
				pos *= 8.0f;
			}
			ParticleBloodSplat(this.getPosition() + pos, true);
		}
		for (int i = 0; i < 16; i++)
		{
			Vec2f pos = Vec2f(XORRandom(40) - 20, XORRandom(40) - 20);
			if (pos.Length() >= 20.0f)
			{
				pos.Normalize();
				pos *= 20.0f;
			}
			ParticleBloodSplat(this.getPosition() + pos, false);
		}

		this.getSprite().Gib();
		Sound::Play("Gore.ogg", this.getPosition(), 1.0f);
	}
}

void onTick(CBlob@ this)
{
	//no movement
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor = 0.0f;
		moveVars.jumpFactor = 0.0f;
	}

	//stuck fix
	if (this.getVelocity() == Vec2f_zero) KillThis(this, this.getPosition());
	else
	{
		CSprite@ sprite = this.getSprite();
		if (sprite !is null) sprite.SetFacingLeft(this.getVelocity().x < 0.0f);

		//spin
		Vec2f vel = this.getVelocity();
		f32 angle = this.getAngleRadians() + (vel.x < 0.0f ? -1.0f : 1.0f) * 0.4f;
		this.setAngleRadians(angle);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (this.isAttached()) Reset(this);
}

void Reset(CBlob@ this)
{
	//Set back to normal
	this.getSprite().SetRelativeZ(this.getSprite().getRelativeZ() + 5);
	this.setAngleRadians(0.0f);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
