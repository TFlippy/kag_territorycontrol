#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		3.5f,				//Weapon damage / projectile blob name
		600.0f,				//Weapon raycast range
		40,					//Weapon fire delay, in ticks
		5,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		75,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		1,					// Bullet count - for shotguns
		0.0f,				// Bullet Jitter
		"mat_rifleammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("RifleFire",1,1.0f,1.0f),		//Sound to play when firing
		SoundInfo("RifleReload",1,1.0f,1.0f),	//Sound to play when reloading
		SoundInfo("RifleCycle",1,1.0f,1.0f),	//Sound to play some time after firing
		20,					//Delay for the delayed sound, in ticks
		Vec2f(-8.0f,1.0f)	//Visual offset for raycast bullets
	);
	
	this.set_u8("gun_hitter", HittersTC::bullet_high_cal);
}

void onTick(CBlob@ this)
{
	GunTick(this);
	
	// if (getGameTime() % 60 != 0) return;

	// const f32 deg2rad = 3.14f / 180.0f;
	// f32 modifier = this.get_f32("gun_fireDamage");
	
	// CControls@ controls = getControls();
	// Driver@ driver = getDriver();

	// Vec2f dir = (controls.getMouseScreenPos() - driver.getScreenCenterPos());
	// f32 len = dir.Length();
	// f32 angle = dir.Angle() - 10;

	// print("" + angle);
	
	// Vec2f recoil = Vec2f(Maths::FastCos(angle * deg2rad), -Maths::FastSin(angle * deg2rad));
	// controls.setMousePosition((driver.getScreenDimensions() / 2.0f) + (recoil * len));
	
	// // f32 rad2deg = 180.0f / 3.14f;
	// const f32 deg2rad = 3.14f / 180.0f;
	
	// CControls@ controls = getControls();
	// Driver@ driver = getDriver();

	// Vec2f dir = (controls.getMouseScreenPos() - driver.getScreenCenterPos());
	// f32 len = dir.Length();
	// f32 angle = dir.Angle() -  10.0f;

	// Vec2f recoil = Vec2f(Maths::FastCos(angle * deg2rad), -Maths::FastSin(angle * deg2rad));
	// controls.setMousePosition((driver.getScreenDimensions() / 2) + (recoil * len));
}