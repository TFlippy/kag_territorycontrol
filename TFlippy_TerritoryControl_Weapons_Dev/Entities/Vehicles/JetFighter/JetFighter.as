#include "Hitters.as";
#include "Explosion.as";
#include "VehicleFuel.as";
#include "GunCommon.as";

// const u32 fuel_timer_max = 30 * 600;
const f32 SPEED_MAX = 100;
const f32 MAX_FUEL = 5000;
const Vec2f gun_offset = Vec2f(-30, 8.5);

const u32 shootDelay = 3; // Ticks
const f32 damage = 2.0f;

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

string[] smokes = 
{
	"LargeSmoke.png",
	"SmallSmoke1.png",
	"SmallSmoke2.png"
};

void onInit(CBlob@ this)
{
	GunSettings settings = GunSettings();

	settings.B_GRAV = Vec2f(0, 0.006); //Bullet Gravity
	settings.B_TTL = 11; //Bullet Time to live
	settings.B_SPEED = 70; //Bullet speed
	settings.B_DAMAGE = 2.0f; //Bullet damage
	settings.G_RECOIL = 0;
	settings.FIRE_SOUND = "GatlingGun-Shoot0.ogg";
	settings.MUZZLE_OFFSET = Vec2f(-38, 8.5); //Where muzzle flash and bullet spawn

	this.set("gun_settings", @settings);

	this.set_f32("velocity", 0.0f);
	
	this.set_string("custom_explosion_sound", "bigbomb_explosion.ogg");
	this.set_bool("map_damage_raycast", true);
	this.Tag("map_damage_dirt");
	
	this.Tag("vehicle");
	this.Tag("aerial");
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("JetFighter_Loop.ogg");
	sprite.SetEmitSoundSpeed(0.0f);
	sprite.SetEmitSoundPaused(false);

	this.getShape().SetRotationsAllowed(true);
	this.set_Vec2f("direction", Vec2f(0, 0));
	
	this.addCommandID("load_fuel");
	this.addCommandID("load_ammo");

	this.set_f32("max_fuel", 5000);
	this.set_f32("fuel_consumption_modifier", 1.00f);
}

void onTick(CBlob@ this)
{
	f32 fuel = GetFuel(this);
	if (fuel > 0)
	{
		if (this.getTickSinceCreated() % 5 == 0)
		{
			f32 velocity = this.get_f32("velocity");
			f32 taken = velocity / fuel_factor * this.get_f32("fuel_consumption_modifier") * (30.00f / 5.00f);
			
			TakeFuel(this, taken);
		}
	}
	
	f32 fuelModifier = Maths::Min(fuel / 100.00f, 1.00f);

	AttachmentPoint@ ap_pilot = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap_pilot !is null)
	{
		CBlob@ pilot = ap_pilot.getOccupied();
		
		if (pilot !is null && this.getHealth() > 10.00f)
		{
			Vec2f dir = pilot.getPosition() - pilot.getAimPos();
			const f32 len = dir.Length();
			dir.Normalize();
		
			// this.SetFacingLeft(dir.x > 0);
			this.SetFacingLeft(this.getVelocity().x < -0.5f);
			// const f32 ang = this.isFacingLeft() ? 0 : 180;
			// this.setAngleDegrees(ang - dir.Angle());
		
			bool pressed_w = ap_pilot.isKeyPressed(key_up);
			bool pressed_s = ap_pilot.isKeyPressed(key_down);
			bool pressed_lm = ap_pilot.isKeyPressed(key_action1);
			
			if (pressed_lm)
			{
				if (GetAmmo(this) > 0) Shoot(this);
			}
			
			// bool pressed_s = ap_pilot.isKeyPressed(key_down);
		
			if (pressed_w) 
			{
				this.set_f32("velocity", Maths::Min(SPEED_MAX, (this.get_f32("velocity") + 8.0f)) * fuelModifier);
			}
			
			if (pressed_s) 
			{
				this.set_f32("velocity", Maths::Min(SPEED_MAX, Maths::Max((this.get_f32("velocity") - 4.00f) * fuelModifier, 0)));
			}
			
			this.set_Vec2f("direction", dir);
			
			if (!this.hasTag("disable bomber drop") && ap_pilot.isKeyPressed(key_action3) && this.get_u32("lastDropTime") < getGameTime()) 
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
						else if (pilot.isMyPlayer())
						{
							Sound::Play("NoAmmo");
						}
					}
					
					if (itemCount > 0) 
					{
						if (isServer()) 
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
								dropped.SetDamageOwnerPlayer(pilot.getPlayer());
								dropped.Tag("no pickup");
								
								if (quantity > 0)
								{
									item.server_SetQuantity(quantity - 1);
								}
								if (item.getQuantity() == 0) 
								{
									item.server_Die();
								}
							}
						}
					}
					
					this.set_u32("lastDropTime",getGameTime() + 4);
				}
			}
		}		
	}
	else
	{
		this.set_f32("velocity", Maths::Max(0, (this.get_f32("velocity") - 1.00f) * fuelModifier));
	}

	const f32 hmod = this.getHealth() / this.getInitialHealth();
	const f32 v = this.get_f32("velocity");
	Vec2f d = this.get_Vec2f("direction");
	// Vec2f grav = Vec2f(0, 1) * 4 * (SPEED_MAX - v);
	
	this.AddForce(-d * v * hmod * fuelModifier);

	if (this.getVelocity().Length() > 1.00f && v > 0.25f) this.setAngleDegrees((this.isFacingLeft() ? 180 : 0) - this.getVelocity().Angle());
	else this.setAngleDegrees(0);
	
	if (isClient())
	{
		this.getSprite().SetEmitSoundSpeed(0.25f + (this.get_f32("velocity") / SPEED_MAX * 0.2f) * (this.getVelocity().Length() * 0.15f));
		
		if (hmod < 0.7 && u32(getGameTime() % 20 * hmod) == 0) ParticleAnimated(smokes[XORRandom(smokes.length)], this.getPosition(), Vec2f(0, 0), float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 3 + XORRandom(4), XORRandom(100) * -0.001f, true);
	}
}

void Shoot(CBlob@ this)
{
	if (getGameTime() < this.get_u32("fireDelay")) return;

	GunSettings@ settings;
	this.get("gun_settings", @settings);

	if (isServer())
	{
		// Angle shittery
		f32 angle = this.getAngleDegrees() + ((XORRandom(500) - 100) / 100.0f);

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
		this.getSprite().PlaySound(settings.FIRE_SOUND, 2.0f);

		CSpriteLayer@ flash = this.getSprite().getSpriteLayer("muzzle_flash");
		if (flash !is null)
		{
			//Turn on muzzle flash
			flash.SetFrameIndex(0);
			flash.SetVisible(true);
		}
	}

	TakeAmmo(this, 1);
	this.set_u32("fireDelay", getGameTime() + 3);
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

void TakeAmmo(CBlob@ this, u16 amount)
{
	this.set_u16("ammo_count", Maths::Max(0, Maths::Min(300, this.get_u16("ammo_count") - amount)));
	this.Sync("ammo_count", false);
}

u16 GiveAmmo(CBlob@ this, u16 amount)
{
	u16 remain = Maths::Max(0, s32(this.get_u16("ammo_count")) + s32(amount) - s32(300));

	this.set_u16("ammo_count", Maths::Max(0, Maths::Min(300, this.get_u16("ammo_count") + amount)));
	this.Sync("ammo_count", false);

	//print("A: " + amount + "; R: " + remain);
	return remain;
}

u16 GetAmmo(CBlob@ this)
{
	return this.get_u16("ammo_count");
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void onCollision(CBlob@ this,CBlob@ blob,bool solid)
{
	float power = this.getOldVelocity().getLength();
	if (power > 5.0f && blob == null)
	{
		if (isClient())
		{
			Sound::Play("WoodHeavyHit1.ogg", this.getPosition(), 1.0f);
		}

		this.server_Hit(this, this.getPosition(), Vec2f(0, 0), (this.getAttachments().getAttachmentPointByName("FLYER") is null || this.getHealth() < 10.0f) ? power * 2.5f : power * 0.0050f, 0, true);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
	if (point is null) return true;
		
	CBlob@ holder = point.getOccupied();
	if (holder is null) return true;
	else return false;
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}

	if (this.hasTag("exploded")) return;

	f32 random = XORRandom(40);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (80.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.50f);
	
	Explode(this, 40.0f + random, 25.0f);
	
	for (int i = 0; i < 10 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();
		
		LinearExplosion(this, dir, 16.0f + XORRandom(16) + (modifier * 8), 16 + XORRandom(24), 3, 2.00f, Hitters::explosion);
	}
	
	if(isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		this.Tag("exploded");
		this.getSprite().Gib();
	}

}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}

void onAttach(CBlob@ this,CBlob@ attached,AttachmentPoint @attachedPoint)
{
	if (attached.hasTag("bomber")) return;

	attached.Tag("invincible");
	attached.Tag("invincibilityByVehicle");
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	detached.Untag("invincible");
	detached.Untag("invincibilityByVehicle");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	AttachmentPoint@ ap_pilot = this.getAttachments().getAttachmentPointByName("PILOT");
	
	if (ap_pilot !is null)
	{
		return ap_pilot.getOccupied() == null;
	}
	else return true;
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
	else if (cmd == this.getCommandID("load_ammo"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ carried = caller.getCarriedBlob();

		if (carried !is null && carried.getName() == "mat_gatlingammo")
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

s32 getHeight(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();
	
	Vec2f point;
	if (map.rayCastSolidNoBlobs(pos, pos + Vec2f(0, 1000), point))
	{
		return Maths::Max((point.y - pos.y - 16) / 8.00f, 0);
	}
	else return 0;
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

	f32 fuel = this.get_f32("fuel_count");
	string reqsText = "Fuel: " + fuel + " / " + MAX_FUEL;

	u8 numDigits = reqsText.size() - 1;

	upperleft -= Vec2f((float(numDigits) * 4.0f), 0);
	lowerright += Vec2f((float(numDigits) * 4.0f), 18);

	// GUI::DrawRectangle(upperleft, lowerright);
	GUI::SetFont("menu");
	GUI::DrawTextCentered(reqsText, this.getInterpolatedScreenPos() + Vec2f(0, 40), color_white);
				
	// CMap@ map = getMap();
	// s32 landY = map.getLandYAtX(this.getPosition().x / 8.00f);
	// s32 height = Maths::Max(landY - (this.getPosition().y / 8.00f) - 2, 0);

	f32 velocity = this.get_f32("velocity");
	f32 taken = velocity / fuel_factor * this.get_f32("fuel_consumption_modifier") * (30.00f / 5.00f);

	// GUI::DrawRectangle(upperleft, lowerright);
	GUI::SetFont("menu");
	GUI::DrawTextCentered("Speed: " + int(this.getVelocity().getLength() * 3.60f) + " km/h", this.getInterpolatedScreenPos() + Vec2f(0, 56), color_white);
	GUI::DrawTextCentered("Consumption: " + taken + "/s", this.getInterpolatedScreenPos() + Vec2f(-8, 68), color_white);
				
	// GUI::DrawText("Therefore, you are unable to join another faction for " + secs + " " + units + "." ,
		// Vec2f(getScreenWidth() / 2 - 220.0f, getScreenHeight() / 3 + offset + 20.0f + Maths::Sin(getGameTime() / 5.0f) * 5.0f),
		// SColor(255, 255, 55, 55));
}

const f32 fuel_factor = 100.00f;

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null && this.get_f32("fuel_count") < MAX_FUEL)
	{
		string fuel_name = carried.getName();
		
		if (fuel_name == "mat_fuel")
		{
			params.write_netid(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton("$" + fuel_name + "$", Vec2f(12, 0), this, this.getCommandID("load_fuel"), "Load " + carried.getInventoryName() + "\n(" + this.get_f32("fuel_count") + " / " + MAX_FUEL + ")", params);
		}
	}
	if (GetAmmo(this) < 300 && carried !is null && carried.getName() == "mat_gatlingammo")
	{
		params.write_netid(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton("$icon_gatlingammo$", Vec2f(10, 0), this, this.getCommandID("load_ammo"), "Load " + carried.getInventoryName() + "\n(" + this.get_u16("ammo_count") + " / " + 300 + ")", params);
	}
}

void onRender(CSprite@ this)
{
	if (this is null) return;

	AttachmentPoint@ pilot = this.getBlob().getAttachments().getAttachmentPointByName("PILOT");
	if (pilot !is null	&& pilot.getOccupied() !is null && pilot.getOccupied().isMyPlayer())
	{
		drawFuelCount(this.getBlob());
	}
	
	CBlob@ blob = this.getBlob();
	f32 fuel = blob.get_f32("fuel_count");
	if (fuel <= 0)
	{
		Vec2f pos = blob.getInterpolatedScreenPos();
		
		GUI::SetFont("menu");
		GUI::DrawTextCentered("This vehicle requires fuel to fly!", Vec2f(pos.x, pos.y + 85 + Maths::Sin(getGameTime() / 5.0f) * 5.0f), SColor(255, 255, 55, 55));
		GUI::DrawTextCentered("(Fuel)", Vec2f(pos.x, pos.y + 105 + Maths::Sin(getGameTime() / 5.0f) * 5.0f), SColor(255, 255, 55, 55));
	}
}
