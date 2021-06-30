#include "Hitters.as";
#include "VehicleAttachmentCommon.as";
#include "GunCommon.as";

const Vec2f arm_offset = Vec2f(-6, -6);
const u16 max_ammo = 500;

const string ammo_blob = "mat_mithril";

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");
	this.Tag("turret");

	GunSettings settings = GunSettings();

	settings.B_GRAV = Vec2f(0, 0.003); //Bullet Gravity
	settings.B_TTL = 13; //Bullet Time to live
	settings.B_SPEED = 90; //Bullet speed
	settings.B_DAMAGE = 6.0f; //Bullet damage
	settings.B_TYPE = HittersTC::plasma;
	settings.G_RECOIL = 0;
	settings.MUZZLE_OFFSET = Vec2f(-40, -7); //Where muzzle flash and bullet spawn

	this.set("gun_settings", @settings);

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("GUNNER");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_up);
	}

	this.getShape().SetRotationsAllowed(false);

	this.set_string("CustomBullet", "Bullet_Plasma.png");
	this.set_f32("CustomBulletLength", 7.0f);

	this.set_u16("ammo_count", 0);
	this.set_u32("fireDelay", 0);

	this.addCommandID("load_ammo");

	//this.getCurrentScript().runFlags |= Script::tick_hasattached;
}

void onInit(CSprite@ this)
{
	// Add arm
	CSpriteLayer@ arm = this.addSpriteLayer("arm", "Coilgun_Cannon.png", 80, 16);
	if (arm !is null)
	{
		arm.SetOffset(arm_offset);
	}

	// Add muzzle flash
	CSpriteLayer@ flash = this.addSpriteLayer("muzzle_flash", "MuzzleFlash_Plasma.png", 16, 8);
	if (flash !is null)
	{
		GunSettings@ settings;
		this.getBlob().get("gun_settings", @settings);

		Animation@ anim = flash.addAnimation("default", 1, false);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		anim.AddFrames(frames);
		flash.SetRelativeZ(1.0f);
		flash.SetOffset(settings.MUZZLE_OFFSET);
		flash.SetVisible(false);
		// flash.setRenderStyle(RenderStyle::additive);
	}

	this.SetZ(-10.0f);

	this.SetEmitSound("Coilgun_Shoot.ogg");
	this.SetEmitSoundSpeed(1.0f);
	this.SetEmitSoundPaused(true);
}

f32 getAimAngle(CBlob@ this)
{
	bool facing_left = this.isFacingLeft();
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");
	Vec2f dir = gunner.getAimPos() - this.getPosition();
	f32 angle = dir.Angle();
	dir.Normalize();

	if (gunner !is null && gunner.getOccupied() !is null)
	{
		gunner.offsetZ = 5.0f;
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
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("GUNNER");
	CSprite@ sprite = this.getSprite();

	if (this.get_bool("justShot"))
	{
		this.set_bool("justShot", false);
	}

	if (ap !is null)
	{
		CBlob@ gunner = ap.getOccupied();
		if (gunner is null) return;

		f32 angle = getAimAngle(this);

		bool facing_left = sprite.isFacingLeft();
		f32 rotation = angle * (facing_left ? -1 : 1);

		CSpriteLayer@ arm = sprite.getSpriteLayer("arm");
		if (arm !is null)
		{
			arm.ResetTransform();
			arm.SetFacingLeft(facing_left);
			arm.SetRelativeZ(1.0f);
			arm.SetOffset(arm_offset);
			arm.RotateBy(rotation, Vec2f(facing_left ? -4.0f : 4.0f, 0.0f));
		}

		CSpriteLayer@ flash = sprite.getSpriteLayer("muzzle_flash");
		if (flash !is null)
		{
			GunSettings@ settings;
			this.get("gun_settings", @settings);

			flash.ResetTransform();
			flash.SetRelativeZ(1.0f);
			flash.RotateBy(rotation, Vec2f(-37 * (facing_left ? 1 : -1), 0));
		}

		const bool a1_jr = ap.isKeyJustReleased(key_action1);
		const bool a1_p = ap.isKeyPressed(key_action1) && !ap.isKeyJustPressed(key_action1);
		const bool spinup = getGameTime() < this.get_u32("spinCooldown");

		sprite.SetEmitSoundPaused(!(a1_p && !spinup && GetAmmo(this) > 0));

		if (ap.isKeyJustPressed(key_up))
		{
			if (isServer()) gunner.server_DetachFrom(this);
		}

		if (ap.isKeyJustPressed(key_action1))
		{
			sprite.PlaySound("/Coilgun_Spinup.ogg", 1.00f, 1.00f);
			this.set_u32("spinCooldown", getGameTime() + 50);
		}
		else if (!spinup && a1_jr) sprite.PlaySound("/Coilgun_Spindown.ogg", 1.00f, 1.00f);

		if (a1_p && !spinup && getGameTime() >= this.get_u32("shootCooldown"))
		{
			if (GetAmmo(this) > 0) Shoot(this, angle);
			else sprite.PlaySound("EmptyFire.ogg", 1.00f, 1.00f);
		}
	}
	else sprite.SetEmitSoundPaused(true);
}

void TakeAmmo(CBlob@ this, u16 amount)
{
	this.set_u16("ammo_count", Maths::Max(0, Maths::Min(max_ammo, this.get_u16("ammo_count") - amount)));
	this.Sync("ammo_count", false);
}

u16 GiveAmmo(CBlob@ this, u16 amount)
{
	u16 remain = Maths::Max(0, s32(this.get_u16("ammo_count")) + s32(amount) - s32(max_ammo));

	this.set_u16("ammo_count", Maths::Max(0, Maths::Min(max_ammo, this.get_u16("ammo_count") + amount)));
	this.Sync("ammo_count", false);

	//print("A: " + amount + "; R: " + remain);
	return remain;
}

u16 GetAmmo(CBlob@ this)
{
	return this.get_u16("ammo_count");
}

void Shoot(CBlob@ this, f32 angle)
{
	if (isServer())
	{
		angle = angle * (this.isFacingLeft() ? -1 : 1);

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
		CSpriteLayer@ flash = this.getSprite().getSpriteLayer("muzzle_flash");
		if (flash !is null)
		{
			//Turn on muzzle flash
			flash.SetFrameIndex(0);
			flash.SetVisible(true);
		}
	}

	TakeAmmo(this, 1);
	this.set_u32("shootCooldown", getGameTime() + 2);
	this.set_bool("justShot", true);
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

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	CBlob@ carried = caller.getCarriedBlob();

	if (this.get_u16("ammo_count") < max_ammo && carried !is null && carried.getName() == ammo_blob)
	{
		params.write_netid(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton("$" + ammo_blob + "$", Vec2f(0, 0), this, this.getCommandID("load_ammo"), "Load " + carried.getInventoryName() + "\n(" + this.get_u16("ammo_count") + " / " + max_ammo + ")", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("load_ammo"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ carried = caller.getCarriedBlob();

		if (carried !is null && carried.getName() == ammo_blob)
		{
			u16 remain = GiveAmmo(this, carried.getQuantity());
			// this.Sync("ammo_count", false); // fuck this broken sync shit

			if (isServer())
			{
				if (remain == 0) carried.server_Die();
				else carried.server_SetQuantity(remain);
			}
		}
	}
}

void onRender(CSprite@ this)
{
	if (this is null) return;

	AttachmentPoint@ gunner = this.getBlob().getAttachments().getAttachmentPointByName("GUNNER");
	if (gunner !is null && gunner.getOccupied() !is null && gunner.getOccupied().isMyPlayer())
	{
		drawAmmoCount(this.getBlob());
	}
}

void drawAmmoCount(CBlob@ this)
{
	// draw ammo count
	Vec2f pos2d1 = this.getInterpolatedScreenPos() - Vec2f(0, 10);

	Vec2f pos2d = this.getInterpolatedScreenPos() - Vec2f(0, 60);
	Vec2f dim = Vec2f(20, 8);
	const f32 y = this.getHeight() * 2.4f;
	f32 charge_percent = 1.0f;

	Vec2f ul = Vec2f(pos2d.x - dim.x, pos2d.y + y);
	Vec2f lr = Vec2f(pos2d.x - dim.x + charge_percent * 2.0f * dim.x, pos2d.y + y + dim.y);

	if (this.isFacingLeft())
	{
		ul -= Vec2f(8, 0);
		lr -= Vec2f(8, 0);

		f32 max_dist = ul.x - lr.x;
		ul.x += max_dist + dim.x * 2.0f;
		lr.x += max_dist + dim.x * 2.0f;
	}

	f32 dist = lr.x - ul.x;
	Vec2f upperleft((ul.x + (dist / 2.0f)) + 4.0f, pos2d1.y + this.getHeight() + 30);
	Vec2f lowerright((ul.x + (dist / 2.0f)), upperleft.y + 20);

	//GUI::DrawRectangle(upperleft - Vec2f(0,20), lowerright , SColor(255,0,0,255));

	u16 ammo = this.get_u16("ammo_count");

	string reqsText = "" + ammo + " / " + max_ammo;

	u8 numDigits = reqsText.size();

	upperleft -= Vec2f((float(numDigits) * 4.0f), 0);
	lowerright += Vec2f((float(numDigits) * 4.0f), 0);

	GUI::DrawRectangle(upperleft, lowerright);
	GUI::SetFont("menu");
	GUI::DrawText(reqsText, upperleft + Vec2f(2, 1), color_white);
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
	if (detached.hasTag("bomber")) return;

	if (detached.hasTag("invincibilityByVehicle"))
	{
		detached.Untag("invincible");
		detached.Untag("invincibilityByVehicle");
	}
}
