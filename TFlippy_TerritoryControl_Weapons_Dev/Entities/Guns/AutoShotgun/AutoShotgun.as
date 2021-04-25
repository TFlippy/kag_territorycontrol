#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		1.25f,				//Weapon damage / projectile blob name
		500.0f,				//Weapon raycast range
		8,					//Weapon fire delay, in ticks
		8,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		40,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		20,					//For shotguns: Additional delay to reload end
		5,					//Bullet count when fired
		1.5f,				//Random bullet angle offset in degrees
		"mat_shotgunammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("AutoShotgun_Fire",0,1.0f,0.8f),	//Sound to play when firing
		SoundInfo("SMGReload",1,0.8f,0.6f),	//Sound to play when reloading
		SoundInfo(),	//Sound to play some time after firing
		16,					//Delay for the delayed sound, in ticks
		Vec2f(-8.0f,1.0f)	//Visual offset for raycast bullets
	);
	
	this.set_u8("gun_hitter", HittersTC::shotgun);
	this.getShape().SetOffset(Vec2f(0, 2));
}

void onTick(CBlob@ this)
{
	GunTick(this);
}