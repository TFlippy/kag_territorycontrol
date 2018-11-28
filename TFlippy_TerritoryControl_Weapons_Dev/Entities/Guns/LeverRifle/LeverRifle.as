#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		false,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		3.0f,				//Weapon damage / projectile blob name
		600.0f,				//Weapon raycast range
		15,					//Weapon fire delay, in ticks
		8,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		10,					//Weapon reload time
		true,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		1,					// Bullet count - for shotguns
		0.2f,				// Bullet Jitter
		"mat_rifleammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("LeverRifle_Fire",1,1.0f,1.5f),		//Sound to play when firing
		SoundInfo("LeverRifle_Load",1,0.6f,1.0f),	//Sound to play when reloading
		SoundInfo("LeverRifle_Cycle",1,0.6f,1.0f),	//Sound to play some time after firing
		4,					//Delay for the delayed sound, in ticks
		Vec2f(-8.0f,1.0f)	//Visual offset for raycast bullets
	);
	
	this.set_u8("gun_hitter", HittersTC::bullet_high_cal);
}

void onTick(CBlob@ this)
{
	GunTick(this);
}