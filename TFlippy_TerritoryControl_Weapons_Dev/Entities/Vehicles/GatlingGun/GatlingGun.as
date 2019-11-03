#include "VehicleCommon.as"
#include "Hitters.as";
#include "HittersTC.as";

// Mounted Bow logic


const Vec2f arm_offset = Vec2f(-4, 0);

const u32 shootDelay = 3; // Ticks
const f32 damage = 1.5f;

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
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_SetupWeapon(this, v,
	                    shootDelay, // fire delay (ticks)
	                    1, // fire bullets amount
	                    Vec2f(-6.0f, 2.0f), // fire position offset
	                    "mat_gatlingammo", // bullet ammo config name
						"", // fire position offset
	                    "GatlingGun-Shoot0", // fire sound
	                    "EmptyFire" // empty fire sound
	                   );
	v.charge = 400;
	// init arm + cage sprites
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", "GatlingGun_Barrel.png", 24, 16);

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
	}

	this.getShape().SetRotationsAllowed(false);
	this.set_string("autograb blob", "mat_gatlingammo");

	this.set_u32("fireDelay", 0);
	
	sprite.SetZ(-10.0f);
	
	
	this.getCurrentScript().runFlags |= Script::tick_hasattached;

	if (isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_gatlingammo");
		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo))
				ammo.server_Die();
		}
	}
}

void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("tracer");
	CSpriteLayer@ tracer = this.addSpriteLayer("tracer", "GatlingGun_Tracer.png" , 32, 1, this.getBlob().getTeamNum(), 0);

	if (tracer !is null)
	{
		Animation@ anim = tracer.addAnimation("default", 0, false);
		anim.AddFrame(0);
		tracer.SetRelativeZ(-1.0f);
		tracer.SetVisible(false);
		tracer.setRenderStyle(RenderStyle::additive);
	}
}

void onTick(CSprite@ this)
{
	if ((this.getBlob().get_u32("fireDelay") - (shootDelay - 1)) < getGameTime()) this.getSpriteLayer("tracer").SetVisible(false);
	
	CSpriteLayer@ arm = this.getSpriteLayer("arm");
	if (arm.isAnimationEnded())
	{
		arm.SetAnimation("default");
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

void onTick(CBlob@ this)
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30)
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}

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
	if(this.hasTag("invincible") && this.isAttached()){
		CBlob@ gunner=this.getAttachmentPoint(0).getOccupied();
		if(gunner !is null){
			gunner.Tag("invincible");
			gunner.Tag("invincibilityByVehicle");
		}
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{

	f32 hp = this.getHealth();
	f32 max_hp = this.getInitialHealth();
	int damframe = hp < max_hp * 0.4f ? 2 : hp < max_hp * 0.9f ? 1 : 0;
	CSprite@ sprite = this.getSprite();
	sprite.animation.frame = damframe;
	CSpriteLayer@ cage = sprite.getSpriteLayer("cage");
	if (cage !is null)
	{
		cage.animation.frame = damframe;
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

	if (isClient()) this.getSprite().getSpriteLayer("arm").SetAnimation("shoot");
	
	f32 angle = this.getAngleDegrees() + Vehicle_getWeaponAngle(this, v);
	angle = angle * (this.isFacingLeft() ? -1 : 1);
	angle += ((XORRandom(300) - 150) / 100.0f);
		
	Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
	Vec2f startPos = this.getPosition();
	Vec2f endPos = startPos + dir * 500;
	Vec2f hitPos;
	f32 length;
	
	bool flip = this.isFacingLeft();		
	HitInfo@[] hitInfos;
	
	bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
	length = (hitPos - startPos).Length();
	
	bool blobHit = getMap().getHitInfosFromRay(startPos, angle + (flip ? 180.0f : 0.0f), length, this, @hitInfos);
		
	if (isClient())
	{
		DrawLine(this.getSprite(), startPos, length / 32, angle, this.isFacingLeft());
		
		// Vec2f mousePos = getControls().getMouseScreenPos();
		// getControls().setMousePosition(Vec2f(mousePos.x, mousePos.y - 10));
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
						// print("Hit " + blob.getName() + " for " + damage * falloff);
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), damage * Maths::Max(0.1, falloff), HittersTC::bullet_high_cal);
						falloff = falloff * 0.5f;			
					}
				}
			}
		}
		
		if (mapHit)
		{
			CMap@ map = getMap();
			TileType tile =	map.getTile(hitPos).type;
			
			if (!map.isTileBedrock(tile) && tile != CMap::tile_ground_d0 && tile != CMap::tile_stone_d0)
			{
				map.server_DestroyTile(hitPos, damage * 0.125f);
			}
		}
	}
	
	this.set_u32("fireDelay", getGameTime() + shootDelay);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
	// return this.getTeamNum() == byBlob.getTeamNum();
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("fire raycast"))
	{
		const u8 charge = params.read_u8();
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}
		Vehicle_onFire(this, v, null, charge);
	}
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

	if(attached.getPlayer() !is null && this.hasTag("invincible")){
		if(this.isAttached()){
			attached.Tag("invincible");
			attached.Tag("invincibilityByVehicle");
		}
	}
}
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if(detached.hasTag("invincibilityByVehicle")){
		detached.Untag("invincible");
		detached.Untag("invincibilityByVehicle");
	}
}