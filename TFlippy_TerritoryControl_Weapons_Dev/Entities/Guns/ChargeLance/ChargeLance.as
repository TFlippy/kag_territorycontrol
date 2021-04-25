#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		100.00f,			//Weapon damage / projectile blob name
		6000.0f,				//Weapon raycast range
		30,				//Weapon fire delay, in ticks
		5,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		120,				//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		25,					// Bullet count - for shotguns
		0.70f,				// Bullet Jitter
		"mat_lancerod",		//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("ChargeLanceFire",3,1.5f,1.0f),		//Sound to play when firing
		SoundInfo("ChargeLanceReload",1,1.5f,1.0f),	//Sound to play when reloading
		SoundInfo("ChargeLanceCycle",1,1.5f,1.0f),	//Sound to play some time after firing
		20,					//Delay for the delayed sound, in ticks
		Vec2f(-8.0f,2.0f)	//Visual offset for raycast bullets
	);
	
	this.set_string("gun_tracerName", "ChargeRifle_Tracer.png");
	this.set_u8("gun_hitter", HittersTC::railgun_lance);
	this.getShape().SetOffset(Vec2f(0, 3));
	
	this.Tag("medium weight");
}

void onTick(CBlob@ this)
{
	GunTick(this);
}