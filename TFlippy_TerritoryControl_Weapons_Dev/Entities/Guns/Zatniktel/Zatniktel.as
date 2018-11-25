#include "Hitters.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitProjectile(
		this,
		false,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		"zatniktelprojectile",		//Projectile to fire
		10.0f,				//Projectile speed
		10,					//Weapon fire delay, in ticks
		3,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		5,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		"mat_mithril",		//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("Zatniktel_Shoot", 1, 0.7f, 1.0f),	//Sound to play when firing
		SoundInfo("Zatniktel_Pickup", 1, 0.7f, 1.0f),//Sound to play when reloading
		SoundInfo(),	
		0,					//Delay for the delayed sound, in ticks
		Vec2f(0.0f,-4.0f)	//Offset for projectiles
	);
}

void onTick(CBlob@ this)
{
	GunTick(this);
}