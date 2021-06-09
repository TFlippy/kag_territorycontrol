#include "GunCommon.as";

void onInit(CBlob@ this)
{
	GunSettings settings = GunSettings();

	//General
	//settings.CLIP = 0; //Amount of ammunition in the gun at creation
	settings.TOTAL = 12; //Max amount of ammo that can be in a clip
	settings.FIRE_INTERVAL = 3; //Time in between shots
	settings.RELOAD_TIME = 60; //Time it takes to reload (in ticks)
	settings.AMMO_BLOB = "mat_rifleammo"; //Ammunition the gun takes

	//Bullet
	//settings.B_PER_SHOT = 1; //Shots per bullet | CHANGE B_SPREAD, otherwise both bullets will come out together
	settings.B_SPREAD = 1; //the higher the value, the more 'uncontrollable' bullets get
	settings.B_GRAV = Vec2f(0, 0.001); //Bullet gravity drop
	settings.B_SPEED = 65; //Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
	settings.B_TTL = 15; //TTL = 'Time To Live' which determines the time the bullet lasts before despawning
	settings.B_DAMAGE = 4.0f; //1 is 1 heart
	settings.B_TYPE = HittersTC::bullet_high_cal; //Type of bullet the gun shoots | hitter

	//Recoil
	settings.G_RECOIL = -7; //0 is default, adds recoil aiming up
	settings.G_RANDOMX = true; //Should we randomly move x
	settings.G_RANDOMY = false; //Should we randomly move y, it ignores g_recoil
	settings.G_RECOILT = 4; //How long should recoil last, 10 is default, 30 = 1 second (like ticks)
	settings.G_BACK_T = 3; //Should we recoil the arm back time? (aim goes up, then back down with this, if > 0, how long should it last)

	//Sound
	settings.FIRE_SOUND = "Callahan_Shoot.ogg"; //Sound when shooting
	settings.RELOAD_SOUND = "SniperReload.ogg"; //Sound when reloading

	//Offset
	settings.MUZZLE_OFFSET = Vec2f(-23, -1); //Where the muzzle flash appears

	this.set("gun_settings", @settings);

	//Custom
	this.set_f32("scope_zoom", 0.40f);

	CSpriteLayer@ laser = this.getSprite().addSpriteLayer("laser", "Laser.png", 32, 1);
	if (laser !is null)
	{
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
 
				if (d < dist && b.getTeamNum() != myTeam && b.isCollidable() && !b.hasTag("invincible") && !b.hasTag("dead") &&
				   (b.hasTag("player") || b.hasTag("npc") || b.hasTag("human") || b.hasTag("vehicle")))
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
				if (point !is null)
				{
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