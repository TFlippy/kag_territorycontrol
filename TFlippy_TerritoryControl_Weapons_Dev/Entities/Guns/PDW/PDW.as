#include "Hitters.as";
#include "HittersTC.as";

void onInit(CBlob@ this)
{
	// GunInitRaycast(
		// this,
		// true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		// 1.15f,				//Weapon damage / projectile blob name
		// 500.0f,				//Weapon raycast range
		// 2,					//Weapon fire delay, in ticks
		// 30,					//Weapon clip size
		// 1.00f,				//Ammo usage factor, completely ignore for now
		// 45,					//Weapon reload time
		// false,				//If true, gun will be reloaded like a shotgun
		// 0,					//For shotguns: Additional delay to reload end
		// 1,					//Bullet count - for shotguns
		// 0.50f,				//Bullet Jitter
		// "mat_pistolammo",	//Ammo item blob name
		// false,				//If true, firing sound will be looped until player stops firing
		// SoundInfo("PDW_Shoot", 0, 0.70f, 1.00f),	//Sound to play when firing
		// SoundInfo("SMGReload", 1, 1.00f, 0.90f),	//Sound to play when reloading
		// SoundInfo(),						//Sound to play some time after firing
		// 0,					//Delay for the delayed sound, in ticks
		// Vec2f(-8.0f, -0.50f)	//Visual offset for raycast bullets
	// );
	
	// this.set_u8("gun_shoot_delay", 2);
	
	
	this.set_u8("gun_shoot_delay", 3);
	
	this.set_u8("gun_bullet_count", 1);
	this.set_f32("gun_bullet_spread", 4);
	this.set_Vec2f("gun_muzzle_offset", Vec2f(-8.0f, -0.50f));
	
	this.set_string("gun_shoot_sound", "PDW_Shoot");
	
	
	this.set_u8("gun_hitter", HittersTC::bullet_low_cal);
}

// void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
// {
	// if (cmd == this.getCommandID("gun_shoot"))
	// {
		// print("bam");
	// }
// }

// class BaseTest
// {
	// string getSound()
	// {
		// return "";
	// }
// }

// class Test: BaseTest
// {
	// string getSound() override
	// {
		// return "";
	// }
// }

// void onTick(CBlob@ this)
// {
	// GunTick(this);
// }