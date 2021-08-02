// Princess brain

#include "Hitters.as";
#include "Knocked.as";
#include "VehicleAttachmentCommon.as";
#include "DeityCommon.as";
#include "GunCommon.as";
#include "BulletCase.as";

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
	settings.B_DAMAGE = 0.5f; //Bullet damage
	settings.MUZZLE_OFFSET = Vec2f(-19, -5); //Where muzzle flash and bullet spawn

	this.set("gun_settings", @settings);

	this.set_f32("pickup_priority", 16.00f);
	this.getShape().SetRotationsAllowed(false);

	this.getCurrentScript().tickFrequency = 10;
	// this.getCurrentScript().runFlags |= Script::tick_not_ininventory;

	this.set_u16("target", 0);

	// this.SetLightRadius(48.0f);
	// this.SetLightColor(SColor(255, 255, 0, 0));

	if (isServer())
	{
		if (this.getTeamNum() == 250)
		{
			CBlob@ ammo = server_CreateBlob("mat_gatlingammo", this.getTeamNum(), this.getPosition());
			ammo.server_SetQuantity(500);
			this.server_PutInInventory(ammo);
		}
	}

	this.set_bool("security_state", true);
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
	return byBlob.getTeamNum() == this.getTeamNum() && GetAmmo(this) == 0;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if (this.getTeamNum() != forBlob.getTeamNum()) return false;

	CBlob@ carried = forBlob.getCarriedBlob();
	return (carried is null ? true : carried.getName() == "mat_gatlingammo" && !forBlob.isAttached());
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

const Vec2f headOffset = Vec2f(0, -5);

void onTick(CBlob@ this)
{
	if (this.get_bool("security_state"))
	{
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

			f32 dist = (b.getPosition() - this.getPosition()).LengthSquared();

			if (myTeam == 250 && b.get_u8("deity_id") == Deity::foghorn) continue;
			if (team != myTeam && dist < s_dist && b.hasTag("flesh") && !b.hasTag("dead") && isVisible(this, b))
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
				this.getCurrentScript().tickFrequency = 1;

				if (target.getNetworkID() != this.get_u16("target"))
				{
					this.getSprite().PlaySound("Sentry_Found.ogg", 1.00f, 1.00f);
					// this.set_u32("next_shoot", getGameTime() + 2);
				}

				this.set_u16("target", target.getNetworkID());
			}
		}
		else
		{
			this.getCurrentScript().tickFrequency = 10;
		}

		int ammo = GetAmmo(this);

		CBlob@ t = getBlobByNetworkID(this.get_u16("target"));
		CPlayer@ host = this.getDamageOwnerPlayer();
		if (t !is null)
		{
			this.SetFacingLeft((t.getPosition().x - this.getPosition().x) < 0);

			CPlayer@ _target = t.getPlayer();
			if (host !is null && _target is host) //recognizes host and changes team
			{
				this.server_setTeamNum(_target.getTeamNum());
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
						this.getSprite().PlaySound("Sentry_Shoot.ogg", 2.0f);
						ParticleCase2("GatlingCase.png", this.getPosition(), this.isFacingLeft() ? -dir.Angle() : angle);

						CSpriteLayer@ flash = this.getSprite().getSpriteLayer("muzzle_flash");
						if (flash !is null)
						{
							//Turn on muzzle flash
							flash.SetFrameIndex(0);
							flash.SetVisible(true);
						}
					}
				}

				this.set_u32("next_shoot", getGameTime() + 2);
				SetAmmo(this, ammo - 1);
			}
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
