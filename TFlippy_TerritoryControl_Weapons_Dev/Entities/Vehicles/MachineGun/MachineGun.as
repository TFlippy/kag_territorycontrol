#include "Hitters.as";
#include "HittersTC.as";
#include "VehicleAttachmentCommon.as"

const Vec2f arm_offset = Vec2f(0, -3);
const u32 shootDelay = 3; // Ticks
const f32 damage = 2.5f;
const u16 max_ammo = 300;

const string ammo_blob = "mat_gatlingammo";

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");
	this.Tag("turret");

	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", "MachineGun_Top.png", 32, 8);

	if (arm !is null)
	{
		{
			Animation@ anim = arm.addAnimation("default", 0, true);
			int[] frames = {0};
			anim.AddFrames(frames);
		}
	
		{
			Animation@ anim = arm.addAnimation("shoot", 1, false);
			int[] frames = {0, 2, 1};
			anim.AddFrames(frames);
		}
		
		arm.SetOffset(arm_offset);
		arm.SetRelativeZ(5);
	}
	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("GUNNER");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_up);
	}

	this.getShape().SetRotationsAllowed(false);
	
	this.set_u16("ammo_count", 0);
	this.set_u32("fireDelay", 0);
	sprite.SetZ(-10.0f);
	
	this.addCommandID("load_ammo");
	
	this.getCurrentScript().runFlags |= Script::tick_hasattached;
}

void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("tracer");
	CSpriteLayer@ tracer = this.addSpriteLayer("tracer", "GatlingGun_Tracer.png" , 32, 1, this.getBlob().getTeamNum(), 0);

	if (tracer !is null)
	{
		Animation@ anim = tracer.addAnimation("default", 0, false);
		anim.AddFrame(0);
		tracer.SetRelativeZ(-2.0f);
		tracer.SetOffset(arm_offset);
		tracer.SetVisible(false);
		tracer.setRenderStyle(RenderStyle::additive);
	}
	
	this.SetEmitSound("MachineGun_Shoot.ogg");
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
	
	bool failed = true;

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
			else
			{
				this.SetFacingLeft(!facing_left);
			}
		}
	}

	return angle;
}

const f32 jitter = 2.5f;

void onTick(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("GUNNER");
	CSprite@ sprite = this.getSprite();
	
	if (this.get_bool("justShot"))
	{
		sprite.getSpriteLayer("tracer").SetVisible(false);
		this.set_bool("justShot", false);
	}
	
	if (ap !is null)
	{
		CBlob@ gunner = ap.getOccupied();
		if (gunner is null) return;
	
		f32 angle = getAimAngle(this);
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
		
		const bool a1_jr = ap.isKeyJustReleased(key_action1);
		const bool a1_p = ap.isKeyPressed(key_action1) && !ap.isKeyJustPressed(key_action1);
		
		const bool spinup = getGameTime() < this.get_u32("spinCooldown");
			
		sprite.SetEmitSoundPaused(!(a1_p && !spinup && GetAmmo(this) > 0));
		
		if (ap.isKeyJustPressed(key_up))
		{
			if (isServer())
			{
				gunner.server_DetachFrom(this);
			}
		}
		
		if (ap.isKeyJustPressed(key_action1))
		{
			// sprite.PlaySound("/Coilgun_Spinup.ogg", 1.00f, 1.00f);
			this.set_u32("spinCooldown", getGameTime() + 0);
		}
		else if (!spinup && a1_jr)
		{
			// sprite.PlaySound("/Coilgun_Spindown.ogg", 1.00f, 1.00f);
		}
					
		if (a1_p && !spinup && getGameTime() >= this.get_u32("shootCooldown"))
		{
			if (GetAmmo(this) > 0)
			{
				Shoot(this, angle + (XORRandom(100) / 100.00f * jitter) - (jitter * 0.50f));
			}
			else
			{
				sprite.PlaySound("EmptyFire.ogg", 1.00f, 1.00f);
			}
		}
	}
	else
	{
		sprite.SetEmitSoundPaused(true);
	}
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
	
	print("A: " + amount + "; R: " + remain);
	return remain;
}

u16 GetAmmo(CBlob@ this)
{
	return this.get_u16("ammo_count");
}

void Shoot(CBlob@ this, f32 angle)
{
	if (isClient()) this.getSprite().getSpriteLayer("arm").SetAnimation("shoot");

	angle = angle * (this.isFacingLeft() ? -1 : 1);
	
	bool flip = this.isFacingLeft();	
		
	Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
	Vec2f startPos = this.getPosition() + Vec2f(arm_offset.x * (flip ? 1 : -1), arm_offset.y);
	Vec2f endPos = startPos + dir * 800;
	Vec2f hitPos;
	f32 length;
	
	HitInfo@[] hitInfos;
	
	bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
	length = (hitPos - startPos).Length();
	
	bool blobHit = getMap().getHitInfosFromRay(startPos, angle + (flip ? 180.0f : 0.0f), length, this, @hitInfos);
		
	if (isClient())
	{
		DrawLine(this.getSprite(), startPos, length / 32, angle, this.isFacingLeft());
		ShakeScreen(128, 48, hitPos);	
	}
	
	if (isServer())
	{
		if (blobHit)
		{
			f32 falloff = 1;
			for (u32 i = 0; i < hitInfos.length; i++)
			{
				if (hitInfos[i].blob !is null)
				{	
					CBlob@ blob = hitInfos[i].blob;
					
					if ((blob.isCollidable() || blob.hasTag("flesh")) && blob.getTeamNum() != this.getTeamNum())
					{
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), damage * Maths::Max(0.1, falloff), HittersTC::railgun_lance);
						falloff = falloff * 0.5f;			
					}
				}
			}
		}
		
		if (mapHit)
		{
			CMap@ map = getMap();
			
			for (u32 i = 1; i < 3; i++)
			{
				Vec2f tpos = hitPos + (dir * i * 4);
				TileType tile =	map.getTile(tpos).type;
				
				if (!map.isTileBedrock(tile))
				{
					map.server_DestroyTile(tpos, damage / i);
				}
			}
		}
	}
	
	TakeAmmo(this, 1);
	this.set_u32("shootCooldown", getGameTime() + shootDelay);
	this.set_bool("justShot", true);
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
				if (remain == 0)
				{
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
	if (this is null) return;

	AttachmentPoint@ gunner = this.getBlob().getAttachments().getAttachmentPointByName("GUNNER");
	if (gunner !is null	&& gunner.getOccupied() !is null && gunner.getOccupied().isMyPlayer())
	{
		drawAmmoCount(this.getBlob());
	}
}

void drawAmmoCount(CBlob@ this)
{
	// draw ammo count
	Vec2f pos2d1 = this.getScreenPos() - Vec2f(0, 10);

	Vec2f pos2d = this.getScreenPos() - Vec2f(0, 60);
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

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}

void DrawLine(CSprite@ this, Vec2f startPos, f32 length, f32 angle, bool flip)
{
	CSpriteLayer@ tracer = this.getSpriteLayer("tracer");
	
	tracer.SetVisible(true);
	
	tracer.ResetTransform();
	tracer.ScaleBy(Vec2f(length, 1.0f));
	tracer.TranslateBy(Vec2f(length * 16.0f, 0.0f));
	tracer.RotateBy(angle + (flip ? 180 : 0), Vec2f());
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