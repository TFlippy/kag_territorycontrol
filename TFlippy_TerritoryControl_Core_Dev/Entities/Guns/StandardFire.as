//////////////////////////////////////////////////////
//
//  StandardFire.as - Vamist
//
//  Handles client side shooting, Setting gun vars,
//  and sprite angles
//

#include "GunStandard.as";
#include "Recoil.as";
#include "HittersTC.as";

//Ginger TODO list, do these if you want :kag_smiley:
// 1) Fix reloading system since its still broken
// 2) Ammo casing particles can be polished
// 3) Figure out NPC situation
// 4) We can slim down the variable count to simplify things
// 5) Convert TC Guns
// 6) BuilderAutoPickup.as is incompatible

class GunSettings
{
	uint8 CLIP;  //Amount of ammunition in the gun at creation
	uint8 TOTAL; //Max amount of ammo that can be in a clip
	uint8 FIRE_INTERVAL;  //Time in between shots
	uint8 RELOAD_TIME;   //Time it takes to reload (in ticks)
	uint8 B_PER_SHOT; //Shots per bullet | CHANGE B_SPREAD, otherwise both bullets will come out together

	int8 B_SPREAD; //the higher the value, the more 'uncontrollable' bullets get
	int8 B_SPEED; //Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
	int8 B_TTL;  //TTL = 'Time To Live' which determines the time the bullet lasts before despawning

	u8 B_TYPE; //Type of bullet the gun shoots | hitter

	Vec2f B_GRAV; //Bullet gravity drop
	Vec2f B_KB;   //KnockBack velocity on hit | KNOCKS PLAYERS WITH X VALUE
	Vec2f MUZZLE_OFFSET; //Where the muzzle flash appears
	Vec2f BULLET_OFFSET; //Unused

	bool S_LAST_B; //Should we spread from the last bullet shot(true) or from the mouse pos(false), only matters for shotguns
	bool G_RANDOMX;//Should we randomly move x
	bool G_RANDOMY;//Should we randomly move y, it ignores g_recoil

	int B_F_COINS; //Coins on hitting flesh (player or other blobs with 'flesh')
	int B_O_COINS; //Coins on hitting objects (Todo: define these 'objects' in BulletClass.as)
	int G_RECOIL;  //0 is default, adds recoil aiming up
	int G_RECOILT; //How long should recoil last, 10 is default, 30 = 1 second (like ticks)
	int G_BACK_T;  //Should we recoil the arm back time? (aim goes up, then back down with this, if > 0, how long should it last)

	string S_FLESH_HIT;  //Sound we make when hitting a fleshy object
	string S_OBJECT_HIT; //Sound we make when hitting a wall
	string FIRE_SOUND;   //Sound when shooting
	string RELOAD_SOUND; //Sound when reloading
	string AMMO_BLOB; //Ammunition the gun takes

	float B_DAMAGE; //1.0f is 1 heart

	GunSettings()
	{
		//DEFAULTS
		CLIP         = 0;
		TOTAL        = 32;
		FIRE_INTERVAL= 3;
		RELOAD_TIME  = 25;

		B_PER_SHOT = 1;
		B_SPREAD = 0;
		B_GRAV   = Vec2f(0, 0.006);
		B_SPEED  = 60;
		B_TTL    = 100;
		B_DAMAGE = 1.0f;
		B_TYPE   = HittersTC::bullet_high_cal;
		B_KB     = Vec2f(0, 0); //Reserve this for powerful weapons
		B_F_COINS= 0;
		B_O_COINS= 0;
		S_LAST_B = false;

		G_RECOIL = -5;
		G_RANDOMX= true;
		G_RANDOMY= false;
		G_RECOILT= 4;
		G_BACK_T = 3;

		S_FLESH_HIT  = "ArrowHitFlesh.ogg";
		S_OBJECT_HIT = "BulletImpact.ogg";
		FIRE_SOUND   = "AK47_Shoot.ogg";
		RELOAD_SOUND = "SMGReload.ogg";

		AMMO_BLOB = "mat_rifleammo";

		MUZZLE_OFFSET = Vec2f(-10, -1);
		BULLET_OFFSET = Vec2f(6, 0);
	}
};

const uint8 NO_AMMO_INTERVAL = 35;
 
void Init(CBlob@ this) 
{
	// Prevent classes from jabbing n stuff
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null) 
	{
		ap.SetKeysToTake(key_action1);
	}

	// Set commands
	this.addCommandID("reload");

	// Set vars
	this.set_bool("beginReload", false);
	this.set_bool("doReload", false);
	this.set_u8("actionInterval", 0);
	this.set_u8("clickReload", 1);
	setGunVars(this);
	this.Tag("weapon");
	this.Tag("no shitty rotation reset");
	this.Tag("hopperable");

	// Add muzzle flash
	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			GunSettings@ settings;
			this.get("gun_settings", @settings);

			const bool hitterType = this.get_u8("ammo_type") == HittersTC::plasma || this.get_u8("ammo_type") == HittersTC::railgun_lance;
			string muzzleflash_file = hitterType ? "MuzzleFlash_Plasma" : "MuzzleFlash";

			CSpriteLayer@ flash = sprite.addSpriteLayer("muzzle_flash", muzzleflash_file, 16, 8, this.getTeamNum(), 0);
			if (flash !is null)
			{
				Animation@ anim = flash.addAnimation("default", 1, false);
				anim.AddFrame(0);
				anim.AddFrame(1);
				anim.AddFrame(2);
				anim.AddFrame(3);
				anim.AddFrame(5);
				anim.AddFrame(6);
				anim.AddFrame(7);
				flash.SetRelativeZ(1.0f);
				flash.SetOffset(settings.MUZZLE_OFFSET);
				flash.SetVisible(false);
				// flash.setRenderStyle(RenderStyle::additive);
			}
		}
	}
}

void setGunVars(CBlob@ this)
{
	GunSettings@ settings;
	this.get("gun_settings", @settings);

	this.set_bool("recoil_random_x",    settings.G_RANDOMX);
	this.set_bool("recoil_random_y",    settings.G_RANDOMY);
	this.set_bool("sFLB",               settings.S_LAST_B);
	this.set_u8("clip",                 settings.CLIP);
	this.set_u8("total",                settings.TOTAL);
	this.set_u8("spread",               settings.B_SPREAD);
	this.set_u8("TTL",                  settings.B_TTL);
	this.set_u8("b_count",              settings.B_PER_SHOT);
	this.set_u8("speed",                settings.B_SPEED);
	this.set_u8("ammo_type",            settings.B_TYPE);
	this.set_u16("coins_flesh",         settings.B_F_COINS);
	this.set_u16("coins_object",        settings.B_O_COINS);
	this.set_u16("recoilTime",          settings.G_RECOILT);
	this.set_u16("recoilBackTime",      settings.G_BACK_T);
	this.set_s16("recoil",              settings.G_RECOIL);
	this.set_f32("damage",              settings.B_DAMAGE);
	this.set_Vec2f("KB",                settings.B_KB);
	this.set_Vec2f("grav",              settings.B_GRAV);
	this.set_string("sound",            settings.FIRE_SOUND);
	this.set_string("flesh_hit_sound" , settings.S_FLESH_HIT);
	this.set_string("object_hit_sound", settings.S_OBJECT_HIT);
}

void onTick(CBlob@ this)
{
	// Server will always get put back to sleep (doesnt need to run any of this)
	if (this.isAttached() && isClient())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		if (holder !is null)
		{
			CSprite@ sprite = this.getSprite();
			f32 aimangle = getAimAngle(this, holder);

			this.set_f32("gun_recoil_current", Maths::Lerp(this.get_f32("gun_recoil_current"), 0, 0.45f));

			GunSettings@ settings;
			this.get("gun_settings", @settings);

			// Handles reloading + shooting, holder player needs to do this
			//if (holder.isMyPlayer()) //disabled for NPCs 
			{

				CControls@ controls = holder.getControls();

				// Does our client want us to reload?
				if (controls !is null && controls.isKeyJustPressed(KEY_KEY_R) &&
					!this.get_bool("beginReload") && !this.get_bool("doReload") && 
					this.get_u8("clip") < this.get_u8("total") && countAmmo(this, settings.AMMO_BLOB) > 0)
				{
					this.set_bool("beginReload", true);
				}

				uint8 actionInterval = this.get_u8("actionInterval");
				if (actionInterval > 0)
				{
					actionInterval--;
				} 
				else if (this.get_bool("beginReload"))
				{
					actionInterval = settings.RELOAD_TIME;
					this.set_bool("beginReload", false);
					this.set_bool("doReload", true);
					sprite.PlaySound(settings.RELOAD_SOUND);
				}
				else if (this.get_bool("doReload"))
				{
					reload(this, holder);
					this.set_bool("doReload", false);
				} 
				else if (point.isKeyPressed(key_action1) || holder.isKeyPressed(key_action1))
				{
					if (this.get_u8("clip") > 0)
					{
						actionInterval = settings.FIRE_INTERVAL;
						Vec2f fromBarrel = Vec2f((holder.isFacingLeft() ? -1 : 1),0);
						fromBarrel = fromBarrel.RotateBy(aimangle);
						fromBarrel *= 7;
						//print(fromBarrel + " ");
						/*if(G_RECOIL > 0)
						{
							CControls@ c = holder.getControls();
							if(c !is null)
							{
								c.setMousePosition(c.getMouseScreenPos() + Vec2f(0,-G_RECOIL));
								ShakeScreen(Vec2f(0,-G_RECOIL), 150, sprite.getWorldTranslation());
							}
						}*/
						if (settings.B_PER_SHOT > 1)
						{
							shootShotgun(this.getNetworkID(), aimangle, holder.getNetworkID(),sprite.getWorldTranslation() + fromBarrel);
						}
						else
						{
							if (settings.B_SPREAD != 0)
							{
								aimangle += XORRandom(2) != 0 ? -XORRandom(settings.B_SPREAD) : XORRandom(settings.B_SPREAD);
							}
							shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(),sprite.getWorldTranslation() + fromBarrel);
						}

						this.set_f32("gun_recoil_current", 3); //Todo: add a new var (or use one existing) that will affect this

						CSpriteLayer@ flash = sprite.getSpriteLayer("muzzle_flash");
						if (flash !is null)
						{
							flash.SetFrameIndex(0);
							flash.SetVisible(true);
						}
					}
					else if (this.get_u8("clip") == 0 && this.get_u8("clickReload") == 1 && countAmmo(this, settings.AMMO_BLOB) > 0)
					{
						actionInterval = settings.RELOAD_TIME;
						this.set_bool("beginReload", false);
						this.set_bool("doReload", true);
						sprite.PlaySound(settings.RELOAD_SOUND);
					}
					else if (!this.get_bool("beginReload"))
					{
						sprite.PlaySound("Gun_Empty.ogg");
						actionInterval = NO_AMMO_INTERVAL;
						this.set_u8("clickReload", 1);
					}
				}

				this.set_u8("actionInterval", actionInterval);
			}

			sprite.ResetTransform();
			//sprite.RotateBy( aimangle, holder.isFacingLeft() ? Vec2f(-3,3) : Vec2f(3,3) );
			this.setAngleDegrees(aimangle); //Rotate gun //TODO: change rotation point somehow
			sprite.SetOffset(Vec2f(this.get_f32("gun_recoil_current"), 0)); //Recoil effect for gun blob
		}
	} 
	else 
	{
		this.getCurrentScript().runFlags |= Script::tick_not_sleeping;
	}
}

f32 getAimAngle(CBlob@ this, CBlob@ holder)
{
	Vec2f aimvector = holder.getAimPos() - this.getInterpolatedPosition();
	return holder.isFacingLeft() ? -aimvector.Angle() + 180.0f : -aimvector.Angle();
}
