//////////////////////////////////////////////////////
//
//  StandardFire.as - Vamist & Gingerbeard
//
//  Handles client side activities
//
//

#include "GunCommon.as";
#include "GunStandard.as";
#include "GunModule.as"
#include "BulletCase.as";
#include "Recoil.as";

const uint8 NO_AMMO_INTERVAL = 25;
 
void onInit(CBlob@ this) 
{
	// Prevent classes from jabbing n stuff
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null) 
	{
		ap.SetKeysToTake(key_action1);
	}

	// Set commands
	this.addCommandID("reload");
	this.addCommandID("fireProj");

	// Set vars
	this.set_bool("beginReload", false); //Starts a reload
	this.set_bool("doReload", false); //Determines if the gun is in a reloading phase
	this.set_u8("actionInterval", 0); //Timer for gun activities like shooting and reloading
	this.set_u8("clickReload", 1); //'Click' moment after shooting
	this.set_f32("gun_recoil_current", 0.0f); //Determines how far the kickback animation is when shooting

	this.Tag("weapon");
	this.Tag("no shitty rotation reset");
	this.Tag("hopperable");

	GunSettings@ settings;
	this.get("gun_settings", @settings);

	if (!this.exists("CustomBullet")) this.set_string("CustomBullet", "Bullet.png");  // Default bullet image
	if (!this.exists("CustomBulletWidth")) this.set_f32("CustomBulletWidth", 0.7f);  // Default bullet width
	if (!this.exists("CustomBulletLength")) this.set_f32("CustomBulletLength", 3.0f); // Default bullet length

	string vert_name = this.get_string("CustomBullet");
	CRules@ rules = getRules();

	if (isClient()) //&& !rules.get_bool(vert_name + '-inbook'))
	{
		if (vert_name == "")
		{
			// warn(this.getName() + " Attempted to add an empty CustomBullet, this can cause null errors");
			return;
		}

		//rules.set_bool(vert_name + '-inbook', true);

		Vertex[]@ bullet_vertex;
		rules.get(vert_name, @bullet_vertex);

		if (bullet_vertex is null)
		{
			Vertex[] vert;
			rules.set(vert_name, @vert);
		}

		// #blamekag
		if (!rules.exists("VertexBook"))
		{
			string[] book;
			rules.set("VertexBook", @book);
			book.push_back(vert_name);
		}
		else
		{
			string[]@ book;
			rules.get("VertexBook", @book);
			book.push_back(vert_name);
		}
	}

	this.set_u8("clip", settings.CLIP); //Clip u8 for easy maneuverability

	CSprite@ sprite = this.getSprite();

	if (this.hasTag("CustomSoundLoop"))
	{
		sprite.SetEmitSound(settings.FIRE_SOUND);
		sprite.SetEmitSoundVolume(this.exists("CustomShootVolume") ? this.get_f32("CustomShootVolume") : 2.0f);
		sprite.SetEmitSoundPaused(true);
	}

	// Required or stuff breaks due to wonky mouse syndrome
#ifndef GUNS
	if (isServer())
		getControls().setMousePosition(Vec2f(0,0));
#endif

	if (!this.exists("CustomFlash") || (this.exists("CustomFlash") && !this.get_string("CustomFlash").empty()))
	{
		// Determine muzzleflash sprite
		const bool hitterType = settings.B_TYPE == HittersTC::plasma || settings.B_TYPE == HittersTC::railgun_lance;
		const string muzzleflash_file = this.exists("CustomFlash") ? this.get_string("CustomFlash") : hitterType ? "MuzzleFlash_Plasma" : "MuzzleFlash";

		// Add muzzle flash
		CSpriteLayer@ flash = sprite.addSpriteLayer("muzzle_flash", muzzleflash_file, 16, 8, this.getTeamNum(), 0);
		if (flash !is null)
		{
			Animation@ anim = flash.addAnimation("default", 1, false);
			int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
			anim.AddFrames(frames);
			flash.SetRelativeZ(1.0f);
			flash.SetOffset(settings.MUZZLE_OFFSET);
			flash.SetFacingLeft(this.hasTag("CustomMuzzleLeft"));
			flash.SetVisible(false);
			// flash.setRenderStyle(RenderStyle::additive);
		}
	}

	/*GunModule[] modules = {};
	modules.push_back(TestModule());
	this.set("GunModules", modules);*/

	/*if (true)//(this.exists("GunModule"))
	{
		GunModule[]@ modules;
		this.get("GunModule", @modules);
		print("done");
		for (int a = 0; a < modules.length(); a++)
			modules[a].onModuleInit(this);
	}*/
}

void onTick(CBlob@ this)
{
	// Server will always get put back to sleep (doesnt need to run any of this)
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		if (holder !is null)
		{
			/*GunModule[] modules;
			this.get("GunModules", @modules);
			for (int a = 0; a < modules.length(); a++)
			{
				modules[a].onTick(this, holder);
			}*/

			CSprite@ sprite = this.getSprite();
			f32 aimangle = getAimAngle(this, holder);

			this.set_f32("gun_recoil_current", Maths::Lerp(this.get_f32("gun_recoil_current"), 0, 0.45f));

			GunSettings@ settings;
			this.get("gun_settings", @settings);

			// Case particle the gun uses
			string casing = this.exists("CustomCase") ? this.get_string("CustomCase") :
							settings.B_TYPE == HittersTC::bullet_high_cal ? "rifleCase":
							settings.B_TYPE == HittersTC::bullet_low_cal  ? "pistolCase":
							settings.B_TYPE == HittersTC::shotgun         ? "shotgunCase": "";
			f32 oAngle = (aimangle % 360) + 180;

			// Shooting
			const bool can_shoot = holder.isAttached() && holder.getName() != "automat" ? 
					   holder.isAttachedToPoint("PASSENGER") || holder.isAttachedToPoint("PILOT") : true;

			// Keys
			const bool pressing_shoot = (this.hasTag("CustomSemiAuto") ?
					   point.isKeyJustPressed(key_action1) || holder.isKeyJustPressed(key_action1) : //automatic
					   point.isKeyPressed(key_action1) || holder.isKeyPressed(key_action1)); //semiautomatic

			// Sound
			const f32 reload_pitch = this.exists("CustomReloadPitch") ? this.get_f32("CustomReloadPitch") : 1.0f;
			const f32 cycle_pitch  = this.exists("CustomCyclePitch")  ? this.get_f32("CustomCyclePitch")  : 1.0f;
			const f32 shoot_volume = this.exists("CustomShootVolume") ? this.get_f32("CustomShootVolume") : 2.0f;

			// Loop firing sound
			if (this.hasTag("CustomSoundLoop"))
			{
				sprite.SetEmitSoundPaused(!(pressing_shoot && this.get_u8("clip") > 0 && !this.get_bool("doReload")));
			}

			// Start reload sequence when pressing [R]
			CControls@ controls = holder.getControls();
			if (controls !is null && controls.isKeyJustPressed(KEY_KEY_R) &&
				!this.get_bool("beginReload") && !this.get_bool("doReload") && 
				this.get_u8("clip") < settings.TOTAL && HasAmmo(this))
			{
				this.set_bool("beginReload", true);
			}

			uint8 actionInterval = this.get_u8("actionInterval");
			if (actionInterval > 0)
			{
				actionInterval--; // Timer counts down with ticks

				if (this.exists("CustomCycle") && isClient())
				{
					// Custom cycle sequence 
					if ((actionInterval == settings.FIRE_INTERVAL / 2) && this.get_bool("justShot"))
					{
						sprite.PlaySound(this.get_string("CustomCycle"));
						this.set_bool("justShot", false);
					}
				}
			} 
			else if (this.get_bool("beginReload")) // Beginning of reload
			{
				// Start reload sequence
				actionInterval = settings.RELOAD_TIME;
				this.set_bool("beginReload", false);
				this.set_bool("doReload", true);

				if (HasAmmo(this) && this.get_u8("clip") < settings.TOTAL) 
				{
					if (!this.hasTag("CustomShotgunReload")) sprite.PlaySound(settings.RELOAD_SOUND, 1.0f, reload_pitch);
				}
			}
			else if (this.get_bool("doReload")) // End of reload
			{
				/*for (int a = 0; a < modules.length(); a++)
				{
					modules[a].onReload(this);
				}*/

				if (this.hasTag("CustomShotgunReload"))
				{
					if (HasAmmo(this) && this.get_u8("clip") < settings.TOTAL)
					{
						sprite.PlaySound(settings.RELOAD_SOUND, 1.0f, reload_pitch);
					}
					else if (this.exists("CustomCycle"))
					{
						actionInterval = settings.RELOAD_TIME * 2;
						sprite.PlaySound(this.get_string("CustomCycle"), 1.0f, cycle_pitch);
					}
				}

				if (holder.isMyPlayer() || (isServer() && holder.getBrain() !is null && holder.getBrain().isActive()))
				{
					Reload(this, holder);
				}

				if (this.hasTag("CustomShotgunReload")) this.set_bool("doReload", false);
			} 
			else if (pressing_shoot && can_shoot)
			{
				if (this.get_u8("clip") > 0)
				{
					/*for (int a = 0; a < modules.length(); a++)
					{
						modules[a].onFire(this);
					}*/

					// Shoot weapon
					actionInterval = settings.FIRE_INTERVAL;

					Vec2f fromBarrel = Vec2f((settings.MUZZLE_OFFSET.x / 3) * (this.isFacingLeft() ? 1 : -1), settings.MUZZLE_OFFSET.y + 1);
					fromBarrel = fromBarrel.RotateBy(aimangle);

					if (settings.B_SPREAD != 0 && settings.B_PER_SHOT == 1)
					{
						aimangle += XORRandom(2) != 0 ? -XORRandom(settings.B_SPREAD) : XORRandom(settings.B_SPREAD);
					}

					if (holder.isMyPlayer() || (isServer() && holder.getBrain() !is null && holder.getBrain().isActive()))
					{
						if (this.exists("ProjBlob"))
						{
							shootProj(this, aimangle);

							if (isClient())
							{
								Recoil@ coil = Recoil(holder, settings.G_RECOIL, settings.G_RECOILT, settings.G_BACK_T, settings.G_RANDOMX, settings.G_RANDOMY);
								coil.onTick();
							}
						}
						else
						{
							// Local hosts / clients will run this
							if (isClient())
							{
								shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(), sprite.getWorldTranslation() + fromBarrel);
								Recoil@ coil = Recoil(holder, settings.G_RECOIL, settings.G_RECOILT, settings.G_BACK_T, settings.G_RANDOMX, settings.G_RANDOMY);
								coil.onTick();
							}
							else // Server will run this
							{
								shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(), this.getPosition() + fromBarrel);
							}
						}
					}

					// Shooting sound
					if (!this.hasTag("CustomSoundLoop")) sprite.PlaySound(settings.FIRE_SOUND, shoot_volume);

					// Gun 'kickback' anim
					this.set_f32("gun_recoil_current", this.exists("CustomGunRecoil") ? this.get_u32("CustomGunRecoil") : 3);

					CSpriteLayer@ flash = sprite.getSpriteLayer("muzzle_flash");
					if (flash !is null)
					{
						//Turn on muzzle flash
						flash.SetFrameIndex(0);
						flash.SetVisible(true);
					}
				}
				else if (this.get_u8("clickReload") == 1 && HasAmmo(this))
				{
					// Start reload sequence if no ammo in gun
					actionInterval = settings.RELOAD_TIME;
					this.set_bool("beginReload", false);
					this.set_bool("doReload", true);
					sprite.PlaySound(settings.RELOAD_SOUND, 1.0f, reload_pitch);
				}
				else if (!this.get_bool("beginReload") && !this.get_bool("doReload"))
				{
					// Gun empty sequence
					sprite.PlaySound(this.exists("CustomSoundEmpty") ? this.get_string("CustomSoundEmpty") : "Gun_Empty.ogg");
					actionInterval = NO_AMMO_INTERVAL;
					this.set_u8("clickReload", 1);
				}
			}

			this.set_u8("actionInterval", actionInterval);

			sprite.ResetTransform();
			//sprite.RotateBy( aimangle, holder.isFacingLeft() ? Vec2f(-3,3) : Vec2f(3,3) );
			this.setAngleDegrees(aimangle);
			sprite.SetOffset(Vec2f(this.get_f32("gun_recoil_current"), 0)); //Recoil effect for gun blob
		}
	} 
	else 
	{
		if (isClient() && this.hasTag("CustomSoundLoop"))
		{
			// Turn off sound if detached
			this.getSprite().SetEmitSoundPaused(true);
		}
		this.getCurrentScript().runFlags |= Script::tick_not_sleeping;
	}
}
