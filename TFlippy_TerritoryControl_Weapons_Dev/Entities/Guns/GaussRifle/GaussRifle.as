#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		3.00f,				//Weapon damage / projectile blob name
		1000.0f,			//Weapon raycast range
		30,					//Weapon fire delay, in ticks
		1,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		20,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		13,					// Bullet count - for shotguns
		0.60f,				// Bullet Jitter
		"mat_steelingot",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("GaussRifle_Shoot", 1, 1.00f, 1.00f),		//Sound to play when firing
		SoundInfo("BazookaCycle", 1, 0.70f, 0.80f),	//Sound to play when reloading
		SoundInfo("", 1, 1.00f, 1.00f),	//Sound to play some time after firing
		20,					//Delay for the delayed sound, in ticks
		Vec2f(-8.0f,2.0f)	//Visual offset for raycast bullets
	);
	
	this.set_string("gun_tracerName", "GaussRifle_Tracer.png");
	this.set_u8("gun_hitter", HittersTC::railgun_lance);
	
	this.Tag("medium weight");
}

void onTick(CBlob@ this)
{
	GunTick(this);
}