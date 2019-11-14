#include "Hitters.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitProjectile(
		this,
		false,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		"molotov",    		//Projectile to fire
		40.0f,				//Projectile speed
		30,					//Weapon fire delay, in ticks
		3,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		15,					//Weapon reload time
		true,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		"mat_molotov",		//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("Molothrower_Shoot", 1, 1.0f, 1.00f),		//Sound to play when firing
		SoundInfo("thud", 1, 1.0f, 0.65f),	//Sound to play when reloading
		SoundInfo(),									//Sound to play some time after firing
		0,					//Delay for the delayed sound, in ticks
		Vec2f(16.0f, 0.0f)	//Offset for projectiles
	);
}
void onTick(CBlob@ this)
{
	GunTick(this);
}
