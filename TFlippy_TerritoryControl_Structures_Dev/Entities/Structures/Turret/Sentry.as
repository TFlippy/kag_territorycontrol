// Princess brain

#include "Hitters.as";
#include "Knocked.as";
#include "VehicleAttachmentCommon.as";
#include "DeityCommon.as";
#include "GunCommon.as";

const f32 radius = 128.0f;
const u32 delay = 90;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.Tag("medium weight");

	GunSettings settings = GunSettings();

	settings.B_GRAV = Vec2f(0, 0.005); //Bullet Gravity
	settings.B_TTL = 11; //Bullet Time to live
	settings.B_SPEED = 58; //Bullet speed
	settings.B_DAMAGE = 1.5f; //Bullet damage
	settings.MUZZLE_OFFSET = Vec2f(-19, -5); //Where muzzle flash and bullet spawn

	this.set("gun_settings", @settings);
	this.set_f32("CustomShootVolume", 1.0f);

	this.set_f32("pickup_priority", 16.00f);
	this.getShape().SetRotationsAllowed(false);

	this.getCurrentScript().tickFrequency = 60;
	// this.getCurrentScript().runFlags |= Script::tick_not_ininventory;

	this.set_u16("target", 0);
	this.set_u16("ammoCount", 0);
	this.set_bool("security_state", true);

	// this.SetLightRadius(48.0f);
	// this.SetLightColor(SColor(255, 255, 0, 0));

	if (isServer())
	{
		if (this.getTeamNum() == 250)
		{
			this.set_u16("ammoCount", 500);
		}
	}

	this.addCommandID("addAmmo");
	this.addCommandID("takeAmmo");
}

void onInit(CSprite@ this)
{
	// this.SetEmitSound("Zapper_Loop.ogg");
	// this.SetEmitSoundVolume(0.0f);
	// this.SetEmitSoundSpeed(0.0f);
	// this.SetEmitSoundPaused(false);
	this.SetZ(20);

	// Add head
	CSpriteLayer@ head = this.addSpriteLayer("head", "Sentry_Head.png", 24, 8);
	if (head !is null)
	{
		head.SetOffset(headOffset);
		head.SetRelativeZ(1.0f);
		head.SetVisible(true);
	}

	// Add muzzle flash
	CSpriteLayer@ flash = this.addSpriteLayer("muzzle_flash", "MuzzleFlash.png", 16, 8);
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
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getTeamNum() == this.getTeamNum();
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() == this.getTeamNum() && this.getDistanceTo(caller) <= 48)
	{
		{
			bool state = this.get_bool("security_state");
			CBitStream params;
			params.write_bool(!state);
			caller.CreateGenericButton((state ? 27 : 23), Vec2f(0, -7), this, 
				this.getCommandID("security_set_state"), getTranslatedString(state ? "OFF" : "ON"), params);
		}
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$icon_gatlingammo$", Vec2f(0, 0), this, 
				this.getCommandID("addAmmo"), getTranslatedString("Insert Gatling Gun Ammo"), params);
		}
		if (this.get_u16("ammoCount") > 0)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton(20, Vec2f(0, 7), this, 
				this.getCommandID("takeAmmo"), getTranslatedString("Take Gatling Gun Ammo"), params);
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

	Vec2f mouseWorld = getControls().getMouseWorldPos();
	bool mouseOnBlob = (mouseWorld - blob.getPosition()).getLength() < this.getBlob().getRadius();
	if (blob.getTeamNum() == localBlob.getTeamNum() && mouseOnBlob)
	{
		renderAmmo(blob);
	}
}

void renderAmmo(CBlob@ blob)
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

	u16 ammo = blob.get_u16("ammoCount");

	string reqsText = "" + ammo;

	u8 numDigits = reqsText.size();

	upperleft -= Vec2f((float(numDigits) * 4.0f), 0);
	lowerright += Vec2f((float(numDigits) * 4.0f), 0);

	GUI::DrawRectangle(upperleft, lowerright);
	GUI::SetFont("menu");
	GUI::DrawText(reqsText, upperleft + Vec2f(2, 1), color_white);
}

const Vec2f headOffset = Vec2f(0, -5);

void onTick(CBlob@ this)
{
	if (this.get_bool("security_state"))
	{
		u16 ammo = this.get_u16("ammoCount");
		if (ammo == 0) return;
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ attachedBlob = point.getOccupied();

		if (attachedBlob !is null && !attachedBlob.hasTag("vehicle")) return;

		Vec2f pos = this.getPosition();
		CMap@ map = getMap();

		CBlob@[] blobs;
		map.getBlobsInRadius(this.getPosition(), 400, @blobs);

		int index = -1;
		f32 s_dist = 900000.00f;
		u8 myTeam = this.getTeamNum();

		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			u8 team = b.getTeamNum();
			if (team == myTeam || !isVisible(this, b)) continue;

			f32 dist = (b.getPosition() - this.getPosition()).LengthSquared();

			if (dist < s_dist && b.hasTag("flesh") && !b.hasTag("dead"))
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
				this.getCurrentScript().tickFrequency = 4;

				if (target.getNetworkID() != this.get_u16("target"))
				{
					this.getSprite().PlaySound("Sentry_Found.ogg", 0.50f, 0.50f);
					// this.set_u32("next_shoot", getGameTime() + 2);
				}

				this.set_u16("target", target.getNetworkID());
			}
			CBlob@ t = getBlobByNetworkID(this.get_u16("target"));
			CPlayer@ host = this.getDamageOwnerPlayer();
			if (t !is null)
			{
				this.SetFacingLeft((t.getPosition().x - this.getPosition().x) < 0);

				CPlayer@ _target = t.getPlayer();
				if (host !is null && _target is host) //recognizes host and changes team
				{
					this.server_setTeamNum(_target.getBlob().getTeamNum());
					@t = null;
				}
			}
			if (t is null || !isVisible(this, t) || ((t.getPosition() - this.getPosition()).LengthSquared() > 450.00f * 450.00f) || t.hasTag("dead") || !t.isActive()) //if blob doesn't exist or gone out of tracking range or LoS
			{
				this.set_u16("target", 0); //then reset targetting
			}
			else
			{
				if (ammo > 0 && this.get_u32("next_shoot") < getGameTime())
				{
					if (t !is null)
					{
						Vec2f dir = t.getPosition() - (this.getPosition() - Vec2f(0, 3));
						dir.Normalize();
						f32 angle = -dir.Angle() + (this.isFacingLeft() ? 180 : 0);
						angle += ((XORRandom(400) - 200) / 100.0f);

						if (isServer())
						{
							GunSettings@ settings;
							this.get("gun_settings", @settings);

							// Muzzle
							Vec2f fromBarrel = Vec2f((settings.MUZZLE_OFFSET.x / 3) * (this.isFacingLeft() ? 1 : -1), settings.MUZZLE_OFFSET.y + 3);
							fromBarrel = fromBarrel.RotateBy(angle);

							// Fire!
							shootGun(this.getNetworkID(), angle, this.getNetworkID(), this.getPosition() + fromBarrel);
						}

						if (isClient())
						{
							this.getSprite().PlaySound("Sentry_Shoot.ogg", 1.0f);

							CSpriteLayer@ flash = this.getSprite().getSpriteLayer("muzzle_flash");
							if (flash !is null)
							{
								//Turn on muzzle flash
								flash.SetFrameIndex(0);
								flash.SetVisible(true);
							}
						}
					}

					this.set_u32("next_shoot", getGameTime() + 3);
					if (this.getTeamNum() != 250)
					{
						this.sub_u16("ammoCount", 1);
						if (isServer()) this.Sync("ammoCount", true);
					}
				}
			}
		}
		else
		{
			this.getCurrentScript().tickFrequency = 30;
		}
	}
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
	else if (cmd == this.getCommandID("addAmmo"))
	{

		//mat_gatlingammo
		u16 blobNum = 0;
		if (!params.saferead_u16(blobNum))
		{
			warn("addAmmo");
			return;
		}
		CBlob@ blob = getBlobByNetworkID(blobNum);
		if (blob is null) return;

		CInventory@ invo = blob.getInventory();
		if (invo !is null)
		{
			int ammoCount = invo.getCount("mat_gatlingammo");

			if (ammoCount > 0)
			{
				this.Sync("ammoCount", true);
				this.add_u16("ammoCount", ammoCount);
				this.Sync("ammoCount", true);
				invo.server_RemoveItems("mat_gatlingammo", ammoCount);
			}
		}

		CBlob@ attachedBlob = blob.getAttachments().getAttachmentPointByName("PICKUP").getOccupied();
		if (attachedBlob !is null && attachedBlob.getName() == "mat_gatlingammo")
		{
			this.add_u16("ammoCount", attachedBlob.getQuantity());
			attachedBlob.server_Die();
		}

	}
	else if (cmd == this.getCommandID("takeAmmo"))
	{
		u16 ammo = Maths::Min(this.get_u16("ammoCount"), 500);
		if (ammo > 0)
		{
			this.sub_u16("ammoCount", ammo);
			if (isServer()) server_CreateBlob("mat_gatlingammo", -1, getBlobByNetworkID(params.read_u16()).getPosition()).server_SetQuantity(ammo);
		}
	}
}

bool isVisible(CBlob@ this, CBlob@ target)
{
	//Anti spawn killing
	CBlob@[] spawns;
	getBlobsByName("ruins", @spawns);
	getBlobsByTag("faction_base", @spawns);

	for (int i = 0; i < spawns.length; i++)
	{
		CBlob@ spawn = spawns[i];
		if (spawn.get_bool("isActive") && spawn.getTeamNum() != this.getTeamNum())
		{
			if (target.isOverlapping(spawn) && target.getTeamNum() > 6 && target.getTeamNum() < 250)
			{
				return false;
			}
		}
	}

	//Is blob visible?
	Vec2f col;
	return !getMap().rayCastSolidNoBlobs(this.getPosition(), target.getPosition(), col);
}

void onTick(CSprite@ this)
{
	//this.SetFacingLeft(false);
	CBlob@ blob = this.getBlob();
	if (blob.get_bool("security_state"))
	{
		if (isClient())
		{
			CBlob@ target = getBlobByNetworkID(blob.get_u16("target"));
			if (target !is null)
			{
				//blob.SetFacingLeft((target.getPosition().x - blob.getPosition().x) < 0);

				Vec2f dir = target.getPosition() - blob.getPosition() + Vec2f(0, 3);
				dir.Normalize();
				f32 angle = dir.Angle();

				CSpriteLayer@ head = this.getSpriteLayer("head");
				if (head !is null)
				{
					head.ResetTransform();
					head.SetFacingLeft((target.getPosition().x - blob.getPosition().x) < 0);
					head.RotateBy(-angle + (head.isFacingLeft() ? 180 : 0), Vec2f());
				}

				CSpriteLayer@ flash = this.getSpriteLayer("muzzle_flash");
				if (flash !is null)
				{
					GunSettings@ settings;
					blob.get("gun_settings", @settings);

					flash.ResetTransform();
					flash.SetRelativeZ(1.0f);
					flash.SetFacingLeft((target.getPosition().x - blob.getPosition().x) > 0);
					flash.RotateBy(-angle + (flash.isFacingLeft() ? 180 : 0), Vec2f(settings.MUZZLE_OFFSET.x, 0) * (flash.isFacingLeft() ? 1 : -1));
				}
			}
			else
			{
				CSpriteLayer@ head = this.getSpriteLayer("head");
				if (head !is null)
				{
					head.ResetTransform();
					head.SetFacingLeft(blob.isFacingLeft());
					head.RotateBy((Maths::Sin(blob.getTickSinceCreated() * 0.05f) * 20), Vec2f());
				}
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}

void onDie(CBlob@ this)
{
	u16 ammo = this.get_u16("ammoCount");
	if (ammo <= 0) return;

	if (isServer()) server_CreateBlob("mat_gatlingammo", -1, this.getPosition()).server_SetQuantity(Maths::Min(ammo, 5000));
}