#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		false,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		0.50f,				//Weapon damage / projectile blob name
		250.0f,				//Weapon raycast range
		5,					//Weapon fire delay, in ticks
		4,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		20,					//Weapon reload time
		true,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		4,					// Bullet count - for shotguns
		7.5f,				// Bullet Jitter
		"mat_banditammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("BanditRifleFire",1,1.0f,0.80f),	//Sound to play when firing
		SoundInfo("thud",1,1.0f,1.5f),//Sound to play when reloading
		SoundInfo(),							//Sound to play some time after firing
		0,					//Delay for the delayed sound, in ticks
		Vec2f(-6.0f,-2.0f)	//Visual offset for raycast bullets
	);
	
	this.set_u8("gun_hitter", HittersTC::shotgun);
}
void onTick(CBlob@ this)
{
	GunTick(this);
}