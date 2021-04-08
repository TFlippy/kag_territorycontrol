#include "Hitters.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		2.50f,				//Weapon damage / projectile blob name
		600.0f,				//Weapon raycast range
		1,					//Weapon fire delay, in ticks
		200,				//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		30,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		3,					//Bullet count - for shotguns
		3.0f,				//Bullet Jitter
		"mat_gatlingammo",	//Ammo item blob name
		true,				//If true, firing sound will be looped until player stops firing
		SoundInfo("Rekt_Shoot_Loop",1,2.0f,1.00f),	//Sound to play when firing
		SoundInfo("Minigun_Reload",1,1.0f,0.8f),	//Sound to play when reloading
		SoundInfo(),						//Sound to play some time after firing
		0,					//Delay for the delayed sound, in ticks
		Vec2f(-7.0f,1.0f)	//Visual offset for raycast bullets
	);
	
	this.set_bool("gun_force_nonsolid", true);
	this.getShape().SetOffset(Vec2f(0, 3));
}

void onTick(CBlob@ this)
{
	GunTick(this);
}