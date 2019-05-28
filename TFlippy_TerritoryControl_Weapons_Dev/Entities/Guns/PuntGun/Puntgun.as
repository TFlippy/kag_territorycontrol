#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	this.Tag("heavy weight");
	
	GunInitRaycast(
		this,
		true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		0.75f,                //Weapon damage / projectile blob name
        400.0f,                //Weapon raycast range
        5,                     //Weapon fire delay, in ticks
        1,                     //Weapon clip size
        10.00f,                //Ammo usage factor, completely ignore for now
        100,                   //Weapon reload time
        false,                 //If true, gun will be reloaded like a shotgun
        1,                     //For shotguns: Additional delay to reload end
        20,                    //Bullet count when fired
        12.0f,                //Random bullet angle offset in degrees
        "mat_banditammo",    //Ammo item blob name
        false,                //If true, firing sound will be looped until player stops firing
        SoundInfo("PuntgunFire",1,3.0f,2.0f),    //Sound to play when firing
        SoundInfo("PuntgunReload",1,0.6f,1.0f),    //Sound to play when reloading
        SoundInfo("PuntgunPump",1,2.0f,1.0f),    //Sound to play some time after firing
        16,                    //Delay for the delayed sound, in ticks
        Vec2f(-8.0f,1.0f)    //Visual offset for raycast bullets
	);
	
	this.set_u8("gun_hitter", HittersTC::shotgun);
}

void onTick(CBlob@ this)
{
	GunTick(this);
}