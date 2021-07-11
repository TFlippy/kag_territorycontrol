#include "Hitters.as";
#include "Explosion.as";
#include "VehicleFuel.as";
#include "GunCommon.as";

const Vec2f miniGun_offset = Vec2f(-42,7);

const Vec2f upVelo = Vec2f(0.00f, -0.01f);
const Vec2f downVelo = Vec2f(0.00f, 0.002f);
const Vec2f leftVelo = Vec2f(-0.01f, 0.00f);
const Vec2f rightVelo = Vec2f(0.01f, 0.00f);

const Vec2f minClampVelocity = Vec2f(-0.40f, -0.70f);
const Vec2f maxClampVelocity = Vec2f( 0.40f, 0.00f);

const Vec2f gun_clampAngle = Vec2f(-20, 80);

const f32 thrust = 950.00f;
const u32 shootDelay = 4; // Ticks
const f32 damage = 2.0f;
const int maxAmmoStack = 300;

void onInit(CBlob@ this)
{
	this.set_string("custom_explosion_sound", "bigbomb_explosion.ogg");
	this.set_bool("map_damage_raycast", true);
	this.Tag("map_damage_dirt");

	this.addCommandID("load_fuel");
	this.addCommandID("addAmmo");
	this.addCommandID("shoot");

	this.Tag("vehicle");
	this.Tag("aerial");
	this.Tag("helicopter");
	this.set_bool("lastTurn", false);

	GunSettings settings = GunSettings();

	settings.B_GRAV = Vec2f(0, 0.008); //Bullet Gravity
	settings.B_TTL = 14; //Bullet Time to live
	settings.B_SPEED = 30; //Bullet speed
	settings.B_DAMAGE = 2.0f; //Bullet damage
	settings.MUZZLE_OFFSET = Vec2f(-42,7);
	settings.G_RECOIL = 0;

	this.set("gun_settings", @settings);

	if (this !is null)
	{
		CShape@ shape = this.getShape();
		if (shape !is null)
		{
			shape.SetRotationsAllowed(false);
		}
	}

	this.set_f32("max_fuel", 3000);
	this.set_f32("fuel_consumption_modifier", 3.0f);

	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			ap.offsetZ = 10.0f;
			ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
		}
	}

	this.set_u16("ammoCount", 0);

	this.getCurrentScript().tickFrequency = 1;
}

void onInit(CSprite@ this)
{
	//Add minigun
	CSpriteLayer@ mini = this.addSpriteLayer("minigun", "Minicopter_Gun.png", 13, 6);
	if (mini !is null)
	{
		mini.SetOffset(miniGun_offset);
		mini.SetRelativeZ(-50.0f);
		mini.SetVisible(true);
	}

	// Add minigun muzzle flash
	CSpriteLayer@ flash = this.addSpriteLayer("muzzle_flash", "MuzzleFlash.png", 16, 8);
	if (flash !is null)
	{
		GunSettings@ settings;
		this.getBlob().get("gun_settings", @settings);

		Animation@ anim = flash.addAnimation("default", 1, false);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		anim.AddFrames(frames);
		flash.SetRelativeZ(1.0f);
		flash.SetOffset(Vec2f(-58,6));
		flash.SetVisible(false);
		// flash.setRenderStyle(RenderStyle::additive);
	}

	this.SetEmitSound("minicopter_loop.ogg");
	this.SetEmitSoundSpeed(0.01f);
	this.SetEmitSoundPaused(false);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this)
{
	if (this !is null)
	{
		CSprite@ sprite = this.getSprite();
		CShape@ shape = this.getShape();
		Vec2f currentVel = this.getVelocity();
		f32 angle = shape.getAngleDegrees();

		const bool flip = this.isFacingLeft();

		Vec2f newForce = Vec2f(0, 0);

		AttachmentPoint@[] aps;
		this.getAttachmentPoints(@aps);

		f32 fuel = GetFuel(this);

		int size = aps.size();
		for(int a = 0; a < size; a++)
		{
			AttachmentPoint@ ap = aps[a];
			if (ap !is null)
			{
				CBlob@ hooman = ap.getOccupied();
				if (hooman !is null)
				{
					if (ap.name == "DRIVER")
					{
						const bool pressed_w  = ap.isKeyPressed(key_up);
						const bool pressed_s  = ap.isKeyPressed(key_down);
						const bool pressed_a  = ap.isKeyPressed(key_left);
						const bool pressed_d  = ap.isKeyPressed(key_right);
						const bool pressed_c  = ap.isKeyPressed(key_pickup);
						const bool pressed_m1 = ap.isKeyPressed(key_action1);

						Vec2f aimPos = ap.getAimPos();

						const f32 mass = this.getMass();

						if (fuel > 0)
						{
							if (pressed_w) newForce += upVelo;
							if (pressed_s) newForce += downVelo;
							if (pressed_a) newForce += leftVelo;
							if (pressed_d) newForce += rightVelo;
						}
						else
						{
							return;
						}
					}
					else if (ap.name == "PASSENGER" && hooman !is null)
					{
						bool pressed_m1 = ap.isKeyPressed(key_action1);
						Vec2f aimPos = hooman.getAimPos();
						
						CSpriteLayer@ minigun = sprite.getSpriteLayer("minigun");
						if (minigun !is null)
						{
							if (this.get_bool("lastTurn") != flip)
							{
								this.set_bool("lastTurn", flip);
								minigun.ResetTransform();

							}

							Vec2f aimvector = aimPos - minigun.getWorldTranslation();
							aimvector.RotateBy(-this.getAngleDegrees());

							const f32 flip_factor = flip ? -1: 1;
							const f32 angle = constrainAngle(-aimvector.Angle() + (flip ? 180 : 0)) * flip_factor;
							const f32 clampedAngle = (Maths::Clamp(angle, gun_clampAngle.x, gun_clampAngle.y) * flip_factor);

							this.set_f32("gunAngle", clampedAngle);

							minigun.ResetTransform();
							minigun.RotateBy(clampedAngle, Vec2f(5 * flip_factor, 1));

							CSpriteLayer@ flash = sprite.getSpriteLayer("muzzle_flash");
							if (flash !is null)
							{
								GunSettings@ settings;
								this.get("gun_settings", @settings);

								flash.ResetTransform();
								flash.SetRelativeZ(1.0f);
								flash.RotateBy(clampedAngle, Vec2f(22 * flip_factor, 1));
							}

							if (pressed_m1 && isClient())
							{
								CBlob@ realPlayer = getLocalPlayerBlob();
								if (getGameTime() > this.get_u32("fireDelayGun") && realPlayer !is null && realPlayer is hooman)
								{
									CBitStream params;
									params.write_s32(this.get_f32("gunAngle"));
									params.write_Vec2f(minigun.getWorldTranslation());
									this.SendCommand(this.getCommandID("shoot"), params);
									this.set_u32("fireDelayGun", getGameTime() + (shootDelay));
								}
							}
						}
						//gun here
					}
				}
			}
		}

		Vec2f currentForce = this.get_Vec2f("current_force");
		Vec2f targetForce = this.get_Vec2f("target_force") + newForce;

		f32 targetForce_y = Maths::Clamp(targetForce.y, minClampVelocity.y, maxClampVelocity.y);

		Vec2f clampedTargetForce = Vec2f(Maths::Clamp(targetForce.x, Maths::Max(minClampVelocity.x, -Maths::Abs(targetForce_y)), Maths::Min(maxClampVelocity.x, Maths::Abs(targetForce_y))), targetForce_y);
		Vec2f resultForce = Vec2f(Lerp(currentForce.x, clampedTargetForce.x, lerp_speed_x), Lerp(currentForce.y, clampedTargetForce.y, lerp_speed_y));

		this.AddForce(resultForce * thrust);
		this.setAngleDegrees(resultForce.x * 80.00f);
		this.SetFacingLeft(this.getVelocity().x < 1.00f);

		sprite.animation.time = Maths::Floor(1.00f + (1.00f - Maths::Abs(resultForce.getLength())) * 3) % 4;
		sprite.SetEmitSoundSpeed(Maths::Min(0.0001f + Maths::Abs(resultForce.getLength() * 1.50f), 1.10f));

		this.set_Vec2f("current_force", resultForce);
		this.set_Vec2f("target_force", clampedTargetForce);

		if (this.getTickSinceCreated() % 5 == 0)
		{
			f32 taken = this.get_f32("fuel_consumption_modifier") * resultForce.getLength();
			TakeFuel(this, taken);
		}
	}
}

const f32 lerp_speed_x = 0.20f;
const f32 lerp_speed_y = 0.20f;

f32 Lerp(f32 a, f32 b, f32 time)
{
	return a + (b - a) * time;
}

// f32 constrainAngle(f32 x)
// {
    // x = x % 360;
    // if (x < 0) x += 360;
    // return x;
// }

f32 constrainAngle(f32 x)
{
	x = (x + 180) % 360;
	if (x < 0) x += 360;
	return x - 180;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attachedPoint.socket)
	{
		this.Tag("no barrier pass");
	}
	if (attached !is null)
	{
		attached.SetVisible(true);
		attached.Tag("invincible");
		attached.Tag("invincibilityByVehicle");
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint)
{
	if (attachedPoint.socket)
	{
		detached.setVelocity(this.getVelocity());
		detached.AddForce(Vec2f(0.0f, -300.0f));
		this.Untag("no barrier pass");
	}
	if (detached !is null)
	{
		detached.SetVisible(true);
		detached.Untag("invincible");
		detached.Untag("invincibilityByVehicle");
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (!blob.isCollidable() || blob.isAttached()){
		return false;
	} // no colliding against people inside vehicles
	if (blob.getRadius() > this.getRadius() ||
	        (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("player") && this.getShape().vellen > 1.0f) ||
	        (blob.getShape().isStatic()) || blob.hasTag("projectile"))
	{
		return true;
	}
	return blob.hasTag("noisemaker");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() == this.getTeamNum())
	{
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$icon_pistolammo$", Vec2f(17, 5), this, 
				this.getCommandID("addAmmo"), getTranslatedString("Insert Low Caliber Ammo"), params);
		}
		{
			CBitStream params;
			CBlob@ carried = caller.getCarriedBlob();
			if (carried !is null && this.get_f32("fuel_count") < this.get_f32("max_fuel"))
			{
				string fuel_name = carried.getName();
				bool isValid = fuel_name == "mat_oil" || fuel_name == "mat_fuel";

				if (isValid)
				{
					params.write_netid(caller.getNetworkID());
					CButton@ button = caller.CreateGenericButton("$" + fuel_name + "$", Vec2f(12, 0), this, this.getCommandID("load_fuel"), "Load " + carried.getInventoryName() + "\n(" + this.get_f32("fuel_count") + " / " + this.get_f32("max_fuel") + ")", params);
				}
			}
		}
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
			dmg *= 1.25f;
			break;
		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 0.5f;
			break;
		case Hitters::bomb_arrow:
			dmg *= 0.5f;
			break;
		case Hitters::flying:
			dmg *= 0.5f;
			break;
	}
	return dmg;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shoot"))
	{
		if (this.get_u16("ammoCount") > 0)
		{
			this.sub_u16("ammoCount", 1);
			this.Sync("ammoCount", true);
			f32 angle = params.read_s32();
			ShootGun(this, angle, params.read_Vec2f());
		}
	}
	else if(cmd == this.getCommandID("addAmmo"))
	{
		//mat_gatlingammo
		u16 blobNum = 0;
		if (!params.saferead_u16(blobNum))
		{
			warn("addAmmo");
			return;
		}
		CBlob@ blob = getBlobByNetworkID(blobNum);
		if(blob is null) return;

		CBlob@ attachedBlob = blob.getAttachments().getAttachmentPointByName("PICKUP").getOccupied();
		if (attachedBlob !is null && attachedBlob.getName() == "mat_pistolammo")
		{
			this.add_u16("ammoCount", attachedBlob.getQuantity());
			attachedBlob.server_Die();
		}

		CInventory@ invo = blob.getInventory();
		int ammoCount = invo.getCount("mat_pistolammo");

		if (ammoCount > 0)
		{
			invo.server_RemoveItems("mat_pistolammo", ammoCount);
			this.add_u16("ammoCount", ammoCount);
		}

		this.Sync("ammoCount", true);
	}
	else if (cmd == this.getCommandID("load_fuel"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ carried = caller.getCarriedBlob();

		if (carried !is null)
		{
			string fuel_name = carried.getName();
			f32 fuel_modifier = 1.00f;
			bool isValid = false;

			fuel_modifier = GetFuelModifier(fuel_name, isValid, 1);

			if (isValid)
			{
				u16 remain = GiveFuel(this, carried.getQuantity(), fuel_modifier);

				if (remain == 0)
				{
					carried.Tag("dead");
					carried.server_Die();
				}
				else
				{
					carried.server_SetQuantity(remain);
				}
			}
		}
	}
}


void onRender(CSprite@ this)
{
	if (this is null) return; //can happen with bad reload

	// draw only for local player
	CBlob@ blob = this.getBlob();
	CBlob@ localBlob = getLocalPlayerBlob();

	if (blob is null)
	{
		return;
	}

	if (localBlob is null)
	{
		return;
	}

	AttachmentPoint@ gunner = blob.getAttachments().getAttachmentWithBlob(localBlob);
	if (gunner !is null)
	{
		if(gunner.name == "DRIVER")
		{
			drawFuelCount(blob);
		}
		else
		{
			renderAmmo(blob,false);
		}
	}

	Vec2f mouseWorld = getControls().getMouseWorldPos();
	bool mouseOnBlob = (mouseWorld - blob.getPosition()).getLength() < this.getBlob().getRadius();
	f32 fuel = blob.get_f32("fuel_count");
	if (fuel <= 0 && mouseOnBlob)
	{
		Vec2f pos = blob.getInterpolatedScreenPos();

		GUI::SetFont("menu");
		GUI::DrawTextCentered("Requires fuel!", Vec2f(pos.x, pos.y + 85 + Maths::Sin(getGameTime() / 5.0f) * 5.0f), SColor(255, 255, 55, 55));
		GUI::DrawTextCentered("(Oil or Fuel)", Vec2f(pos.x, pos.y + 105 + Maths::Sin(getGameTime() / 5.0f) * 5.0f), SColor(255, 255, 55, 55));
	}
}

const f32 fuel_factor = 100.00f;

void renderAmmo(CBlob@ blob, bool rocket)
{
	Vec2f pos2d1 = blob.getInterpolatedScreenPos() - Vec2f(0, 10);

	Vec2f pos2d = blob.getInterpolatedScreenPos() - Vec2f(0, 60);
	Vec2f dim = Vec2f(20, 8);
	const f32 y = blob.getHeight() * 2.4f;
	f32 charge_percent = 1.0f;

	Vec2f ul = Vec2f(pos2d.x - dim.x, pos2d.y + y);
	Vec2f lr = Vec2f(pos2d.x - dim.x + charge_percent * 2.0f * dim.x, pos2d.y + y + dim.y);

	if (blob.isFacingLeft())
	{
		ul -= Vec2f(8, 0);
		lr -= Vec2f(8, 0);

		f32 max_dist = ul.x - lr.x;
		ul.x += max_dist + dim.x * 2.0f;
		lr.x += max_dist + dim.x * 2.0f;
	}

	f32 dist = lr.x - ul.x;
	Vec2f upperleft((ul.x + (dist / 2.0f)) - 5.0f + 4.0f, pos2d1.y + blob.getHeight() + 30);
	Vec2f lowerright((ul.x + (dist / 2.0f))  + 5.0f + 4.0f, upperleft.y + 20);

	//GUI::DrawRectangle(upperleft - Vec2f(0,20), lowerright , SColor(255,0,0,255));

	u16 ammo = rocket ? blob.get_u16("rocketCount") : blob.get_u16("ammoCount");

	string reqsText = "" + ammo;

	u8 numDigits = reqsText.size();

	upperleft -= Vec2f((float(numDigits) * 4.0f), 0);
	lowerright += Vec2f((float(numDigits) * 4.0f), 0);

	GUI::DrawRectangle(upperleft, lowerright);
	GUI::SetFont("menu");
	GUI::DrawText(reqsText, upperleft + Vec2f(2, 1), color_white);
}

void ShootGun(CBlob@ this, f32 angle, Vec2f gunPos)
{
	if (isServer())
	{
		f32 sign = (this.isFacingLeft() ? -1 : 1);
		angle += ((XORRandom(400) - 100) / 100.0f);
		angle += this.getAngleDegrees();

		GunSettings@ settings;
		this.get("gun_settings", @settings);

		Vec2f fromBarrel = Vec2f((settings.MUZZLE_OFFSET.x + 5) * -sign, settings.MUZZLE_OFFSET.y);
		fromBarrel.RotateBy(this.getAngleDegrees());

		CBlob@ gunner = this.getAttachmentPoint(1).getOccupied();
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
		this.getSprite().PlaySound("minicopter_shoot.ogg", 2.00f);
	}

	this.set_u32("fireDelayGunSprite", getGameTime() + (shootDelay + 1)); //shoot delay increased to compensate for cmd time
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

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(8, 0).RotateBy(this.getAngleDegrees());
	ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void drawFuelCount(CBlob@ this)
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
	Vec2f upperleft((ul.x + (dist / 2.0f) - 10) + 4.0f, pos2d1.y + this.getHeight() + 30);
	Vec2f lowerright((ul.x + (dist / 2.0f) + 10), upperleft.y + 20);

	//GUI::DrawRectangle(upperleft - Vec2f(0,20), lowerright , SColor(255,0,0,255));

	int fuel = this.get_f32("fuel_count");
	string reqsText = "Fuel: " + fuel + " / " + this.get_f32("max_fuel");

	u8 numDigits = reqsText.size() - 1;

	upperleft -= Vec2f((float(numDigits) * 4.0f), 0);
	lowerright += Vec2f((float(numDigits) * 4.0f), 18);

	// GUI::DrawRectangle(upperleft, lowerright);
	GUI::SetFont("menu");
	GUI::DrawTextCentered(reqsText, this.getInterpolatedScreenPos() + Vec2f(0, 40), color_white);
}

void onDie(CBlob@ this)
{
	DoExplosion(this);

	if (isServer())
	{
		CBlob@ wreck = server_CreateBlobNoInit("minicopterwreck");
		wreck.setPosition(this.getPosition());
		wreck.setVelocity(this.getVelocity());
		wreck.setAngleDegrees(this.getAngleDegrees());
		wreck.server_setTeamNum(this.getTeamNum());
		wreck.Init();
	}
}

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}

	this.set_f32("map_damage_radius", 48.0f);
	this.set_f32("map_damage_ratio", 0.4f);
	f32 angle = this.get_f32("bomb angle");

	Explode(this, 100.0f, 50.0f);

	for (int i = 0; i < 4; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 40);
		LinearExplosion(this, dir, 40.0f + XORRandom(64), 48.0f, 6, 0.5f, Hitters::explosion);
	}

	Vec2f pos = this.getPosition() + this.get_Vec2f("explosion_offset").RotateBy(this.getAngleDegrees());
	CMap@ map = getMap();

	if (isServer())
	{
		for (int i = 0; i < (5 + XORRandom(5)); i++)
		{
			CBlob@ blob = server_CreateBlob("flame", -1, this.getPosition());
			blob.setVelocity(Vec2f(XORRandom(10) - 5, -XORRandom(10)));
			blob.server_SetTimeToDie(10 + XORRandom(5));
		}
	}

	if (isClient())
	{
		for (int i = 0; i < 40; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(angle, XORRandom(400) * 0.01f, 70), particles[XORRandom(particles.length)]);
		}
	}

	this.getSprite().Gib();
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 1 + XORRandom(200) * 0.01f, 2 + XORRandom(5), XORRandom(100) * -0.00005f, true);
}
