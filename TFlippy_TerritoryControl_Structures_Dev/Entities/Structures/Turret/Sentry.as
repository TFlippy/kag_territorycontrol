// Princess brain

#include "Hitters.as";
#include "HittersTC.as";
#include "Knocked.as";
#include "VehicleAttachmentCommon.as"
#include "DeityCommon.as"

const f32 radius = 128.0f;
const f32 damage = 5.00f;
const u32 delay = 90;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.set_f32("pickup_priority", 16.00f);
	this.getShape().SetRotationsAllowed(false);
	
	this.getCurrentScript().tickFrequency = 10;
	// this.getCurrentScript().runFlags |= Script::tick_not_ininventory;
	
	this.getSprite().SetZ(20);
	
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
	
	CSpriteLayer@ head = this.addSpriteLayer("head", "Sentry_Head.png", 24, 8);
	if (head !is null)
	{
		head.SetOffset(headOffset);
		head.SetRelativeZ(1.0f);
		head.SetVisible(true);
	}
	
	CSpriteLayer@ laser = this.addSpriteLayer("laser", "GatlingGun_Tracer.png", 8, 1);
	if (laser !is null)
	{
		Animation@ anim = laser.addAnimation("default", 0, false);
		anim.AddFrame(0);
		// laser.SetRelativeZ(-1.0f);
		laser.SetVisible(false);
		laser.setRenderStyle(RenderStyle::additive);
		laser.SetRelativeZ(-250.0f);
		laser.SetOffset(headOffset);
		// laser.SetOffset(Vec2f(-18.0f, 1.5f));
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getTeamNum() == this.getTeamNum() && GetAmmo(this) == 0;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if (this.getTeamNum() != forBlob.getTeamNum()) return false;

	CBlob@ carried = forBlob.getCarriedBlob();
	return (carried is null ? true : carried.getName() == "mat_gatlingammo");
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
		
		bool fired = false;
		
		if (index != -1)
		{
			this.getCurrentScript().tickFrequency = 1;
			CBlob@ target = blobs[index];
			
			if (target !is null)
			{
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
		if (t is null || !isVisible(this, t) || ((t.getPosition() - this.getPosition()).LengthSquared() > 450.00f*450.00f)) //if blob doesn't exist or gone out of tracking range or LoS
		{
			this.set_u16("target", 0); //then reset targetting
		}
		else
		{
			if (ammo > 0 && this.get_u32("next_shoot") < getGameTime())
			{
				fired = true;
			
				this.getSprite().PlaySound("Sentry_Shoot.ogg");
				this.set_u32("next_shoot", getGameTime() + 2);
				SetAmmo(this, ammo - 1);
			
				if (isServer())
				{
					this.server_Hit(t, t.getPosition(), Vec2f(0, 0), 0.50f, HittersTC::bullet_high_cal, true);
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

bool isVisible(CBlob@ blob, CBlob@ target)
{
	Vec2f col;
	return !getMap().rayCastSolidNoBlobs(blob.getPosition(), target.getPosition(), col);
}

void onTick(CSprite@ this)
{
	this.SetFacingLeft(false);
	CBlob@ blob = this.getBlob();
	if (blob.get_bool("security_state"))
	{
		if (isClient())
		{					
			CBlob@ target = getBlobByNetworkID(blob.get_u16("target"));
			if (target !is null)
			{
				blob.SetFacingLeft((target.getPosition().x - blob.getPosition().x) < 0);
			
				Vec2f dir = target.getPosition() - blob.getPosition();
				f32 length = dir.getLength();
				dir.Normalize();
				f32 angle = dir.Angle();
			
				CSpriteLayer@ head = this.getSpriteLayer("head");
				if (head !is null)
				{
					head.ResetTransform();
					head.RotateBy(-dir.Angle() + (this.isFacingLeft() ? 180 : 0), Vec2f());
				}
				
				CSpriteLayer@ laser = this.getSpriteLayer("laser");
				if (laser !is null)
				{
					laser.ResetTransform();
					laser.ScaleBy(Vec2f((length / 8.0f), 1.0f));
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
					head.RotateBy((Maths::Sin(blob.getTickSinceCreated() * 0.05f) * 20) + (this.isFacingLeft() ? 180 : 0), Vec2f());
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