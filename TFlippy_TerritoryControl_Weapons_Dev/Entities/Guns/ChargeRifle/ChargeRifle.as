#include "Hitters.as";
#include "HittersTC.as";
#include "GunCommon.as";

void onInit(CBlob@ this)
{
	// GunInitRaycast(
		// this,
		// true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		// 4.00f,			//Weapon damage / projectile blob name
		// 500.0f,				//Weapon raycast range
		// 4,				//Weapon fire delay, in ticks
		// 3,					//Weapon clip size
		// 1.00f,				//Ammo usage factor, completely ignore for now
		// 20,				//Weapon reload time
		// false,				//If true, gun will be reloaded like a shotgun
		// 0,					//For shotguns: Additional delay to reload end
		// 2,					// Bullet count - for shotguns
		// 0.20f,				// Bullet Jitter
		// "mat_mithril",		//Ammo item blob name
		// false,				//If true, firing sound will be looped until player stops firing
		// SoundInfo("ChargeRifle_Shoot",4,1.5f,1.0f),		//Sound to play when firing
		// SoundInfo("ChargeRifle_Reload",1,1.5f,1.0f),	//Sound to play when reloading
		// SoundInfo("",0,1.5f,1.0f),	//Sound to play some time after firing
		// 0,					//Delay for the delayed sound, in ticks
		// Vec2f(-8.0f,2.0f)	//Visual offset for raycast bullets
	// );
	
	// this.set_string("gun_tracerName", "ChargeLance_Tracer.png");
	// this.set_u8("gun_hitter", HittersTC::plasma);
	
	
	const string[] shoot_sounds = { "ChargeRifle_Shoot1", "ChargeRifle_Shoot2", "ChargeRifle_Shoot3", "ChargeRifle_Shoot4" };
	
	GunSettings settings = GunSettings();
	settings.shoot_sounds = shoot_sounds;
	settings.shoot_delay = 4;
	settings.ammo_count_max = 3;
	settings.bullet_spread = 1.00f;
	settings.muzzle_offset = Vec2f(-15.0f, -1.00f);
	settings.automatic = false;
	settings.sprite_muzzleflash = "MuzzleFlash_Plasma.png";
	this.set("gun_settings", @settings);
}

// void onTick(CBlob@ this)
// {
	// GunTick(this);
// }