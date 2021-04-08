#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		2.50f,				//Weapon damage / projectile blob name
		800.0f,				//Weapon raycast range
		5,					//Weapon fire delay, in ticks
		10,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		45,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		1,					//Bullet count - for shotguns
		0.05f,				//Bullet Jitter
		"mat_rifleammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("SilencedRifle_Shoot",0,0.75f,1.00f),	//Sound to play when firing
		SoundInfo("SMGReload",1,1.0f,0.8f),	//Sound to play when reloading
		SoundInfo(),						//Sound to play some time after firing
		0,					//Delay for the delayed sound, in ticks
		Vec2f(-7.0f,1.0f)	//Visual offset for raycast bullets
	);
	
	this.set_string("gun_tracerName", "SilencedRifle_Tracer.png");
	this.set_u8("gun_hitter", HittersTC::bullet_high_cal);
	this.getShape().SetOffset(Vec2f(-2, 3));
	
	this.set_f32("scope_zoom", 0.20f);
}

void onTick(CBlob@ this)
{
	GunTick(this);
}