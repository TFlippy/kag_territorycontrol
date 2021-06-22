#include "GunCommon.as";

void onInit(CBlob@ this)
{
	GunSettings settings = GunSettings();

	//General
	//settings.CLIP = 0; //Amount of ammunition in the gun at creation
	settings.TOTAL = 1; //Max amount of ammo that can be in a clip
	settings.FIRE_INTERVAL = 5; //Time in between shots
	settings.RELOAD_TIME = 60; //Time it takes to reload (in ticks)
	settings.AMMO_BLOB = "mat_rifleammo"; //Ammunition the gun takes

	//Bullet
	settings.B_PER_SHOT = 16; //Shots per bullet | CHANGE B_SPREAD, otherwise both bullets will come out together
	settings.B_SPREAD = 1; //the higher the value, the more 'uncontrollable' bullets get
	settings.B_GRAV = Vec2f(0, 0.003); //Bullet gravity drop
	settings.B_SPEED = 100; //Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
	settings.B_TTL = 18; //TTL = 'Time To Live' which determines the time the bullet lasts before despawning
	settings.B_DAMAGE = 2.0f; //1 is 1 heart
	settings.B_TYPE = HittersTC::bullet_high_cal; //Type of bullet the gun shoots | hitter

	//Recoil
	settings.G_RECOIL = -24; //0 is default, adds recoil aiming up
	//settings.G_RANDOMX = true; //Should we randomly move x
	//settings.G_RANDOMY = false; //Should we randomly move y, it ignores g_recoil
	settings.G_RECOILT = 7; //How long should recoil last, 10 is default, 30 = 1 second (like ticks)
	settings.G_BACK_T = 0; //Should we recoil the arm back time? (aim goes up, then back down with this, if > 0, how long should it last)

	//Sound
	settings.FIRE_SOUND = "AMR_Shoot.ogg"; //Sound when shooting
	settings.RELOAD_SOUND = "SMGReload.ogg"; //Sound when reloading

	//Offset
	settings.MUZZLE_OFFSET = Vec2f(-28, -3); //Where the muzzle flash appears

	this.set("gun_settings", @settings);

	//Custom
	this.set_u8("CustomKnock", 20);
	this.set_f32("CustomBulletLength", 14.0f);
	this.set_f32("scope_zoom", 0.40f);
	this.Tag("heavy weight");
	this.Tag("place45");
}
