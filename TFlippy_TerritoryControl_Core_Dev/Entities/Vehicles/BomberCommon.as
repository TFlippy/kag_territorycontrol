#include "VehicleCommon.as";
#include "Hitters.as";
#include "Explosion.as";
#include "VehicleFuel.as";

// Boat logic

void onInit(CBlob@ this)
{
	this.Tag("aerial");

	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255,255,240,171));

	this.set_f32("map dmg modifier",35.0f);
	this.set_u32("lastDropTime",0);

	if (!this.exists("fuel_consumption_modifier")) this.set_f32("fuel_consumption_modifier", 1.00f);

	this.getSprite().SetEmitSound(this.exists("bomber_sound") ? this.get_string("bomber_sound") : "BomberLoop.ogg");

	this.addCommandID("load_fuel");
}

void onTick(CBlob@ this)
{
	//don't stop executing this when bomber is empty
	if (this.getHealth() > 1.0f)
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v)) return;

		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSoundPaused(false);
		sprite.SetEmitSoundVolume(0.3f + v.soundVolume);
		BomberHandling(this,v);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("load_fuel"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ carried = caller.getCarriedBlob();

		if (carried !is null)
		{
			string fuel_name = carried.getName();
			f32 fuel_modifier = 1.00f;
			bool isValid = false;

			fuel_modifier = GetFuelModifier(fuel_name, isValid, 0);

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

s32 getHeight(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();

	Vec2f point;
	if (map.rayCastSolidNoBlobs(pos, pos + Vec2f(0, 1000), point))
	{
		return Maths::Max((point.y - pos.y - 16) / 8.00f, 0);
	}
	else return map.tilemapheight + 50- pos.y / 8;
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

	/*upperleft -= Vec2f((float(numDigits) * 4.0f), 0);
	lowerright += Vec2f((float(numDigits) * 4.0f), 18);

	GUI::DrawRectangle(upperleft, lowerright);*/ //removed because annoying
	GUI::SetFont("menu");
	GUI::DrawTextCentered(reqsText, this.getInterpolatedScreenPos() + Vec2f(0, 40), color_white);

	// CMap@ map = getMap();
	// s32 landY = map.getLandYAtX(this.getPosition().x / 8.00f);
	// s32 height = Maths::Max(landY - (this.getPosition().y / 8.00f) - 2, 0);

	f32 height = getHeight(this);
	f32 taken = height / fuel_factor * this.get_f32("fuel_consumption_modifier") * (30.00f / 5.00f);

	// GUI::DrawRectangle(upperleft, lowerright);
	GUI::SetFont("menu");
	//GUI::DrawTextCentered("Altitude: " + height, this.getInterpolatedScreenPos() + Vec2f(0, 56), color_white);
	//GUI::DrawTextCentered("Consumption: " + taken + "/s", this.getInterpolatedScreenPos() + Vec2f(-8, 68), color_white);

	// GUI::DrawText("Therefore, you are unable to join another faction for " + secs + " " + units + "." ,
		// Vec2f(getScreenWidth() / 2 - 220.0f, getScreenHeight() / 3 + offset + 20.0f + Maths::Sin(getGameTime() / 5.0f) * 5.0f),
		// SColor(255, 255, 55, 55));
}

const f32 fuel_factor = 25.00f;

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null && this.get_f32("fuel_count") < this.get_f32("max_fuel"))
	{
		string fuel_name = carried.getName();
		bool isValid = fuel_name == "mat_wood" || fuel_name == "mat_coal" || fuel_name == "mat_oil" || fuel_name == "mat_fuel" || fuel_name == "mat_methane";

		if (isValid)
		{
			params.write_netid(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton("$" + fuel_name + "$", Vec2f(0, -8), this, this.getCommandID("load_fuel"), "Load " + carried.getInventoryName() + "\n(" + this.get_f32("fuel_count") + " / " + this.get_f32("max_fuel") + ")", params);
		}
	}
}

void onRender(CSprite@ this)
{
	if (this is null) return;

	AttachmentPoint@ pilot = this.getBlob().getAttachments().getAttachmentPointByName("FLYER");
	if (pilot !is null && pilot.getOccupied() !is null && pilot.getOccupied().isMyPlayer())
	{
		drawFuelCount(this.getBlob());
	}

	CBlob@ blob = this.getBlob();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	bool mouseOnBlob = (mouseWorld - blob.getPosition()).getLength() < this.getBlob().getRadius();
	f32 fuel = blob.get_f32("fuel_count");
	if (fuel <= 0 && mouseOnBlob)
	{
		Vec2f pos = blob.getInterpolatedScreenPos();

		GUI::SetFont("menu");
		GUI::DrawTextCentered("Requires fuel!", Vec2f(pos.x, pos.y + 85 + Maths::Sin(getGameTime() / 5.0f) * 5.0f), SColor(255, 255, 55, 55));
		GUI::DrawTextCentered("(Wood, Coal or Oil)", Vec2f(pos.x, pos.y + 105 + Maths::Sin(getGameTime() / 5.0f) * 5.0f), SColor(255, 255, 55, 55));
	}
}

void BomberHandling(CBlob@ this, VehicleInfo@ v)
{
	f32 fuel = GetFuel(this);
	if (fuel > 0)
	{
		if (this.getTickSinceCreated() % 5 == 0)
		{
			s32 height = getHeight(this);

			f32 taken = height / fuel_factor * this.get_f32("fuel_consumption_modifier");
			TakeFuel(this, taken);
		}
	}

	f32 fuelModifier = Maths::Min(fuel / 100.00f, 1.00f);

	// print("Y: " + landY + "; Height: " + height);

	AttachmentPoint@ driverSeat = this.getAttachments().getAttachmentPointByName("FLYER");
	if (driverSeat !is null)
	{
		CBlob@ blob = driverSeat.getOccupied();
		//Jumping out
		if (blob !is null)
		{
			if (blob.isMyPlayer() && driverSeat.isKeyJustPressed(key_up))
			{
				CBitStream params;
				params.write_u16(blob.getNetworkID());
				this.SendCommand(this.getCommandID("vehicle getout"), params);
				return;
			}
		}

		//Bombing
		if (!this.hasTag("disable bomber drop") && driverSeat.isKeyPressed(key_action3) && this.get_u32("lastDropTime") < getGameTime())
		{
			CInventory@ inv = this.getInventory();
			if (inv !is null)
			{
				u32 itemCount = inv.getItemsCount();

				if (isClient())
				{
					if (itemCount > 0)
					{ 
						this.getSprite().PlaySound("bridge_open", 1.0f, 1.0f);
					}
					else if (blob !is null && blob.isMyPlayer())
					{
						Sound::Play("NoAmmo");
					}
				}

				if (isServer())
				{
					if (itemCount > 0)
					{
						CBlob@ item = inv.getItem(0);
						u32 quantity = item.getQuantity();

						if (item.maxQuantity > 16)
						{
							// To prevent spamming 
							this.server_PutOutInventory(item);
							item.setPosition(this.getPosition());
						}
						else
						{
							CBlob@ dropped = server_CreateBlob(item.getName(), this.getTeamNum(), this.getPosition());
							dropped.server_SetQuantity(1);
							dropped.SetDamageOwnerPlayer(blob.getPlayer());
							dropped.Tag("no pickup");

							if (quantity - 1 > 0)
							{
								item.server_SetQuantity(quantity - 1);
							}
							else
							{
								item.server_Die();
							}
						}
					}
				}
				this.set_u32("lastDropTime",getGameTime()+30);
			}
		}
		//Handling
		const Vec2f vel = this.getVelocity();
		f32 moveForce = v.move_speed;
		f32 turnSpeed = v.turn_speed;

		Vec2f force;

		bool up    = driverSeat.isKeyPressed(key_action1);
		bool down  = driverSeat.isKeyPressed(key_action2);
		bool left  = driverSeat.isKeyPressed(key_left);
		bool right = driverSeat.isKeyPressed(key_right);

		bool fakeCrash = blob is null && !this.isOnGround() && !this.isInWater();
		if (fakeCrash)
		{
			up = false;
			down = true;
			if (Maths::Abs(vel.x) >= 0.5f)
			{
				left  = vel.x < 0.0f ? true : false;
				right = vel.x < 0.0f ? false : true;
			}
		}

		v.soundVolume = Maths::Clamp(Lerp(v.soundVolume,up ? 1.0f : (down ? 0.0f : (this.isOnGround() ? 0.0f : 0.15f)),(1.0f/getTicksASecond())*2.5f),0.0f,1.0f);
		float goalSpeed = fakeCrash ? -300.0f : ((up ? v.fly_speed : 0.0f) + (down ? -v.fly_speed / 2 : 310.15f));
		force.y = Lerp(v.fly_amount,goalSpeed, (1.0f / getTicksASecond()) * (fakeCrash ? 0.2f : 1.0f));
		v.fly_amount = force.y;

		if (left)
		{
			force.x -= moveForce;
			if (vel.x < -turnSpeed)
			{
				this.SetFacingLeft(true);
			}
		}

		if (right)
		{
			force.x += moveForce;
			if (vel.x > turnSpeed)
			{
				this.SetFacingLeft(false);
			}
		}

		if (fakeCrash)
		{
			if (Maths::Abs(vel.x) >= 0.5f)
			{
				force.x *= 1.1f;
			}
		}

		if (this.exists("gyromat_acceleration"))
		{
			force.x *= Maths::Sqrt(this.get_f32("gyromat_acceleration"));
		}

		this.AddForce(Vec2f(force.x * fuelModifier, -force.y * fuelModifier));
	}
}

void onCollision(CBlob@ this,CBlob@ blob,bool solid)
{
	float power = this.getOldVelocity().getLength();
	if (power > 1.5f && (solid ||(blob !is null && blob.isCollidable() && blob.getTeamNum() != this.getTeamNum() && this.doesCollideWithBlob(blob)))){
		if (isClient())
		{
			Sound::Play("WoodHeavyHit1.ogg",this.getPosition(),1.0f);
		}
		this.server_Hit(this,this.getPosition(),Vec2f(0,0),this.getAttachments().getAttachmentPointByName("FLYER") is null ? power*2.5f : power*0.6f,0,true);
	}
}

void onDie( CBlob@ this )
{
	//explode all bombs we dropped from inventory cuz of death
	CBlob@[] explosives;

	getBlobsByTag("explosive", @explosives);
	int eploSize = explosives.size();

	for (int i = 0;i < eploSize; i++)
	{
		CBlob@ b = explosives[i];

		float distance = (b.getPosition() - this.getPosition()).Length();

		if (distance < 1.0f)
		{
			b.Tag("DoExplode");
			b.server_Die();
		}
	}

	Sound::Play("WoodDestruct.ogg", this.getPosition(),1.0f);
	DoExplosion(this, this.getOldVelocity());

	AttachmentPoint@ driverSeat = this.getAttachments().getAttachmentPointByName("FLYER");
	if (driverSeat !is null)
	{
		CBlob@ blob = driverSeat.getOccupied();
		if (blob !is null)
		{
			blob.server_Die();
		}
	}
}

void DoExplosion(CBlob@ this,Vec2f velocity)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, velocity, DoExplosion);
		return;
	}

	Sound::Play("KegExplosion.ogg",this.getPosition(),1.0f);
	this.set_Vec2f("explosion_offset",Vec2f(0,-16).RotateBy(this.getAngleDegrees()));

	Explode(this,32.0f,3.0f);
	for (int i = 0; i < 16; i++)
	{
		Vec2f dir = Vec2f(1-i / 2.0f,-1+i / 2.0f);
		Vec2f jitter = Vec2f((XORRandom(200)-100) / 200.0f,(XORRandom(200)-100) / 200.0f);

		LinearExplosion(this,Vec2f(dir.x * jitter.x, dir.y * jitter.y), 16.0f + XORRandom(16), 10.0f, 4, 5.0f, Hitters::explosion);
	}
	this.getSprite().Gib();
}
void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge)
{
	//print("hello | hi :)");
}

bool Vehicle_canFire(CBlob@ this,VehicleInfo@ v,bool isActionPressed,bool wasActionPressed,u8 &out chargeValue)
{
	return true;
}
bool doesCollideWithBlob(CBlob@ this,CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_ground(this,blob) && !blob.hasTag("turret") && !blob.isAttached();
}
bool canBePickedUp(CBlob@ this,CBlob@ byBlob)
{
	return false;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	AttachmentPoint@ ap_pilot = this.getAttachments().getAttachmentPointByName("FLYER");

	if (ap_pilot !is null)
	{
		return ap_pilot.getOccupied() == null;
	}
	else return false;
}

void onAttach(CBlob@ this,CBlob@ attached,AttachmentPoint @attachedPoint)
{
	if (attached.hasTag("bomber")) return;

	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	Vehicle_onAttach(this,v,attached,attachedPoint);
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	if (detached.hasTag("bomber")) return;

	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))return;

	Vehicle_onDetach(this, v, detached, attachedPoint);
}
