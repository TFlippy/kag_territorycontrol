#include "Hitters.as";
#include "Explosion.as";

// const u32 fuel_timer_max = 30 * 600;
const f32 SPEED_MAX = 100;
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
	this.set_f32("max_fuel", 4000);
	this.set_f32("fuel_consumption_modifier", 2.00f);
}

void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("tracer");
	CSpriteLayer@ tracer = this.addSpriteLayer("tracer", "GatlingGun_Tracer.png", 32, 1, this.getBlob().getTeamNum(), 0);

	if (tracer !is null)
	{
		Animation@ anim = tracer.addAnimation("default", 0, false);
		anim.AddFrame(0);
		
		tracer.SetOffset(gun_offset);
		tracer.SetRelativeZ(-1.0f);
		tracer.SetVisible(false);
		tracer.setRenderStyle(RenderStyle::additive);
	}
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
				Shoot(this);
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
					
					if (getNet().isClient()) 
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
						if (getNet().isServer()) 
						{
							CBlob@ item = inv.getItem(0);
							u32 quantity = item.getQuantity();

							if (item.maxQuantity>8)
							{ 
								// To prevent spamming 
								this.server_PutOutInventory(item);
								item.setPosition(this.getPosition());
							}
							else
							{
								CBlob@ dropped = server_CreateBlob(item.getName(), this.getTeamNum(), this.getPosition());
								dropped.server_SetQuantity(1);
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
	
	if (getNet().isClient())
	{
		this.getSprite().SetEmitSoundSpeed(0.25f + (this.get_f32("velocity") / SPEED_MAX * 0.2f) * (this.getVelocity().Length() * 0.15f));
		
		if (hmod < 0.7 && u32(getGameTime() % 20 * hmod) == 0) ParticleAnimated(CFileMatcher(smokes[XORRandom(smokes.length)]).getFirst(), this.getPosition(), Vec2f(0, 0), float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 3 + XORRandom(4), XORRandom(100) * -0.001f, true);
	}
}

void Shoot(CBlob@ this)
{
	if (getGameTime() < this.get_u32("fireDelay")) return;

	f32 sign = (this.isFacingLeft() ? -1 : 1);
	f32 angleOffset = (15 * sign);
	f32 angle = this.getAngleDegrees() + ((XORRandom(200) - 100) / 100.0f) + angleOffset;
		
	Vec2f dir = Vec2f(sign, 0.0f).RotateBy(angle);
	
	Vec2f offset = gun_offset;
	offset.x *= -sign;
	
	Vec2f startPos = this.getPosition() + offset.RotateBy(angle);
	Vec2f endPos = startPos + dir * 500;
	Vec2f hitPos;
	
	bool flip = this.isFacingLeft();		
	HitInfo@[] hitInfos;
	
	bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
	f32 length = (hitPos - startPos).Length();
	
	bool blobHit = getMap().getHitInfosFromRay(startPos, angle + (flip ? 180.0f : 0.0f), length, this, @hitInfos);
		
	if (getNet().isClient())
	{
		DrawLine(this.getSprite(), startPos, length / 32, angleOffset, this.isFacingLeft());
		this.getSprite().PlaySound("GatlingGun-Shoot0", 1.00f, 1.00f);
		
		// Vec2f mousePos = getControls().getMouseScreenPos();
		// getControls().setMousePosition(Vec2f(mousePos.x, mousePos.y - 10));
	}
	
	if (getNet().isServer())
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
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), damage * Maths::Max(0.1, falloff), Hitters::arrow);
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

void DrawLine(CSprite@ this, Vec2f startPos, f32 length, f32 angle, bool flip)
{
	CSpriteLayer@ tracer = this.getSpriteLayer("tracer");
	
	tracer.SetVisible(true);
	
	tracer.ResetTransform();
	tracer.ScaleBy(Vec2f(length, 1.0f));
	tracer.TranslateBy(Vec2f(length * 16.0f, 0.0f));
	tracer.RotateBy(angle + (flip ? 180 : 0), Vec2f());
}

void onTick(CSprite@ this)
{
	if ((this.getBlob().get_u32("fireDelay") - (shootDelay - 1)) < getGameTime()) this.getSpriteLayer("tracer").SetVisible(false);
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
		if (getNet().isClient())
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
		
		for (int i = 0; i < 35; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(220) * 0.01f, 90), particles[XORRandom(particles.length)]);
		}
		
		this.Tag("exploded");
		this.getSprite().Gib();
	}

}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
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

void TakeFuel(CBlob@ this, f32 amount)
{
	f32 max_fuel = this.get_f32("max_fuel");
	this.set_f32("fuel_count", Maths::Max(0, Maths::Min(max_fuel, this.get_f32("fuel_count") - amount)));
	this.Sync("fuel_count", true);
}

f32 GiveFuel(CBlob@ this, f32 amount, f32 modifier)
{
	f32 max_fuel = this.get_f32("max_fuel");
	f32 remain = Maths::Max(0, s32(this.get_f32("fuel_count")) + s32(amount) - s32(max_fuel));

	this.set_f32("fuel_count", Maths::Max(0, Maths::Min(max_fuel, this.get_f32("fuel_count") + (amount * modifier))));	
	this.Sync("fuel_count", true);
	
	// print("A: " + amount + "; R: " + remain);
	return remain;
}

f32 GetFuel(CBlob@ this)
{
	return this.get_f32("fuel_count");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("load_fuel"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ carried = caller.getCarriedBlob();
		
		if (carried !is null)
		{
			string fuel_name = carried.getConfig();
			f32 fuel_modifier = 1.00f;
			bool isValid = false;
			
			if (fuel_name == "mat_wood")
			{
				fuel_modifier = 1.00f;
				isValid = true;
			}
			else if (fuel_name == "mat_coal")
			{
				fuel_modifier = 4.00f * 5.00f; // More coal than oil in a drum
				isValid = true;
			}
			else if (fuel_name == "mat_oil")
			{
				fuel_modifier = 3.00f * 5.00f;
				isValid = true;
			}
			else if (fuel_name == "mat_fuel")
			{
				fuel_modifier = 100.00f;
				isValid = true;
			}
			
			if (isValid)
			{
				u16 remain = GiveFuel(this, carried.getQuantity(), fuel_modifier);
					
				if (getNet().isServer())
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
	Vec2f upperleft((ul.x + (dist / 2.0f) - 10) + 4.0f, pos2d1.y + this.getHeight() + 30);
	Vec2f lowerright((ul.x + (dist / 2.0f) + 10), upperleft.y + 20);

	//GUI::DrawRectangle(upperleft - Vec2f(0,20), lowerright , SColor(255,0,0,255));

	f32 fuel = this.get_f32("fuel_count");
	string reqsText = "Fuel: " + fuel + " / " + this.get_f32("max_fuel");

	u8 numDigits = reqsText.length() - 1;

	upperleft -= Vec2f((float(numDigits) * 4.0f), 0);
	lowerright += Vec2f((float(numDigits) * 4.0f), 18);

	// GUI::DrawRectangle(upperleft, lowerright);
	GUI::SetFont("menu");
	GUI::DrawTextCentered(reqsText, this.getScreenPos() + Vec2f(0, 40), color_white);
				
	// CMap@ map = getMap();
	// s32 landY = map.getLandYAtX(this.getPosition().x / 8.00f);
	// s32 height = Maths::Max(landY - (this.getPosition().y / 8.00f) - 2, 0);

	f32 velocity = this.get_f32("velocity");
	f32 taken = velocity / fuel_factor * this.get_f32("fuel_consumption_modifier") * (30.00f / 5.00f);

	// GUI::DrawRectangle(upperleft, lowerright);
	GUI::SetFont("menu");
	GUI::DrawTextCentered("Speed: " + int(this.getVelocity().getLength() * 3.60f) + " km/h", this.getScreenPos() + Vec2f(0, 56), color_white);
	GUI::DrawTextCentered("Consumption: " + taken + "/s", this.getScreenPos() + Vec2f(-8, 68), color_white);
				
	// GUI::DrawText("Therefore, you are unable to join another faction for " + secs + " " + units + "." ,
		// Vec2f(getScreenWidth() / 2 - 220.0f, getScreenHeight() / 3 + offset + 20.0f + Maths::Sin(getGameTime() / 5.0f) * 5.0f),
		// SColor(255, 255, 55, 55));
}

const f32 fuel_factor = 100.00f;

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null && this.get_f32("fuel_count") < this.get_f32("max_fuel"))
	{
		string fuel_name = carried.getConfig();
		bool isValid = fuel_name == "mat_oil" || fuel_name == "mat_fuel";
		
		if (isValid)
		{
			params.write_netid(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton("$" + fuel_name + "$", Vec2f(12, 0), this, this.getCommandID("load_fuel"), "Load " + carried.getInventoryName() + "\n(" + this.get_f32("fuel_count") + " / " + this.get_f32("max_fuel") + ")", params);
		}
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
		Vec2f pos = blob.getScreenPos();
		
		GUI::SetFont("menu");
		GUI::DrawTextCentered("This vehicle requires fuel to fly!", Vec2f(pos.x, pos.y + 85 + Maths::Sin(getGameTime() / 5.0f) * 5.0f), SColor(255, 255, 55, 55));
		GUI::DrawTextCentered("(Oil)", Vec2f(pos.x, pos.y + 105 + Maths::Sin(getGameTime() / 5.0f) * 5.0f), SColor(255, 255, 55, 55));
	}
}
