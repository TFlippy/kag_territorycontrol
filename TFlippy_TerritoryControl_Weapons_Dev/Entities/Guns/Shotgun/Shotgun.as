#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		0.75f,				//Weapon damage / projectile blob name
		500.0f,				//Weapon raycast range
		35,					//Weapon fire delay, in ticks
		4,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		10,					//Weapon reload time
		true,				//If true, gun will be reloaded like a shotgun
		49,					//For shotguns: Additional delay to reload end
		6,					//Bullet count when fired
		4.0f,				//Random bullet angle offset in degrees
		"mat_shotgunammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("ShotgunFire",5,1.0f,1.0f),	//Sound to play when firing
		SoundInfo("ShotgunReload",1,0.6f,1.0f),	//Sound to play when reloading
		SoundInfo("ShotgunPump",1,1.0f,1.0f),	//Sound to play some time after firing
		16,					//Delay for the delayed sound, in ticks
		Vec2f(-8.0f,1.0f)	//Visual offset for raycast bullets
	);
	
	this.set_u8("gun_hitter", HittersTC::shotgun);
}

void onTick(CBlob@ this)
{
	GunTick(this);
}