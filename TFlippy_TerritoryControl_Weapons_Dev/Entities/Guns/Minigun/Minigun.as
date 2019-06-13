#include "Hitters.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		3.00f,				//Weapon damage / projectile blob name
		600.0f,				//Weapon raycast range
		3,					//Weapon fire delay, in ticks
		150,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		60,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		2,					//Bullet count - for shotguns
		2.5f,				//Bullet Jitter
		"mat_gatlingammo",	//Ammo item blob name
		true,				//If true, firing sound will be looped until player stops firing
		SoundInfo("Minigun_Shoot",1,1.0f,1.00f),	//Sound to play when firing
		SoundInfo("FlamethrowerReload",1,1.0f,0.65f),	//Sound to play when reloading
		SoundInfo(),						//Sound to play some time after firing
		0,					//Delay for the delayed sound, in ticks
		Vec2f(-12.0f, 3.0f)	//Visual offset for raycast bullets
	);
}

void onTick(CBlob@ this)
{
	GunTick(this);
}