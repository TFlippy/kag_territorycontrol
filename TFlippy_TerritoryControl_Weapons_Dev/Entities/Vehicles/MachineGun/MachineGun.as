#include "Hitters.as";
#include "VehicleCommon.as";
#include "GunCommon.as";
#include "BulletCase.as";

const Vec2f arm_offset = Vec2f(-1, -3);

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");
	this.Tag("turret");
	this.Tag("constant sound"); // loop sound

	GunSettings settings = GunSettings();

	settings.B_GRAV = Vec2f(0, 0.006); //Bullet Gravity
	settings.B_TTL = 20; //Bullet Time to live
	settings.B_SPEED = 70; //Bullet speed
	settings.B_DAMAGE = 2.5f; //Bullet damage
	settings.MUZZLE_OFFSET = Vec2f(-21, -4); //Where muzzle flash and bullet spawn

	this.set("gun_settings", @settings);

	Vehicle_Setup(this,
	              0.0f, // move speed
	              0.1f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false  // inventory access
	             );

	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	Vehicle_SetupWeapon(this, v,
	                    2, // fire delay (ticks)
	                    1, // fire bullets amount
	                    Vec2f(-6.0f, 2.0f), // fire position offset
	                    "mat_gatlingammo", // bullet ammo config name
	                    "", // fire position offset
	                    "", // fire sound
	                    "EmptyFire" // empty fire sound
	                   );
	v.charge = 400;

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("GUNNER");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_up);
	}

	this.getShape().SetRotationsAllowed(false);
	this.set_string("ammoIcon", "icon_gatlingammo");
	this.set_string("autograb blob", "mat_gatlingammo");

	this.set_u32("fireDelay", 0);

	this.getCurrentScript().runFlags |= Script::tick_hasattached;

	if (isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_gatlingammo");
		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo)) ammo.server_Die();
		}
	}
}

void onInit(CSprite@ this)
{
	// Add arm
	CSpriteLayer@ arm = this.addSpriteLayer("arm", "MachineGun_Top.png", 32, 8);
	if (arm !is null) arm.SetOffset(arm_offset);

	// Add muzzle flash
	CSpriteLayer@ flash = this.addSpriteLayer("muzzle_flash", "MuzzleFlash.png", 16, 8);
	if (flash !is null)
	{
		GunSettings@ settings;
		this.getBlob().get("gun_settings", @settings);

		Animation@ anim = flash.addAnimation("default", 1, false);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		anim.AddFrames(frames);
		flash.SetRelativeZ(2.0f);
		flash.SetOffset(settings.MUZZLE_OFFSET);
		flash.SetVisible(false);
		// flash.setRenderStyle(RenderStyle::additive);
	}

	this.SetZ(-10.0f);

	this.SetEmitSound("MachineGun_Shoot.ogg");
	this.SetEmitSoundSpeed(1.0f);
	this.SetEmitSoundPaused(true);
}

f32 getAimAngle(CBlob@ this, VehicleInfo@ v)
{
	f32 angle = Vehicle_getWeaponAngle(this, v);
	bool facing_left = this.isFacingLeft();
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");

	if (gunner !is null && gunner.getOccupied() !is null)
	{
		gunner.offsetZ = -2.0f;
		Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

		if (this.isAttached())
		{
			if (facing_left) aim_vec.x = -aim_vec.x;
			angle = (-(aim_vec).getAngle() + 180.0f);
		}
		else
		{
			if ((!facing_left && aim_vec.x < 0) ||
			     (facing_left && aim_vec.x > 0))
			{
				if (aim_vec.x > 0) aim_vec.x = -aim_vec.x;

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
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("GUNNER");
	if (ap !is null)
	{
		this.set_f32("gun_recoil_current", Maths::Lerp(this.get_f32("gun_recoil_current"), 0, 0.45f));
		CSprite@ sprite = this.getSprite();

		CBlob@ gunner = ap.getOccupied();
		if (gunner is null)
		{
			sprite.SetEmitSoundPaused(true);
			return;
		}

		f32 angle = getAimAngle(this, v);
		Vehicle_SetWeaponAngle(this, angle, v);

		bool facing_left = sprite.isFacingLeft();
		f32 rotation = angle * (facing_left ? -1 : 1);

		CSpriteLayer@ arm = sprite.getSpriteLayer("arm");
		if (arm !is null)
		{
			arm.ResetTransform();
			arm.SetFacingLeft(facing_left);
			arm.SetRelativeZ(1.0f);
			arm.SetOffset(Vec2f(this.get_f32("gun_recoil_current"), 0).RotateBy(-getAimAngle(this, v)) + arm_offset);
			arm.RotateBy(rotation, Vec2f(facing_left ? -1.0f : 1.0f, 0.0f));
		}

		CSpriteLayer@ flash = sprite.getSpriteLayer("muzzle_flash");
		if (flash !is null)
		{
			GunSettings@ settings;
			this.get("gun_settings", @settings);

			flash.ResetTransform();
			//flash.SetRelativeZ(1.0f);
			flash.RotateBy(rotation, Vec2f(settings.MUZZLE_OFFSET.x * (facing_left ? 1 : -1), 1));
		}

		CInventory@ inv = this.getInventory();
		if (inv !is null)
		{
			int ammoCount = inv.getCount(v.ammo_name);
			const bool shooting = ap.isKeyPressed(key_action1) || ap.isKeyJustPressed(key_action1);
			if (isClient()) sprite.SetEmitSoundPaused(!shooting || ammoCount <= 0);
		}
	}

	Vehicle_StandardControls(this, v);
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

	// Angle shittery
	f32 angle = this.getAngleDegrees() + Vehicle_getWeaponAngle(this, v);
	angle *= (this.isFacingLeft() ? -1 : 1);
	angle += ((XORRandom(300) - 100) / 100.0f);

	if (isServer())
	{
		GunSettings@ settings;
		this.get("gun_settings", @settings);

		// Muzzle
		Vec2f fromBarrel = Vec2f((settings.MUZZLE_OFFSET.x / 3) * (this.isFacingLeft() ? 1 : -1), settings.MUZZLE_OFFSET.y + 1);
		fromBarrel = fromBarrel.RotateBy(angle);

		CBlob@ gunner = this.getAttachmentPoint(0).getOccupied();
		if (gunner !is null)
		{
			shootGun(this.getNetworkID(), angle, gunner.getNetworkID(), this.getPosition() + fromBarrel);
		}
	}

	if (isClient())
	{
		CSprite@ sprite = this.getSprite();

		this.set_f32("gun_recoil_current", 3);

		CSpriteLayer@ flash = sprite.getSpriteLayer("muzzle_flash");
		if (flash !is null)
		{
			//Turn on muzzle flash
			flash.SetFrameIndex(0);
			flash.SetVisible(true);
		}
		sprite.ResetTransform();
		sprite.getSpriteLayer("arm").SetAnimation("shoot");

		f32 oAngle = (angle % 360) + 180;
		ParticleCase2("GatlingCase.png", this.getPosition(), this.isFacingLeft() ? oAngle : angle);
	}

	this.set_u32("fireDelay", getGameTime() + 2);
}

void shootGun(const u16 gunID, const f32 aimangle, const u16 hoomanID, const Vec2f pos) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(hoomanID);
	params.write_netid(gunID);
	params.write_f32(aimangle);
	params.write_Vec2f(pos);
	params.write_u32(getGameTime());

	rules.SendCommand(rules.getCommandID("fireGun"), params);
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

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.hasTag("vehicle");
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