#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		false,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		1.75f,				//Weapon damage / projectile blob name
		450.0f,				//Weapon raycast range
		10,					//Weapon fire delay, in ticks
		1,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		10,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		1,					// Bullet count - for shotguns
		3.0f,				// Bullet Jitter
		"mat_banditammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("BanditPistolFire",1,1.0f,0.8f),	//Sound to play when firing
		SoundInfo("BanditPistolReload",1,1.0f,1.0f),//Sound to play when reloading
		SoundInfo(),							//Sound to play some time after firing
		0,					//Delay for the delayed sound, in ticks
		Vec2f(-6.0f,-2.0f)	//Visual offset for raycast bullets
	);
	
	this.set_u8("gun_hitter", HittersTC::bullet_low_cal);
}
void onTick(CBlob@ this)
{
	GunTick(this);
}