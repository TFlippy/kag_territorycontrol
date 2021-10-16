#include "VehicleCommon.as"
#include "CargoAttachmentCommon.as"
#include "Hitters.as";
#include "Explosion.as";

const Vec2f arm_offset = Vec2f(-2, -4);

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              80.0f, // move speed
	              0.40f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              true  // inventory access
	             );

	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	Vehicle_SetupWeapon(this, v,
	                    40, // fire delay (ticks)
	                    1, // fire bullets amount
	                    Vec2f(-6.0f, 2.0f), // fire position offset
	                    "mat_tankshell", // bullet ammo config name
	                    "tankshell", // bullet config name
	                    "KegExplosion", // fire sound
	                    "EmptyFire" // empty fire sound
	                   );
	v.charge = 100;

	this.set_f32("hit dmg modifier", 20.0f);
	this.set_f32("map dmg modifier", 100.0f);

	this.set_u32("lastHornTime", 0.0f);
	this.set_string("custom_explosion_sound", "KegExplosion");
	this.set_string("ammoIcon", "icon_tankshell");

	this.getShape().SetOffset(Vec2f(0, 8));

	this.Tag("blocks sword");

	CSprite@ sprite = this.getSprite();

	sprite.SetZ(10.0f);

	Vehicle_SetupGroundSound(this, v, "machinery_out_lp_03", 0.8f, 1.0f);
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(-12.0f, 12.0f));
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(-1.0f, 12.0f));
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(10.0f, 12.0f));

	AttachmentPoint@ driverpoint = this.getAttachments().getAttachmentPointByName("DRIVER");
	if (driverpoint !is null)
	{
		driverpoint.SetKeysToTake(key_action1);
	}

	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", "SteamTank_Cannon.png", 32, 8);
	if (arm !is null)
	{
		arm.SetOffset(arm_offset);
		arm.SetRelativeZ(1.0f);
	}

	this.getShape().SetRotationsAllowed(true);
	this.set_string("autograb blob", "mat_tankshell");

	if (isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_tankshell");
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
	bool failed = true;

	if (gunner !is null && gunner.getOccupied() !is null)
	{
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
				angle = Maths::Max(-60.0f , Maths::Min(angle , 5.0f));
			}
		}
	}

	return angle;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attached.hasTag("bomber")) return;

	attached.Tag("invincible");
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (detached.hasTag("bomber")) return;

	detached.Untag("invincible");
}

void onTick(CBlob@ this)
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v)) return;

		this.set_f32("gun_recoil_current", Maths::Lerp(this.get_f32("gun_recoil_current"), 0, 0.45f));

		//set the arm angle based on GUNNER mouse aim, see above ^^^^
		f32 angle = getAimAngle(this, v);
		Vehicle_SetWeaponAngle(this, angle, v);
		CSprite@ sprite = this.getSprite();

		CSpriteLayer@ arm = sprite.getSpriteLayer("arm");
		if (arm !is null)
		{
			bool facing_left = sprite.isFacingLeft();
			f32 rotation = angle * (facing_left ? -1 : 1);

			arm.ResetTransform();
			arm.SetRelativeZ(-1.0f);
			arm.SetOffset(Vec2f(this.get_f32("gun_recoil_current"), 0).RotateBy(-getAimAngle(this, v)) + arm_offset);
			arm.RotateBy(rotation, Vec2f(facing_left ? -4.0f : 4.0f, 0.0f));
		}

		Vehicle_StandardControls(this, v);
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
	if (bullet !is null)
	{
		u16 charge = v.charge;
		f32 angle = Vehicle_getWeaponAngle(this, v);
		angle = angle * (this.isFacingLeft() ? -1 : 1);
		angle += ((XORRandom(200) - 100) / 100.0f);
		angle += this.getAngleDegrees();

		Vec2f vel = Vec2f(30.0f * (this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
		bullet.setVelocity(vel);

		Vec2f offset = Vec2f((this.isFacingLeft() ? -1 : 1) * 26, -4);
		offset.RotateBy(angle);
		bullet.setPosition(this.getPosition() + offset);

		bullet.server_SetTimeToDie(20.0f);

		if (isClient())
		{
			Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
			ParticleAnimated("SmallExplosion.png", this.getPosition() + offset, dir, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
		}
		this.set_f32("gun_recoil_current", 5);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("fire blob"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		const u8 charge = params.read_u8();

		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v)) return;

		Vehicle_onFire(this, v, blob, charge);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum() ? blob.isCollidable() : false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachCargo(this, blob);
	}
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v)) return;

		Explode(this, 32.0f, 4.0f);

		int loadedAmmo = v.loaded_ammo;

		for (int i = 0; i < 2 + XORRandom(3); i++)
		{
			Vec2f dir = Vec2f((100 - XORRandom(200)) / 100.0f, (100 - XORRandom(200)) / 100.0f);
			LinearExplosion(this, dir, 5.0f * 1 + loadedAmmo, 3.0f * 1 + loadedAmmo, 8, 8.0f, Hitters::explosion);
		}

		CBlob@ wreck = server_CreateBlobNoInit("steamtankwreck");
		wreck.setPosition(this.getPosition());
		wreck.setVelocity(this.getVelocity());
		wreck.setAngleDegrees(this.getAngleDegrees());
		wreck.server_setTeamNum(this.getTeamNum());
		wreck.Init();
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	switch (customData)
	{
		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			dmg *= 0.25f;
			break;

		case Hitters::bomb:
			dmg *= 4.0f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 4.0f;
			break;

		case Hitters::bomb_arrow:
			dmg *= 4.00f;
			break;

		case Hitters::cata_stones:
			dmg *= 1.0f;
			break;
		case Hitters::crush:
			dmg *= 1.0f;
			break;

		case Hitters::flying: // boat ram
			dmg *= 0.5f;
			break;
	}

	return dmg;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}
