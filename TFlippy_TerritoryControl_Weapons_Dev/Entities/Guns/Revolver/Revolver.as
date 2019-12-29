#include "Hitters.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		false,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		1.50f,				//Weapon damage / projectile blob name
		450.0f,				//Weapon raycast range
		5,					//Weapon fire delay, in ticks
		6,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		55,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		1,					// Bullet count - for shotguns
		2.0f,				// Bullet Jitter
		"mat_pistolammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("RevolverFire",1,1.0f,1.0f),	//Sound to play when firing
		SoundInfo("RevolverReload",1,1.0f,1.0f),//Sound to play when reloading
		SoundInfo(),							//Sound to play some time after firing
		0,					//Delay for the delayed sound, in ticks
		Vec2f(-6.0f,-2.0f)	//Visual offset for raycast bullets
	);
}
void onTick(CBlob@ this)
{
	GunTick(this);
}