#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast
	(
		this,
		false,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		2.25f,				//Weapon damage / projectile blob name
		1000.0f,				//Weapon raycast range
		25,					//Weapon fire delay, in ticks
		4,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		40,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		4,					// Bullet count - for shotguns
		0.0f,				// Bullet Jitter
		"mat_rifleammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("SniperFire", 1, 1.0f, 1.0f),	//Sound to play when firing
		SoundInfo("SniperReload", 1, 1.0f, 1.0f),//Sound to play when reloading
		SoundInfo(),							//Sound to play some time after firing
		0,					//Delay for the delayed sound, in ticks
		Vec2f(0.0f, 0.0f)	//Visual offset for raycast bullets
	);
	
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ laser = sprite.addSpriteLayer("laser", "Laser.png", 32, 1);
	
	this.set_u8("gun_hitter", HittersTC::bullet_high_cal);
	
	if(laser !is null)
	{
		Animation@ anim = laser.addAnimation("default", 0, false);
		anim.AddFrame(0);
		laser.SetRelativeZ(-1.0f);
		laser.SetVisible(true);
		laser.setRenderStyle(RenderStyle::additive);
		laser.SetOffset(Vec2f(-15.0f, 0.5f));
	}
	
	this.set_f32("scope_zoom", 0.35f);
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		GunTick(this);
		
		Vec2f hitPos;
		f32 length;
		f32 range = this.get_f32("gun_fireRange");
		bool flip = this.isFacingLeft();
		f32 angle =	this.getAngleDegrees();
		Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
		Vec2f startPos = this.getPosition();
		Vec2f endPos = startPos + dir * range;
		
		bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
		length = (hitPos - startPos).Length();
		
		CSpriteLayer@ laser = this.getSprite().getSpriteLayer("laser");
		
		if (laser !is null)
		{
			laser.ResetTransform();
			laser.ScaleBy(Vec2f(length / 32.0f - 0.4, 1.0f));
			laser.TranslateBy(Vec2f(length / 2 - 7, 0.0f));
			laser.RotateBy((flip ? 180 : 0), Vec2f());
			laser.SetVisible(true);
		}
	}
	else
	{
		CSpriteLayer@ laser = this.getSprite().getSpriteLayer("laser");
		
		if (laser !is null)
		{
			laser.SetVisible(false);
		}
	}
}