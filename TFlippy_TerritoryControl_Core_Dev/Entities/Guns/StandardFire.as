//////////////////////////////////////////////////////
//
//  StandardFire.as - Vamist
//
//  Handles client side activities
//
//

#include "GunStandard.as";
#include "GunCommon.as";
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

	this.set_u8("clip", settings.CLIP); //Clip u8 for easy maneuverability

	// Add muzzle flash
	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			const bool hitterType = settings.B_TYPE == HittersTC::plasma || settings.B_TYPE == HittersTC::railgun_lance;
			const string muzzleflash_file = this.exists("CustomFlash") ? this.get_string("CustomFlash") : hitterType ? "MuzzleFlash_Plasma" : "MuzzleFlash";

			CSpriteLayer@ flash = sprite.addSpriteLayer("muzzle_flash", muzzleflash_file, 16, 8, this.getTeamNum(), 0);
			if (flash !is null)
			{
				Animation@ anim = flash.addAnimation("default", 1, false);
				int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
				anim.AddFrames(frames);
				flash.SetRelativeZ(1.0f);
				flash.SetOffset(settings.MUZZLE_OFFSET);
				flash.SetVisible(false);
				// flash.setRenderStyle(RenderStyle::additive);
			}
		}
	}
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

			//Case particle the gun uses
			string casing = this.exists("CustomCase") ? this.get_string("CustomCase") :
			                settings.B_TYPE == HittersTC::bullet_high_cal ? "rifleCase":
			                settings.B_TYPE == HittersTC::bullet_low_cal  ? "pistolCase":
			                settings.B_TYPE == HittersTC::shotgun         ? "shotgunCase": "";
			f32 oAngle = (aimangle % 360) + 180;

			const bool pressing_shoot = this.hasTag("CustomSemiAuto") ?
			           point.isKeyJustPressed(key_action1) || holder.isKeyJustPressed(key_action1) : //automatic
			           point.isKeyPressed(key_action1) || holder.isKeyPressed(key_action1); //semiautomatic

			//Start reload sequence when pressing [R]
			CControls@ controls = holder.getControls();
			if (controls !is null && controls.isKeyJustPressed(KEY_KEY_R) &&
			    !this.get_bool("beginReload") && !this.get_bool("doReload") && 
			    this.get_u8("clip") < settings.TOTAL && CountAmmo(this, settings.AMMO_BLOB) > 0)
			{
				this.set_bool("beginReload", true);
			}

			uint8 actionInterval = this.get_u8("actionInterval");
			if (actionInterval > 0)
			{
				actionInterval--; //Timer counts down with ticks

				if (this.exists("CustomCycle"))
				{
					//Custom cycle sequence 
					if ((actionInterval == settings.FIRE_INTERVAL / 2) && this.get_bool("justShot"))
					{
						sprite.PlaySound(this.get_string("CustomCycle"));
						ParticleCase2(casing, this.getPosition(), this.isFacingLeft() ? oAngle : aimangle);
						this.set_bool("justShot", false);
					}
				}
			} 
			else if (this.get_bool("beginReload"))
			{
				//Start reload sequence
				actionInterval = settings.RELOAD_TIME;
				this.set_bool("beginReload", false);
				this.set_bool("doReload", true);

				if (CountAmmo(this, settings.AMMO_BLOB) > 0 && this.get_u8("clip") < settings.TOTAL) 
				{
					sprite.PlaySound(settings.RELOAD_SOUND);
				}
				else if (this.exists("CustomCycle") && this.hasTag("CustomShotgunReload"))
				{
					actionInterval = settings.RELOAD_TIME * 2;
					sprite.PlaySound(this.get_string("CustomCycle"));
				}
			}
			else if (this.get_bool("doReload"))
			{
				//End reload sequence
				Reload(this, holder);
			} 
			else if (pressing_shoot)
			{
				if (this.get_u8("clip") > 0)
				{
					//Shoot weapon
					actionInterval = settings.FIRE_INTERVAL;

					Vec2f fromBarrel = Vec2f((settings.MUZZLE_OFFSET.x / 3) * (this.isFacingLeft() ? 1 : -1), settings.MUZZLE_OFFSET.y + 1);
					fromBarrel = fromBarrel.RotateBy(aimangle);

					if (settings.B_SPREAD != 0 && settings.B_PER_SHOT == 1)
					{
						aimangle += XORRandom(2) != 0 ? -XORRandom(settings.B_SPREAD) : XORRandom(settings.B_SPREAD);
					}

					shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(), sprite.getWorldTranslation() + fromBarrel);

					this.set_f32("gun_recoil_current", 3); //Todo: add a new var (or use one existing) that will affect this

					CSpriteLayer@ flash = sprite.getSpriteLayer("muzzle_flash");
					if (flash !is null)
					{
						flash.SetFrameIndex(0);
						flash.SetVisible(true);
					}

					if (!this.exists("CustomCycle")) 
					{
						ParticleCase2(casing, this.getPosition(), this.isFacingLeft() ? oAngle : aimangle);
					}
					else this.set_bool("justShot", true);
				}
				else if (this.get_u8("clickReload") == 1 && CountAmmo(this, settings.AMMO_BLOB) > 0)
				{
					//Start reload sequence if no ammo in gun
					actionInterval = settings.RELOAD_TIME;
					this.set_bool("beginReload", false);
					this.set_bool("doReload", true);
					sprite.PlaySound(settings.RELOAD_SOUND);
				}
				else if (!this.get_bool("beginReload") && !this.get_bool("doReload"))
				{
					//Gun empty
					sprite.PlaySound("Gun_Empty.ogg");
					actionInterval = NO_AMMO_INTERVAL;
					this.set_u8("clickReload", 1);
				}
			}

			this.set_u8("actionInterval", actionInterval);

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
