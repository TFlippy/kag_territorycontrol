#include "GunCommon.as";

void onInit(CBlob@ this)
{
	GunSettings settings = GunSettings();

	//General
	//settings.CLIP = 0; //Amount of ammunition in the gun at creation
	settings.TOTAL = 4; //Max amount of ammo that can be in a clip
	settings.FIRE_INTERVAL = 35; //Time in between shots
	settings.RELOAD_TIME = 10; //Time it takes to reload (in ticks)
	settings.AMMO_BLOB = "mat_shotgunammo"; //Ammunition the gun takes

	//Bullet
	settings.B_PER_SHOT = 7; //Shots per bullet | CHANGE B_SPREAD, otherwise both bullets will come out together
	settings.B_SPREAD = 5; //the higher the value, the more 'uncontrollable' bullets get
	settings.B_GRAV = Vec2f(0, 0.01); //Bullet gravity drop
	settings.B_SPEED = 60; //Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
	settings.B_TTL = 13; //TTL = 'Time To Live' which determines the time the bullet lasts before despawning
	settings.B_DAMAGE = 1.0f; //1 is 1 heart
	settings.B_TYPE = HittersTC::shotgun; //Type of bullet the gun shoots | hitter

	//Recoil
	settings.G_RECOIL = -16; //0 is default, adds recoil aiming up
	//settings.G_RANDOMX = true; //Should we randomly move x
	//settings.G_RANDOMY = false; //Should we randomly move y, it ignores g_recoil
	settings.G_RECOILT = 8; //How long should recoil last, 10 is default, 30 = 1 second (like ticks)
	settings.G_BACK_T = 2; //Should we recoil the arm back time? (aim goes up, then back down with this, if > 0, how long should it last)

	//Sound
	settings.FIRE_SOUND = "ShotgunFire.ogg"; //Sound when shooting
	settings.RELOAD_SOUND = "ShotgunReload.ogg"; //Sound when reloading

	//Offset
	settings.MUZZLE_OFFSET = Vec2f(-19, -2); //Where the muzzle flash appears

	this.set("gun_settings", @settings);

	//Custom
	this.set_string("CustomCycle", "ShotgunPump");
	this.Tag("CustomShotgunReload");
}
