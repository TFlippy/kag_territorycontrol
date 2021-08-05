#include "VehicleCommon.as"
#include "Hitters.as";

// Mounted Bow logic

const Vec2f arm_offset = Vec2f(-4, -2);
const u32 shootDelay = 8; // Ticks

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");
	this.Tag("turret");

	Vehicle_Setup(this,
	              0.0f, // move speed
	              0.1f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	Vehicle_SetupWeapon(this, v,
	                    shootDelay, // fire delay (ticks)
	                    1, // fire bullets amount
	                    Vec2f(-6.0f, 2.0f), // fire position offset
	                    "mat_smallrocket", // bullet ammo config name
	                    "", // fire position offset
	                    "", // fire sound
	                    "EmptyFire" // empty fire sound
	                   );
	v.charge = 400;
	// init arm
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", "RocketLauncher_Cannon.png", 16, 16);
	if (arm !is null)
	{
		arm.SetOffset(arm_offset);
	}

	this.getShape().SetRotationsAllowed(false);
	this.set_string("autograb blob", "mat_smallrocket");

	this.set_u32("fireDelay", 0);

	sprite.SetZ(-10.0f);

	this.getCurrentScript().runFlags |= Script::tick_hasattached;

	if (isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_smallrocket");

		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo)) ammo.server_Die();
		}
	}
}

f32 getAimAngle(CBlob@ this, VehicleInfo@ v)
{
	f32 angle = Vehicle_getWeaponAngle(this, v);
	bool facing_left = this.isFacingLeft();
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");

	if (gunner !is null && gunner.getOccupied() !is null)
	{
		gunner.offsetZ = 5.0f;
		Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

		if (this.isAttached())
		{
			if (facing_left) { aim_vec.x = -aim_vec.x; }
			angle = (-(aim_vec).getAngle() + 180.0f);
		}
		else
		{
			if ((!facing_left && aim_vec.x < 0) ||
			     (facing_left && aim_vec.x > 0))
			{
				if (aim_vec.x > 0) { aim_vec.x = -aim_vec.x; }

				angle = (-(aim_vec).getAngle() + 180.0f);
				angle = Maths::Max(-90.0f, Maths::Min(angle, 50.0f));
			}
			else this.SetFacingLeft(!facing_left);
		}
	}

	return angle;
}

void onTick(CBlob@ this)
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30)
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v)) return;

		f32 angle = getAimAngle(this, v);
		Vehicle_SetWeaponAngle(this, angle, v);
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ arm = sprite.getSpriteLayer("arm");

		if (arm !is null)
		{
			bool facing_left = sprite.isFacingLeft();
			f32 rotation = angle * (facing_left ? -1 : 1);

			arm.ResetTransform();
			arm.SetFacingLeft(facing_left);
			arm.SetRelativeZ(1.0f);
			arm.SetOffset(arm_offset);
			arm.RotateBy(rotation, Vec2f(facing_left ? -4.0f : 4.0f, 0.0f));
		}
		Vehicle_StandardControls(this, v);
	}
	if (this.hasTag("invincible") && this.isAttached())
	{
		CBlob@ gunner = this.getAttachmentPoint(0).getOccupied();
		if (gunner !is null)
		{
			gunner.Tag("invincible");
			gunner.Tag("invincibilityByVehicle");
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!Vehicle_AddFlipButton(this, caller))
	{
		Vehicle_AddLoadAmmoButton(this, caller);
	}
}

bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _unused)
{
	if (getGameTime() < this.get_u32("fireDelay")) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("GUNNER");
	if (point is null) return;

	CBlob@ gunner = point.getOccupied();
	if (gunner is null) return;

	f32 angle = this.getAngleDegrees() + Vehicle_getWeaponAngle(this, v);
	angle = angle * (this.isFacingLeft() ? -1 : 1);

	Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
	Vec2f startPos = this.getPosition() + Vec2f((this.isFacingLeft() ? -16 : 16), -3).RotateBy(angle);

	if (isServer())
	{
		CBlob@ blob = server_CreateBlob("smallrocket", this.getTeamNum(), startPos);
		blob.set_f32("velocity", 15.0f);
		blob.setAngleDegrees(angle + 90 + (this.isFacingLeft() ? 180 : 0));
		blob.SetDamageOwnerPlayer(gunner.getPlayer());

		//HitInfo@[] hitInfos;
		//bool blobHit = getMap().getHitInfosFromRay(startPos, angle + (this.isFacingLeft() ? 0.0f : 180.0f), 20.0f, this, @hitInfos);
		//if (blobHit) for (u32 i = 0; i < hitInfos.length; i++) this.server_Hit(hitInfos[i].blob, hitInfos[i].hitpos, Vec2f(0, 0), 1.0f, Hitters::fire, true);
	}

	if (isClient())
	{
		for (int i = 1; i < 5; i++) MakeParticle(this, -dir * i, "SmallExplosion");
		this.getSprite().PlaySound("KegExplosion", 1.0f, 0.8f);
	}

	this.set_u32("fireDelay", getGameTime() + shootDelay);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("fire raycast"))
	{
		const u8 charge = params.read_u8();
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v)) return;

		Vehicle_onFire(this, v, null, charge);
	}
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(0, 0).RotateBy(this.getAngleDegrees());
	ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
	// return this.getTeamNum() == byBlob.getTeamNum();
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null) TryToAttachVehicle(this, blob);
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return false;

	CInventory@ inv = forBlob.getInventory();

	return forBlob.getCarriedBlob() is null && (inv !is null ? inv.getItem(v.ammo_name) is null : true);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attached.hasTag("bomber")) return;

	if (attached.getPlayer() !is null && this.hasTag("invincible"))
	{
		if (this.isAttached())
		{
			attached.Tag("invincible");
			attached.Tag("invincibilityByVehicle");
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (detached.hasTag("invincibilityByVehicle"))
	{
		detached.Untag("invincible");
		detached.Untag("invincibilityByVehicle");
	}
}
