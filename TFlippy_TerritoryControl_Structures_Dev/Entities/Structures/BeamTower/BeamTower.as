// A script by TFlippy & Pirate-Rob

#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";
#include "Requirements.as";
#include "ShopCommon.as";

const Vec2f offset = Vec2f(0, -28);
const u32 fire_delay = 30;
const f32 color_fade = 0.90f;

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-40); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 1;
	this.set_f32("beam_scale", 1);
	this.sendonlyvisible = false;
	
	this.addCommandID("beam_fire");
	this.addCommandID("beam_fire_signal");
	
	this.set_Vec2f("shop offset", Vec2f(0, 20));
	this.set_Vec2f("shop menu size", Vec2f(1, 1));
	this.set_string("shop description", "Solar Death Ray Tower");
	this.set_u8("shop icon", 15);

	this.set_bool("map_damage_raycast", true);
	this.Tag("map_damage_dirt");
	this.Tag("map_destroy_ground");
	
	{
		ShopItem@ s = addShopItem(this, "Solar Death Ray Targeting Device", "$icon_beamtowertargeter$", "beamtowertargeter", "Targeting device for a Solar Death Ray Tower.");
		AddRequirement(s.requirements, "coin", "", "Coins", 400);

		s.spawnNothing = true;
	}
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ beam = this.addSpriteLayer("beam", "BeamTower_Beam.png", 4, 4);
	if (beam !is null)
	{
		Animation@ anim = beam.addAnimation("default", 0, false);
		anim.AddFrame(0);
		beam.SetVisible(false);
		beam.setRenderStyle(RenderStyle::additive);
		beam.SetRelativeZ(-1.0f);
		beam.SetLighting(false);
		beam.SetOffset(offset);
	}
}

void onTick(CBlob@ this)
{
	if (isClient())
	{
		if (getGameTime() > (this.get_u32("last_shoot_time") + 2))
		{
			CSpriteLayer@ beam = this.getSprite().getSpriteLayer("beam");
			if (beam !is null)
			{
				beam.SetVisible(false);
			}
		}
	}
}

void Shoot(CBlob@ this, f32 power, Vec2f dir)
{
	if (getGameTime() >= (this.get_u32("last_shoot_time") + fire_delay))
	{				
		if (power > 0.50f)
		{
			CMap@ map = getMap();
		
			f32 dist = 10000;
			f32 angle = dir.Angle();
			
			Vec2f sourcePosition = this.getPosition() + offset;
			Vec2f targetPosition = sourcePosition + dir * 10000;
			Vec2f hitPosition;
			
			HitInfo@[] hitInfos;
			map.getHitInfosFromRay(sourcePosition, -angle, dist, this, hitInfos);
			
			if (hitInfos.length > 0)
			{
				u8 team = this.getTeamNum();
				bool done = false;
				
				for (int i = 0; i < hitInfos.length; i++)
				{
					HitInfo@ hitInfo = hitInfos[i];
					
					CBlob@ blob = hitInfo.blob;
					if (blob !is null)
					{
						if (!blob.hasTag("invincible"))
						{
							if (isServer())
							{
								f32 damage = power * (1.00f / Maths::Pow((hitInfo.distance / 1024.00f) + 1, 2));
								this.server_Hit(blob, blob.getPosition(), dir, damage * 20, HittersTC::plasma, true);
							}
							
							done = true;
						}
					}
					else
					{
						done = true;
					}
					
					if (done)
					{
						hitPosition = hitInfo.hitpos;
						dist = hitInfo.distance;
					}
				}
			}
	
			f32 falloff = 1.00f / Maths::Pow((dist / 1024.00f) + 1, 2);
			
			f32 power_clamped = Maths::Clamp(power, 0, 1);
			f32 power_falloff = power * falloff;
			f32 power_falloff_clamped = Maths::Clamp(power_falloff, 0, 1);
			f32 power_falloff_sqrt = Maths::Sqrt(power_falloff);
			
			// print("" + falloff);
			
			if (isClient())
			{
				CSpriteLayer@ beam = this.getSprite().getSpriteLayer("beam");
				if (beam !is null)
				{
					f32 scale = Maths::Sqrt(power);
					f32 initial_scale = this.get_f32("beam_scale");
					if (initial_scale == 0) initial_scale = 1;
				
					beam.ResetTransform();
					beam.ScaleBy(Vec2f((dist / 4.0f) / initial_scale, (1.00f / initial_scale) * scale));
					beam.TranslateBy(Vec2f((dist / 2), 0));
					beam.RotateBy(-angle, Vec2f());
					beam.SetVisible(true);
					beam.SetColor(SColor(255, 255 * power_clamped, 255 * power_clamped, 255 * power_clamped));
						
					this.set_f32("beam_scale", scale);
					this.getSprite().PlaySound("BeamTower_Shoot.ogg", 1, 1);
				}
				
				Sound::Play("ShockMine_explode.ogg", hitPosition, 0.50f, 1.50f);
			}
			
			this.set_u32("last_shoot_time", getGameTime());
			
			
			this.set_f32("map_damage_radius", power_falloff_sqrt * 16);
			this.set_f32("map_damage_ratio", 0.50f);
			this.set_Vec2f("explosion_offset", (hitPosition - this.getPosition()));
							
			// print("base power: " + power + "; power falloff: " + power_falloff + "; clamped power: " + power_clamped + "; dist: " + dist + "; falloff: " + falloff);
				
			if (power_falloff > 0.50f)
			{
				Explode(this, power_falloff_sqrt * 16, power_falloff);
			}
			
			if (isServer())
			{
				for (int i = 0; i < (power_falloff * 3); i++)
				{
					map.server_setFireWorldspace(hitPosition + getRandomVelocity(0, XORRandom(Maths::Pow(power_falloff, 2)), 360), true);
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("beam_fire_signal"))
	{		
		if (isServer())
		{
			Vec2f pos = params.read_Vec2f();
			Vec2f dir = pos - (this.getPosition() + offset);
			dir.Normalize();
			
			u16 netid = this.getNetworkID();
			f32 power = 0;

			CBlob@[] blobs;
			getBlobsByName("beamtowermirror", @blobs);

			for (int i = 0; i < blobs.length; i++)
			{
				CBlob@ blob = blobs[i];
				if (blob !is null)
				{
					if (blob.get_u16("tower_netid") == netid)
					{
						power += blob.get_f32("power");
					}
				}
			}
			
			CBitStream stream;
			stream.write_f32(power);
			stream.write_Vec2f(dir);
			this.SendCommand(this.getCommandID("beam_fire"), stream);
		}
	}
	else if (cmd == this.getCommandID("beam_fire"))
	{
		f32 power = params.read_f32();
		Vec2f dir = params.read_Vec2f();
	
		Shoot(this, power, dir);
	}
	else if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		if (callerBlob is null) return;

		if (isServer())
		{
			CPlayer@ ply = callerBlob.getPlayer();
			if (ply !is null)
			{
				tcpr("[PBI] " + ply.getUsername() + " has purchased " + name);
			}
		
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				CBlob@ mat = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlobNoInit("beamtowertargeter");
				blob.setPosition(this.getPosition());
				blob.set_u16("tower_netid", this.getNetworkID());
				blob.server_setTeamNum(this.getTeamNum());
				blob.Init();
				
				if (blob is null && callerBlob is null) return;

				if (!blob.hasTag("vehicle"))
				{
					if (!blob.canBePutInInventory(callerBlob))
					{
						callerBlob.server_Pickup(blob);
					}
					else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
					{
						callerBlob.server_PutInInventory(blob);
					}
				}
			}
		}
	}
}