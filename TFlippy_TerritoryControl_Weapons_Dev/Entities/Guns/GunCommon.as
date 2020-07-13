#include "Hitters.as";
#include "HittersTC.as";
#include "BulletCommon.as";
#include "MakeMat.as";

funcdef void AmmoOnHit(CBlob@ &in gun_blob, CBlob@ &in victim, Vec2f &in hit_pos, Vec2f &in dist, f32 &out damage, bool &out custom_hit, bool &out done);

namespace AmmoType
{
	shared enum ammo_types
	{
		none = 0,
		low_cal = 1,
		high_cal,
		shotgun,
		railgun
	};
}

class AmmoSettings
{
	f32 base_damage;
	SColor color;
	
	AmmoOnHit@ hook_onHit;
}

class GunSettings
{	
	bool automatic;

	u8 bullet_count;
	u8 shoot_delay;
	u8 ammo_type;
	u8 reload_time;

	u32 ammo_count_max;
	
	f32 recoil_modifier;
	f32 shake_modifier;
	f32 damage_modifier;
	f32 bullet_spread;
	f32 sound_reload_volume;
	f32 sound_reload_pitch;
	f32 sound_reload_range;
	
	Vec2f muzzle_offset;
	
	string sprite_muzzleflash;
	string sound_reload;
	string sound_empty;
	string[] shoot_sounds;
	
	GunSettings()
	{
		this.damage_modifier = 1;
	
		this.shoot_delay = 1;
		
		this.ammo_type = AmmoType::low_cal;
		this.ammo_count_max = 20;
		
		this.bullet_count = 1;
		this.bullet_spread = 0.00f;
		
		this.shake_modifier = 1.00f;
		this.recoil_modifier = 1.00f;
		
		this.muzzle_offset = Vec2f(0, 0);
	
		this.sound_empty = "Gun_Empty.ogg";
		this.sprite_muzzleflash = "MuzzleFlash.png";
	
		this.automatic = true;
	
		// this.blobname = blobname;
		// this.base_count = base_count;
		// this.bonus_count = bonus_count;
		// this.weight = weight;
	}
	
	string getRandomShootSound()
	{
		print("" + this.shoot_sounds.length);
	
		if (this.shoot_sounds !is null && this.shoot_sounds.length > 0) return shoot_sounds[XORRandom(shoot_sounds.length)];
		else return "";
	}
};

CBlob@ getAmmoBlob(CBlob@ this, u32&out quantity)
{
	quantity = 0;

	CInventory@ inv = this.getInventory();
	if (inv !is null && inv.getItemsCount() > 0)
	{
		CBlob@ item = inv.getItem(0);
		if (item !is null)
		{
			quantity = item.getQuantity();
			return item;
		}
	}
	
	return null;
}

bool takeAmmo(CBlob@ this, u32 count)
{
	CInventory@ inv = this.getInventory();
	if (inv !is null && inv.getItemsCount() > 0)
	{
		CBlob@ item = inv.getItem(0);
		if (item !is null)
		{
			s32 quantity = item.getQuantity();
			item.server_SetQuantity(Maths::Max(quantity - 1, 0));
			
			return true;
		}
	}
	
	return false;
}

bool takeAmmo(CBlob@ this, u32 count, CBlob@ passedBlob, CBlob@ &out item) // hacky work around, cant do &inout on cblob, maybe we can do engine change
{
	if (passedBlob is null)
	{
		CInventory@ inv = this.getInventory();
		if (inv !is null && inv.getItemsCount() > 0)
		{
			@item = inv.getItem(0);
			if (item !is null)
			{
				s32 quantity = item.getQuantity();
				item.server_SetQuantity(Maths::Max(quantity - 1, 0));
				
				return true;
			}
		}
	}
	
	if (passedBlob !is null)
	{
		s32 quantity = passedBlob.getQuantity();
		passedBlob.server_SetQuantity(Maths::Max(quantity - 1, 0));
		
		return true;
	}
	
	return false;
}

void client_Shoot(CBlob@ this, Vec2f pos_aim)
{
	if (isClient())
	{
		CRules@ rules = getRules();
		
		CBitStream stream;
		stream.write_netid(this.getNetworkID());
		stream.write_u32(getGameTime());
		stream.write_Vec2f(pos_aim);

		rules.SendCommand(rules.getCommandID("gun_shoot"), stream);
	}
}

void server_Shoot(CBlob@ this, Vec2f pos_aim)
{
	if (isServer())
	{
		CRules@ rules = getRules();

		CBitStream stream;
		stream.write_netid(this.getNetworkID());
		stream.write_u32(getGameTime());
		stream.write_Vec2f(pos_aim);

		rules.SendCommand(rules.getCommandID("gun_shoot"), stream);
	}
}