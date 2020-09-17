#include "VehicleCommon.as"
#include "CargoAttachmentCommon.as"
#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              125, // move speed
	              0.20f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              true  // inventory access
	             );
	VehicleInfo@ v;
	
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
		
	this.set_f32("hit dmg modifier", 1.0f);//was 5.0
	this.set_f32("map dmg modifier", 2.0f);
	
	this.set_u32("lastHornTime", 0.0f);
	this.set_string("custom_explosion_sound", "KegExplosion");
	
	this.getShape().SetOffset(Vec2f(0, 8));
	
	this.Tag("blocks sword");
	this.Tag("ignore fall");
	
	Vehicle_SetupGroundSound(this, v, "car_engine_2", 1.0f, 1.0f);
	Vehicle_addWheel(this, v, "Tire.png", 16, 16, 0, Vec2f(-10.0f, 10.0f));
	Vehicle_addWheel(this, v, "Tire.png", 16, 16, 0, Vec2f(10.0f, 10.0f));
	
	AttachmentPoint@ driverpoint = this.getAttachments().getAttachmentPointByName("DRIVER");
	if (driverpoint !is null)
	{
		driverpoint.SetKeysToTake(key_action1);
	}
	
	this.getShape().SetRotationsAllowed(true);
	
	this.SetLight(true);
	this.SetLightColor(SColor(255, 255, 240, 200));
	this.SetLightRadius(100.5f);
}

void onTick(CBlob@ this)
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("DRIVER");
		CBlob@ driver = point.getOccupied();
		
		if (driver !is null)
		{
			if (point.isKeyPressed(key_action1) && this.get_u32("lastHornTime") < getGameTime())
			{
				this.getSprite().PlaySound("car_horn", 1.0f, 1.0f);
				this.set_u32("lastHornTime", getGameTime() + 15);
			}
		}

		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}

		Vehicle_StandardControls(this, v);
	}
}

bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}
void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _unused) {}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if (blob !is null)
	{
		TryToAttachCargo(this, blob);
		if(solid)
		{
			f32 vel_thresh =  1.0f;
			f32 dir_thresh =  0.25f;

			const f32 vellen = this.getShape().vellen;
			if (blob !is null && vellen > vel_thresh && blob.isCollidable())
			{
				Vec2f pos = this.getPosition();
				Vec2f vel = this.getVelocity();
				Vec2f other_pos = blob.getPosition();
				Vec2f direction = other_pos - pos;
				direction.Normalize();
				vel.Normalize();
				if (vel * direction > dir_thresh)
				{
					f32 power = vellen / 2;
					if (this.getTeamNum() != blob.getTeamNum())
					{
						this.server_Hit(blob, point1, vel, power, Hitters::flying, false);
						//print(power + " aa");
					}
				}
			}
		}
	}
}

void onDie(CBlob@ this)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;
	
	Explode(this, 32.0f, 4.0f);

	if (isServer())
	{
		CBlob@ blob = server_CreateBlob("carwreck", this.getTeamNum(), this.getPosition());
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.hasTag("vehicle") && this.getTeamNum() == byBlob.getTeamNum();
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum() ? blob.isCollidable() : false;
}