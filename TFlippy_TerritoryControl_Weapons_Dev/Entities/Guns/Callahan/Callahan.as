#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

Vec2f raycast_offset = Vec2f(0.0f, -2.0f);

void onInit(CBlob@ this)
{
	GunInitRaycast
	(
		this,
		true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		4.00f,				//Weapon damage / projectile blob name
		1000.0f,				//Weapon raycast range
		3,					//Weapon fire delay, in ticks
		12,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		60,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		1,					// Bullet count - for shotguns
		0.0f,				// Bullet Jitter
		"mat_rifleammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("Callahan_Shoot", 1, 1.0f, 1.0f),	//Sound to play when firing
		SoundInfo("SniperReload", 1, 1.0f, 1.0f),//Sound to play when reloading
		SoundInfo(),							//Sound to play some time after firing
		0,					//Delay for the delayed sound, in ticks
		raycast_offset	//Visual offset for raycast bullets
	);

	this.set_u8("gun_hitter", HittersTC::bullet_high_cal);
	this.set_f32("scope_zoom", 0.40f);
	
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ laser = sprite.addSpriteLayer("laser", "Laser.png", 32, 1);
	
	if (laser !is null)
	{
		Animation@ anim = laser.addAnimation("default", 0, false);
		anim.AddFrame(0);
		laser.SetRelativeZ(-1.0f);
		laser.SetVisible(false);
		laser.setRenderStyle(RenderStyle::additive);
		laser.SetOffset(Vec2f(-15.0f, 0.5f));
	}
	
	this.set_f32("scope_zoom", 0.35f);
}

const f32 radius = 24.00f;

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		GunTick(this);
		
		// Shitcode ahead
		CControls@ controls = getControls();
		Driver@ driver = getDriver();
		CSpriteLayer@ laser = this.getSprite().getSpriteLayer("laser");
		
		if (laser is null) return;
		
		Vec2f wpos = controls.getMouseWorldPos();
		const u8 myTeam = this.getTeamNum();
		
		f32 dist = 1337.00f;
		u16 closest_id = 0;
		
		CBlob@[] blobs;
		if (this.getMap().getBlobsInRadius(wpos, radius, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];
				f32 d = (b.getPosition() - wpos).getLength();
				
				if (d < dist && b.getTeamNum() != myTeam && b.isCollidable() && (b.hasTag("flesh") || b.hasTag("npc") || b.hasTag("vehicle")) && !b.hasTag("invincible"))
				{
					closest_id = b.getNetworkID();
					dist = d;
				}
			}
			
			// print("" + closest_id + " vs " +  this.get_u16("callahan_target"));
						
			if (closest_id > 0)
			{
				CBlob@ blob = getBlobByNetworkID(closest_id);
				
				Vec2f bpos = blob.getPosition();
				// Vec2f spos = driver.getScreenPosFromWorldPos(bpos);
				// Vec2f dir = (controls.getMouseScreenPos() - spos);
				
				Vec2f dir = (bpos - this.getPosition());
			
				f32 factor = dist / radius;
			
				AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
				CBlob@ holder = point.getOccupied();
				if (holder !is null)
				{
					CPlayer@ ply = holder.getPlayer();
					if (ply !is null && ply.isMyPlayer())
					{
						Vec2f spos = driver.getScreenPosFromWorldPos(bpos);
						Vec2f sdir = (controls.getMouseScreenPos() - spos);
					
						controls.setMousePosition(controls.getMouseScreenPos() - (sdir * 0.75f));
					}
				}

				if (isVisible(this, blob))
				{
					Vec2f hitPos;
					bool flip = this.isFacingLeft();
					
					Vec2f dir = bpos - this.getPosition();
					f32 len = dir.Length();
					dir.Normalize();
					
					f32 length = (bpos - this.getPosition()).Length();
					
					laser.ResetTransform();
					laser.ScaleBy(Vec2f(length / 32.0f - 0.4, 1.0f));
					laser.TranslateBy(Vec2f(length / 2 - 7, 0.0f));
					laser.RotateBy((flip ? 180 : 0), Vec2f());
					laser.SetVisible(true);
				}
				else
				{
					laser.SetVisible(false);
				}
			}
			else
			{
				laser.SetVisible(false);
			}
		}
		else
		{
			laser.SetVisible(false);
		}
		
		if (closest_id != this.get_u16("callahan_target"))
		{
			if (closest_id > 0)
			{
				this.getSprite().PlaySound("Callahan_Found", 0.50f, 1.00);
			}
			else
			{
				this.getSprite().PlaySound("Callahan_Lost", 0.50f, 1.00);
			}
		}
		
		this.set_u16("callahan_target", closest_id);
	}
}

bool isVisible(CBlob@ blob, CBlob@ target)
{
	Vec2f col;
	return !getMap().rayCastSolidNoBlobs(blob.getPosition(), target.getPosition(), col);
}