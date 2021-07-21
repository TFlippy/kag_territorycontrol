//////////////////////////////////////////////////////
//
//  GunCommon.as - GingerBeard
//
//  Handles GunSettings, which stores all of a gun's information. 
//  Defaults are located in this file. If a variable is missing from a gun's settings it will come to this file to provide.
//  This file also includes a manual of optional settings for guns.
//

#include "HittersTC.as";

class GunSettings
{
	uint8 CLIP;  //Amount of ammunition in the gun at creation
	uint8 TOTAL; //Max amount of ammo that can be in a clip
	uint8 FIRE_INTERVAL;//Time in between shots
	uint8 RELOAD_TIME; //Time it takes to reload (in ticks)
	uint8 B_PER_SHOT; //Shots per bullet | CHANGE B_SPREAD, otherwise both bullets will come out together

	int8 B_SPREAD; //the higher the value, the more 'uncontrollable' bullets get
	int8 B_SPEED; //Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
	s8 B_TTL;  //TTL = 'Time To Live' which determines the time the bullet lasts before despawning

	u8 B_TYPE; //Type of bullet the gun shoots (hitter) | Changes muzzle flash

	Vec2f B_GRAV; //Bullet gravity drop
	Vec2f MUZZLE_OFFSET; //Where the muzzle flash appears | Also determines where bullets are spawned

	bool G_RANDOMX;//Should we randomly move x
	bool G_RANDOMY;//Should we randomly move y, it ignores g_recoil

	int G_RECOIL;  //0 is default, adds recoil aiming up
	int G_RECOILT; //How long should recoil last, 10 is default, 30 = 1 second (like ticks)
	int G_BACK_T;  //Should we recoil the arm back time? (aim goes up, then back down with this, if > 0, how long should it last)

	string FIRE_SOUND;   //Sound when shooting
	string RELOAD_SOUND; //Sound when reloading
	string AMMO_BLOB; //Ammunition the gun takes

	float B_DAMAGE; //1.0f is 1 heart

	/// CUSTOM SETTINGS
	/// > These are variables that are optional and are to be set in the individual guns themselves
	///
	/// this.set_string("CustomBullet", string fileName); //Changes the png file of the bullet
	/// this.set_string("CustomFlash", string fileName); //Changes the png file of the muzzle flash
	/// this.set_string("CustomCase", string fileName); //Changes the png file of the spent ammo cartridge particle
	/// this.set_string("CustomSoundFlesh", string fileName); //Changes the sound file of the flesh hitting sound upon bullet collision
	/// this.set_string("CustomSoundObject", string fileName); //Changes the sound file of the object hitting sound upon bullet collision
	/// this.set_string("CustomSoundPickup", string fileName); //Adds a sound effect for when the gun is picked up
	/// this.set_string("CustomSoundEmpty", string fileName); //Changes the sound file of the gun empty sound
	/// this.set_string("CustomCycle", string fileName); //Enables cycling sounds when shooting (pumpaction, bolt action etc)
	///
	/// this.set_f32("CustomReloadPitch", float pitch); //Changes Reload sound pitch
	/// this.set_f32("CustomCyclePitch", float pitch); //Changes Cycle sound pitch
	/// this.set_f32("CustomShootVolume", float volume); //Changes shooting sound volume
	/// this.set_f32("CustomBulletLength", float length); //Changes the length of the bullet sprite
	/// this.set_f32("CustomBulletWidth", float width); //Changes the width of the bullet sprite
	///
	/// this.set_u32("CustomCoinFlesh", uint coins) //Coins on hitting flesh (set as players)
	/// this.set_u32("CustomCoinObject", uint coins) //Coins on hitting objects (set as vehicles)
	/// this.set_u32("CustomGunRecoil", uint recoil) //Distance the gun "kickbacks" when shot
	///
	/// this.set_u8("CustomKnock", int knocktime); //Time in ticks the victim is knocked for
	/// this.set_u8("CustomPenetration", int penetration); //How much damage to blocks that are shot
	///
	/// this.Tag("CustomShotgunReload"); //Switches the gun to use an alternative reloading method
	/// this.Tag("CustomMuzzleLeft"); //Sets the muzzle flash sprite in the opposite direction
	/// this.Tag("CustomSoundLoop"); //Shooting sound becomes looped rather than instantaneous
	/// this.Tag("CustomSemiAuto"); //Switches the gun to become semiautomatic rather than automatic
	/// this.Tag("CustomSpread"); //Changes a shotgun's accuracy by by setting all bullets in a certain direction- kind of weird

	/// PROJECTILE SETTINGS
	/// > These are variables for guns that shoot actual blobs rather than bullets- e.g bazooka
	///
	/// this.set_string("ProjBlob", string blobName); //Blob that is shot from the gun | enables projectile mode
	/// this.set_Vec2f("ProjOffset", Vec2f offset); //Where the blob starts from | uses MUZZLE_OFFSET if not used
	///

	GunSettings()
	{
		//DEFAULTS

		//Gun
		CLIP  = 0;
		TOTAL = 30;
		FIRE_INTERVAL = 10;
		RELOAD_TIME = 25;
		AMMO_BLOB = "mat_rifleammo";

		//Bullet
		B_PER_SHOT = 1;
		B_SPREAD = 0;
		B_GRAV   = Vec2f(0, 0.006);
		B_SPEED  = 60;
		B_TTL    = 15;
		B_DAMAGE = 1.0f;
		B_TYPE   = HittersTC::bullet_high_cal;

		//Recoil
		G_RECOIL  = -5;
		G_RANDOMX = true;
		G_RANDOMY = false;
		G_RECOILT = 4;
		G_BACK_T  = 3;

		//Sound
		FIRE_SOUND   = "AK47_Shoot.ogg";
		RELOAD_SOUND = "SMGReload.ogg";

		//Offset
		MUZZLE_OFFSET = Vec2f(-10, -1);
	}
};

f32 getAimAngle(CBlob@ this, CBlob@ holder)
{
	Vec2f aimvector = holder.getAimPos() - (this.hasTag("place45") ? holder.getInterpolatedPosition() : this.getInterpolatedPosition());
	f32 angle = holder.isFacingLeft() ? -aimvector.Angle() + 180.0f : -aimvector.Angle();
	if (holder.isAttached()) this.SetFacingLeft(holder.isFacingLeft());
	return angle;
}
