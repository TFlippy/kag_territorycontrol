#include "Hitters.as";
#include "HittersTC.as";
#include "BulletCommon.as";
#include "GunCommon.as";
#include "MakeMat.as";

void onInit(CRules@ this)
{
    this.addCommandID("gun_shoot");
	this.addCommandID("gun_reload");
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("gun_shoot"))
	{   
        CBlob@ blob = getBlobByNetworkID(params.read_netid());
        if (blob is null) return;

		u32 seed = params.read_u32();
		Vec2f source_pos = blob.getPosition() - blob.get_Vec2f("gun_muzzle_offset").RotateBy(blob.getAngleDegrees() + (blob.isFacingLeft() ? -180 : 0));				
		Vec2f target_pos = params.read_Vec2f();		
	
		AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
		if (point !is null)
		{
			CBlob@ holder =	point.getOccupied();
			if (holder !is null) @holder = blob;
			
			GunSettings@ settings;
			blob.get("gun_settings", @settings);
		
			Shoot(blob, holder, source_pos, target_pos, seed);
			
			if (isClient())
			{
				blob.set_u32("gun_shoot_next", getGameTime() + settings.shoot_delay);
			}
		}
	}
	else if (cmd == this.getCommandID("gun_reload"))
	{
        CBlob@ blob = getBlobByNetworkID(params.read_netid());
        if (blob is null) { return; }

		Reload(blob);
	}
}

void Shoot(CBlob@ this, CBlob@ holder, Vec2f source_pos, Vec2f target_pos_initial, u32 seed)
{
	const bool server = isServer();
	const bool client = isClient();
	
	CMap@ map = getMap();
	
	GunSettings@ settings;
	this.get("gun_settings", @settings);

	CBlob@ ammo;
	if (takeAmmo(this, 1, @ammo)) // why does this crash?
	{			
		Random@ random = Random(seed);
			
		const f32 damage_init = 1.00f * settings.damage_modifier;
		const u8 hitter_type = HittersTC::bullet_low_cal;
		const u8 bullet_count = settings.bullet_count;
		const f32 spread = settings.bullet_spread;
		
		for (u8 b = 0; b < bullet_count; b++)
		{
			Vec2f target_pos = target_pos_initial; // + Vec2f(spread * (random.NextFloat() - 0.50f), spread * (random.NextFloat() - 0.50f));
			Vec2f hit_pos = target_pos;
            Vec2f dir = (target_pos - source_pos);
			dir.RotateBy(spread * (random.NextFloat() - 0.50f));

			f32 length_target = dir.getLength();
            f32 length_max = 500.00f; // max range or something
			f32 length_rem = length_max;

            f32 angle = dir.getAngleDegrees();
			dir.Normalize();

			if (server)
			{
				f32 damage = damage_init;
				bool done = false;
			
				if (!done)
				{
					HitInfo@[] hitInfos_1;
					map.getHitInfosFromRay(source_pos, -angle, length_target, this, @hitInfos_1);
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

                                    length_rem -= length_target;
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
					map.getHitInfosFromRay(hit_pos, -angle, length_rem, this, @hitInfos_2);
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

                    length_rem = 0.00f;
				}
							
				if (!done)
				{
					hit_pos += (dir * (length_max - length_rem));
					
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
				createBullet(source_pos, hit_pos, SColor(200, 100, 255, 240), Vec2f(10.00f, 1.00f));
				// createBullet(source_pos, hit_pos, SColor(255, 255, 150, 50), Vec2f(4.00f, 0.50f));
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
		
		this.set_bool("gun_cycled", settings.automatic);
	}
	else
	{	
		this.set_bool("gun_cycled", false);
	
		if (client)
		{
			this.getSprite().PlaySound(settings.sound_empty, 0.50f, 1.00f);
		}
	}
	
	this.set_u32("gun_shoot_next", getGameTime() + settings.shoot_delay);
}



void Reload(CBlob@ this)
{
	this.set_bool("gun_cycled", true);

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

