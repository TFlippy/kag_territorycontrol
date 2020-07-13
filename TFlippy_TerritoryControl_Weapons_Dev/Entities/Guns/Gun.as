#include "Hitters.as";
#include "HittersTC.as";
#include "BulletCommon.as";
#include "GunCommon.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	GunSettings@ settings;
	this.get("gun_settings", @settings);

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if(ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}

	this.getShape().SetRotationsAllowed(true);
	this.Tag("no shitty rotation reset");
	this.Tag("weapon");
	this.Tag("hopperable");

	this.set_u32("gun_shoot_next", 0);
	this.set_f32("gun_recoil_current", 0);

	this.set_bool("gun_cycled", false);

	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			CSpriteLayer@ flash = sprite.addSpriteLayer("muzzle_flash",settings.sprite_muzzleflash, 16, 8, this.getTeamNum(), 0);
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
				flash.SetVisible(false);
				// flash.setRenderStyle(RenderStyle::additive);
				// flash.SetOffset(this.get_Vec2f("gun_muzzle_offset") + Vec2f(-16, -1));
			}
		}
	}
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		UpdateAngle(this);

		if (isClient())
		{
			this.set_f32("gun_recoil_current", Maths::Lerp(this.get_f32("gun_recoil_current"), 0, 0.50f));
		}

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder =	point.getOccupied();

		const bool client = isClient();
		const bool server = isServer();
		const bool isLocal = holder.isMyPlayer();

		// if(holder is null)
		// {
			// if(soundFireLoop){
				// sprite.SetEmitSoundPaused(true);
				// this.set_bool("gun_soundFireLoopStarted",false);
			// }
			// return;
		// }

		CPlayer@ player = holder.getPlayer();
		if (player !is null && isLocal)
		{
			CControls@ controls = getControls();

			if (controls.isKeyJustPressed(KEY_KEY_R))
			{
				CRules@ rules = getRules();

				CBitStream stream;
				stream.write_netid(this.getNetworkID());

				rules.SendCommand(rules.getCommandID("gun_reload"), stream);
			}
		}

		if ((point.isKeyPressed(key_action1) || holder.isKeyPressed(key_action1)) && !(holder.get_f32("babbyed") > 0))
		{
			if (this.get_bool("gun_cycled") && getGameTime() >= this.get_u32("gun_shoot_next"))
			{
				server_Shoot(this, holder.getAimPos());
			}
		}
		else if (point.isKeyJustReleased(key_action1) || holder.isKeyJustReleased(key_action1))
		{
			this.set_bool("gun_cycled", true);
		}
	}
}

// bool HitBlob(CBlob@ this, CBlob@ holder, Vec2f dir, Vec2f hitPos, CBlob@ target, f32 &in damage_in, f32 &out damage_out)
// {
	// damage_out = damage_in;

	// if (target !is null && target.getTeamNum() != holder.getTeamNum() && (target.isCollidable() || target.hasTag("flesh")) && !target.hasTag("invincible"))
	// {
		// f32 health_before = target.getHealth();
		// holder.server_Hit(target, hitPos, dir, damage_in, this.get_u8("gun_hitter"), false);

		// damage_out = Maths::Max(damage_in - health_before, 0);
		// return damage_out <= 0;
	// }
	// else return false;
// }

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	attached.Tag("noLMB");
	attached.Tag("noRMB");
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	detached.Untag("noLMB");
	detached.Untag("noRMB");
}

void UpdateAngle(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point !is null)
	{
		CBlob@ holder = point.getOccupied();
		if (holder !is null)
		{
			Vec2f aimpos = holder.getAimPos();
			Vec2f pos = holder.getPosition();

			Vec2f dir = pos - aimpos;
			dir.Normalize();

			f32 mouseAngle = dir.getAngleDegrees();
			if (!holder.isFacingLeft()) mouseAngle += 180;

			this.setAngleDegrees(-mouseAngle);
			this.getSprite().SetOffset(Vec2f(this.get_f32("gun_recoil_current"), 0));
		}
	}
}
