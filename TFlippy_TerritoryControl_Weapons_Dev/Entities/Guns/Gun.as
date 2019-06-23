#include "Hitters.as";
#include "HittersTC.as";
#include "BulletCommon.as";
#include "GunCommon.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if(ap !is null) 
	{
		ap.SetKeysToTake(key_action1);
	}
	
	this.getShape().SetRotationsAllowed(true);
	this.Tag("no shitty rotation reset");
	this.Tag("weapon");
	this.Tag("hopperable");

	this.set_u32("gun_shoot_next", 0);
	this.set_f32("gun_recoil_current", 0);
	
	this.addCommandID("gun_shoot");
	this.addCommandID("gun_reload");
	
	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			CSpriteLayer@ flash = sprite.addSpriteLayer("muzzle_flash", (this.exists("gun_muzzleflash_sprite") ? this.get_string("gun_muzzleflash_sprite") : "MuzzleFlash.png"), 16, 8, this.getTeamNum(), 0);
			if (flash !is null)
			{
				Animation@ anim = flash.addAnimation("default", 1, false);
				anim.AddFrame(0);
				anim.AddFrame(1);
				anim.AddFrame(2);
				anim.AddFrame(3);
				anim.AddFrame(5);
				anim.AddFrame(6);
				anim.AddFrame(7);
				flash.SetRelativeZ(1.0f);
				flash.SetVisible(false);
				// flash.setRenderStyle(RenderStyle::additive);
				// flash.SetOffset(this.get_Vec2f("gun_muzzle_offset") + Vec2f(-16, -1));
			}
		}
	}
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		UpdateAngle(this);
		
		if (isClient())
		{
			this.set_f32("gun_recoil_current", lerp(this.get_f32("gun_recoil_current"), 0, 0.50f));
		}
		
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder =	point.getOccupied();
		
		const bool client = isClient();
		const bool server = isServer();
		const bool isLocal = holder.isMyPlayer();
				
		// if(holder is null)
		// {
			// if(soundFireLoop){
				// sprite.SetEmitSoundPaused(true);
				// this.set_bool("gun_soundFireLoopStarted",false);
			// }
			// return;
		// }
		
		CPlayer@ player = holder.getPlayer();
		if (player !is null && isLocal)
		{
			CControls@ controls = getControls();
		
			if (controls.isKeyJustPressed(KEY_KEY_R)) 
			{
				CBitStream stream;
				this.SendCommand(this.getCommandID("gun_reload"), stream);
			}
		}
				
		if ((point.isKeyPressed(key_action1) || holder.isKeyPressed(key_action1)) && !(holder.get_f32("babbyed") > 0)) 
		{
			if (getGameTime() >= this.get_u32("gun_shoot_next"))
			{
				u32 ammoCount = 0;
				CBlob@ ammo = getAmmoBlob(this, ammoCount);
			
				GunSettings@ settings;
				this.get("gun_settings", @settings);
			
				if (ammo !is null && ammoCount > 0)
				{			
					CBitStream stream;
					stream.write_u32(getGameTime());
					stream.write_Vec2f(this.getPosition());
					stream.write_Vec2f(holder.getAimPos());
					
					this.SendCommand(this.getCommandID("gun_shoot"), stream);
				}
				else if (point.isKeyJustPressed(key_action1) || holder.isKeyJustPressed(key_action1))
				{
					this.getSprite().PlaySound(settings.sound_empty, 0.50f, 1.00f);
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("gun_shoot"))
	{
		u32 seed = params.read_u32();
		Vec2f source_pos = params.read_Vec2f() - this.get_Vec2f("gun_muzzle_offset").RotateBy(this.getAngleDegrees() + (this.isFacingLeft() ? -180 : 0));				
		Vec2f target_pos = params.read_Vec2f();		
	
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point !is null)
		{
			CBlob@ holder =	point.getOccupied();
			if (holder !is null)
			{
				if (TakeAmmo(this, 1))
				{
					Shoot(this, holder, source_pos, target_pos, seed);
				}
			}
		}
	}
	else if (cmd == this.getCommandID("gun_reload"))
	{
		Reload(this);
	}
}

void Shoot(CBlob@ this, CBlob@ holder, Vec2f source_pos, Vec2f target_pos_initial, u32 seed)
{
	CMap@ map = getMap();
	
	GunSettings@ settings;
	this.get("gun_settings", @settings);

	this.set_u32("gun_shoot_next", getGameTime() + settings.shoot_delay);

	const bool server = isServer();
	const bool client = isClient();

	Random@ random = Random(seed);
		
	const f32 damage_init = 1.00f * settings.damage_modifier;
	const u8 hitter_type = HittersTC::bullet_low_cal;
	const u8 bullet_count = settings.bullet_count;
	const f32 spread = settings.bullet_spread;
	
	for (u8 b = 0; b < bullet_count; b++)
	{
		Vec2f target_pos = target_pos_initial + Vec2f(spread * (random.NextFloat() - 0.50f), spread * (random.NextFloat() - 0.50f));
		Vec2f hit_pos = target_pos;
		Vec2f dir = (target_pos - source_pos);
		f32 length = dir.getLength();
		f32 angle = dir.getAngleDegrees();
		dir.Normalize();

		if (server)
		{
			f32 damage = damage_init;
			bool done = false;
		
			if (!done)
			{
				HitInfo@[] hitInfos_1;
				map.getHitInfosFromRay(source_pos, -angle, length, this, @hitInfos_1);
				if (hitInfos_1 !is null)
				{
					for (int i = 0; i < hitInfos_1.length; i++)
					{
						if (!done)
						{
							HitInfo@ hit = hitInfos_1[i];
							if (hit !is null)
							{
								CBlob@ blob = hit.blob;
								if (blob !is null)
								{
									if (blob.getTeamNum() != holder.getTeamNum() && (blob.isCollidable() || blob.hasTag("flesh")) && !blob.hasTag("invincible"))
									{
										f32 health_before = blob.getHealth();
										holder.server_Hit(blob, hit.hitpos, dir, damage, hitter_type, false);
										
										hit_pos = hit.hitpos;
										damage = Maths::Max(damage - health_before, 0);
										if (damage <= 0) done = true;
									}
								}
								else
								{
									map.server_DestroyTile(hit.hitpos, damage);
									hit_pos = hit.hitpos;
									done = true;
								}
							}
						}
						else break;
					}
				}
			}
			
			if (!done)
			{
				CBlob@ blob = map.getBlobAtPosition(hit_pos);
				if (blob !is null && blob.getTeamNum() != holder.getTeamNum() && !blob.hasTag("invincible"))
				{
					f32 health_before = blob.getHealth();
					holder.server_Hit(blob, hit_pos, dir, damage, hitter_type, false);
					
					damage = Maths::Max(damage - health_before, 0);
					if (damage <= 0) done = true;
				}
			}
			
			if (!done)
			{
				map.rayCastSolidNoBlobs(source_pos, target_pos, hit_pos);
				
				Tile tile = map.getTile(hit_pos);
				if (tile.type != CMap::tile_empty)
				{
					if (server)
					{
						map.server_DestroyTile(hit_pos, damage);
						done = true;
					}
				}
			}
			
			if (!done)
			{
				HitInfo@[] hitInfos_2;
				map.getHitInfosFromRay(hit_pos, -angle, length, this, @hitInfos_2);
				if (hitInfos_2 !is null)
				{
					for (int i = 0; i < hitInfos_2.length; i++)
					{
						if (!done)
						{
							HitInfo@ hit = hitInfos_2[i];
							if (hit !is null)
							{
								CBlob@ blob = hit.blob;
								if (blob !is null)
								{
									if (blob.getTeamNum() != holder.getTeamNum() && (blob.isCollidable() || blob.hasTag("flesh")) && !blob.hasTag("invincible"))
									{
										f32 health_before = blob.getHealth();
										holder.server_Hit(blob, hit.hitpos, dir, damage, hitter_type, false);
										
										hit_pos = hit.hitpos;
										damage = Maths::Max(damage - health_before, 0);
										if (damage <= 0) done = true;
									}
								}
								else
								{
									hit_pos = hit.hitpos;
									map.server_DestroyTile(hit.hitpos, damage);
									done = true;
								}
							}
						}
						else break;
					}
				}
			}
						
			if (!done)
			{
				hit_pos += (dir * length);
				
				CBlob@ blob = map.getBlobAtPosition(hit_pos);
				if (blob !is null && blob.getTeamNum() != holder.getTeamNum() && !blob.hasTag("invincible"))
				{
					f32 health_before = blob.getHealth();
					holder.server_Hit(blob, hit_pos, dir, damage, hitter_type, false);
					
					damage = Maths::Max(damage - health_before, 0);
					if (damage <= 0) done = true;
				}
			}
		}
		
		if (client)
		{
			// #ff9d33 low cal
			
			// createBullet(source_pos, hit_pos, SColor(200, 100, 255, 240), Vec2f(6.00f, 0.75f));
			createBullet(source_pos, hit_pos, SColor(255, 255, 150, 50), Vec2f(4.00f, 0.50f));
		}
	}
				
	if (client)
	{
		ShakeScreen(Maths::Sqrt(damage_init * 100), 10, this.getPosition());	
		Sound::Play(settings.getRandomShootSound(), source_pos, 1, 1);
		
		Vec2f target_pos = target_pos_initial;
		Vec2f dir = (target_pos - source_pos);
		dir.Normalize();
		
		ShakeScreen(-dir * damage_init * 15.00f * settings.shake_modifier, 30, this.getPosition());
		
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			CSpriteLayer@ flash = sprite.getSpriteLayer("muzzle_flash");
			if (flash !is null)
			{
				flash.SetFrameIndex(0);
				flash.SetOffset(settings.muzzle_offset);
				flash.SetVisible(true);
			}
		}
		
		this.set_f32("gun_recoil_current", 2);
	}
}

void Reload(CBlob@ this)
{
	if (isServer())
	{
		GunSettings@ settings;
		this.get("gun_settings", @settings);

		s32 ammo_capacity = settings.ammo_count_max;
		s32 ammo_count = this.getBlobCount("mat_pistolammo");

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point !is null)
		{
			CBlob@ holder =	point.getOccupied();
			if (holder !is null)
			{
				CInventory@ inv = holder.getInventory();
				if (inv !is null)
				{
					u32 count = inv.getItemsCount();
					for (u32 i = 0; i < count; i++)
					{
						CBlob@ item = inv.getItem(i);
						if (item !is null && item.hasTag("ammo"))
						{
							s32 quantity = item.getQuantity();
							s32 taken = Maths::Min(quantity, Maths::Clamp(ammo_capacity - ammo_count, 0, ammo_capacity));
							
							// print("" + ammo_count + "/" + ammo_capacity + "; taking " + taken);
							
							item.server_SetQuantity(Maths::Max(quantity - taken, 0));
							MakeMat(this, this.getPosition(), item.getConfig(), taken);
							ammo_count += taken;
							
							if (ammo_count == ammo_capacity)
							{
								return;
							}
						}
					}
				}
			}
		}
	}
}


// bool HitBlob(CBlob@ this, CBlob@ holder, Vec2f dir, Vec2f hitPos, CBlob@ target, f32 &in damage_in, f32 &out damage_out)
// {
	// damage_out = damage_in;

	// if (target !is null && target.getTeamNum() != holder.getTeamNum() && (target.isCollidable() || target.hasTag("flesh")) && !target.hasTag("invincible"))
	// {
		// f32 health_before = target.getHealth();
		// holder.server_Hit(target, hitPos, dir, damage_in, this.get_u8("gun_hitter"), false);
		
		// damage_out = Maths::Max(damage_in - health_before, 0);
		// return damage_out <= 0;
	// }
	// else return false;
// }

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	attached.Tag("noLMB");
	attached.Tag("noRMB");
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	detached.Untag("noLMB");
	detached.Untag("noRMB");
}

void UpdateAngle(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point !is null)
	{
		CBlob@ holder = point.getOccupied();
		if (holder !is null)
		{
			Vec2f aimpos = holder.getAimPos();
			Vec2f pos = holder.getPosition();
			
			Vec2f dir = pos - aimpos;
			dir.Normalize();
			
			f32 mouseAngle = dir.getAngleDegrees();
			if (!holder.isFacingLeft()) mouseAngle += 180;

			this.setAngleDegrees(-mouseAngle);
			this.getSprite().SetOffset(Vec2f(this.get_f32("gun_recoil_current"), 0));
		}
	}
}

const float lerp(float v0, float v1, float t)
{
	return v0 + t * (v1 - v0);
}
