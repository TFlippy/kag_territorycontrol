// Princess brain

#include "Hitters.as";
#include "HittersTC.as";
#include "Knocked.as";
#include "VehicleAttachmentCommon.as"

const f32 radius = 128.0f;
const f32 damage = 5.00f;
const u32 delay = 90;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.Tag("heavy weight");

	this.set_f32("pickup_priority", 16.00f);
	this.getShape().SetRotationsAllowed(false);

	this.getCurrentScript().tickFrequency = 5;
	// this.getCurrentScript().runFlags |= Script::tick_not_ininventory;

	this.set_u16("target", 0);
	this.set_f32("burn_time", 0);

	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 0, 0));

	if (isServer())
	{
		if (this.getTeamNum() == 250)
		{
			CBlob@ ammo = server_CreateBlob("mat_battery", this.getTeamNum(), this.getPosition());
			ammo.server_SetQuantity(200);
			this.server_PutInInventory(ammo);
		}
	}
}

void onInit(CSprite@ this)
{
	// this.SetEmitSound("Zapper_Loop.ogg");
	// this.SetEmitSoundVolume(0.0f);
	// this.SetEmitSoundSpeed(0.0f);
	// this.SetEmitSoundPaused(false);

	this.SetZ(20);

	CSpriteLayer@ head = this.addSpriteLayer("head", "LWS_Launcher.png", 32, 16);
	if (head !is null)
	{
		head.SetRelativeZ(1.0f);
		head.SetOffset(headOffset);
		head.SetVisible(true);
	}

	CSpriteLayer@ laser = this.addSpriteLayer("laser", "LWS_Laser.png", 4, 4);
	if (laser !is null)
	{
		// laser.SetRelativeZ(-1.0f);
		laser.SetVisible(false);
		laser.setRenderStyle(RenderStyle::additive);
		laser.SetRelativeZ(-250.0f);
		laser.SetOffset(headOffset);
		// laser.SetOffset(Vec2f(-18.0f, 1.5f));
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getTeamNum() == this.getTeamNum() && GetAmmo(this) == 0;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if (this.getTeamNum() != forBlob.getTeamNum()) return false;

	CBlob@ carried = forBlob.getCarriedBlob();
	return (carried is null ? true : carried.getName() == "mat_battery");
}

u8 GetAmmo(CBlob@ this)
{
	if (this.getTeamNum() == 250) return 50;

	CInventory@ inv = this.getInventory();
	if (inv != null)
	{
		if (inv.getItem(0) != null) return inv.getItem(0).getQuantity();
	}

	return 0;
}

void SetAmmo(CBlob@ this, u8 amount)
{
	if (this.getTeamNum() == 250) return;

	CInventory@ inv = this.getInventory();
	if (inv != null)
	{
		if (inv.getItem(0) != null) inv.getItem(0).server_SetQuantity(amount);
	}
}

const Vec2f headOffset = Vec2f(0, -8);

void onTick(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ attachedBlob = point.getOccupied();

	if (attachedBlob !is null && !attachedBlob.hasTag("vehicle")) return;

	CBlob@[] blobs;
	getBlobsByTag("aerial", @blobs);
	getBlobsByTag("projectile", @blobs);

	Vec2f pos = this.getPosition();
	CMap@ map = getMap();

	int index = -1;
	f32 s_dist = 900000.00f;
	u8 myTeam = this.getTeamNum();

	for (int i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];
		u8 team = b.getTeamNum();

		f32 dist = (b.getPosition() - this.getPosition()).LengthSquared();

		if (team != myTeam && (dist < 900*900) && dist < s_dist && (b.getHealth() < 5.00f || b.hasTag("wooden")))
		{
			s_dist = dist;
			index = i;
		}
	}

	if (index != -1)
	{
		CBlob@ target = blobs[index];

		if (target !is null)
		{
			if (target.getNetworkID() != this.get_u16("target"))
			{
				this.getSprite().PlaySound("LWS_Found.ogg", 1.00f, 1.00f);
				this.set_u32("next_launch", getGameTime() + 30);
			}

			this.set_u16("target", target.getNetworkID());
		}
	}

	bool fired = false;

	int ammo = GetAmmo(this);
	this.SetLight(ammo > 0);

	CBlob@ t = getBlobByNetworkID(this.get_u16("target"));
	if (t !is null && isVisible(this, t))
	{
		this.SetFacingLeft((t.getPosition().x - this.getPosition().x) < 0);

		if (ammo > 0)
		{
			fired = true;
			f32 burn_time = this.get_f32("burn_time") + 1;
			this.set_f32("burn_time", burn_time);

			if (isServer())
			{
				this.server_Hit(t, t.getPosition(), Vec2f(0, 0), 0.03f * burn_time * (t.hasTag("explosive") ? 20.00f : 1.00f), Hitters::fire, true);

				SetAmmo(this, ammo - 2);
			}

			if (isClient())
			{
				ParticleAnimated("LargeSmoke", t.getPosition(), Vec2f(), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
			}
		}
	}

	if (isClient())
	{
		CSpriteLayer@ laser = this.getSprite().getSpriteLayer("laser");
		if (laser !is null)
		{
			laser.SetVisible(fired);
		}
	}

	if (fired)
	{

	}
	else
	{
		this.set_f32("burn_time", 0);
	}
}

bool isVisible(CBlob@ blob, CBlob@ target)
{
	Vec2f col;
	return !getMap().rayCastSolidNoBlobs(blob.getPosition(), target.getPosition(), col);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (isClient())
	{
		CBlob@ target = getBlobByNetworkID(blob.get_u16("target"));
		if (target !is null)
		{
			AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
			CBlob@ attachedBlob = point.getOccupied();

			if (attachedBlob !is null && !attachedBlob.hasTag("vehicle")) return;

			const bool facingLeft = (target.getPosition().x - blob.getPosition().x) > 0;

			Vec2f dir = target.getPosition() - blob.getPosition();
			f32 length = dir.getLength();
			dir.Normalize();
			f32 angle = dir.Angle();

			CSpriteLayer@ head = this.getSpriteLayer("head");
			if (head !is null)
			{
				head.ResetTransform();
				head.SetFacingLeft(!facingLeft);
				head.RotateBy(-dir.Angle() + (this.isFacingLeft() ? 180 : 0), Vec2f());
			}

			CSpriteLayer@ laser = this.getSpriteLayer("laser");
			if (laser !is null)
			{
				laser.ResetTransform();
				laser.ScaleBy(Vec2f((length / 4.0f), 1.0f));
				laser.TranslateBy(Vec2f((length / 2), 0));
				laser.RotateBy(-angle, Vec2f());
				// laser.SetVisible(true);
				// laser.SetRelativeZ(-250.0f);
				// laser.SetOffset(headOffset);
			}
		}
		else
		{
			CSpriteLayer@ head = this.getSpriteLayer("head");
			if (head !is null)
			{
				head.ResetTransform();
				head.SetFacingLeft(blob.isFacingLeft());
				//head.RotateBy((Maths::Sin(blob.getTickSinceCreated() * 0.05f) * 20), Vec2f());
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("security_set_state"))
	{
		bool state = params.read_bool();

		CSpriteLayer@ head = this.getSprite().getSpriteLayer("head");
		if (head !is null)
		{
			head.SetFrameIndex(state ? 0 : 1);
		}

		this.getSprite().PlaySound(state ? "Security_TurnOn" : "Security_TurnOff", 0.30f, 1.00f);
		this.set_bool("security_state", state);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}
