//////////////////////////////////////////////////////
//
//  BulletMain.as - Vamist
//
//  CORE FILE
//  
//  A bit messy, stuff gets removed and added as time 
//  goes on. Handles spawning bullets and making sure
//  clients can render bullets
//
//  Try not poke around here unless you need to
//  Some code here is messy
//

#include "HittersTC.as";
#include "BulletTrails.as";
#include "BulletClass.as";
#include "BulletCase.as";

// I would use blob.getNetworkID, but without some major changes
// It would be the same pattern every time
// This value resets every time a new player joins
//
// TODO-> SERVER SENDS RANDOM VALUE ON NEW PLAYER JOIN (DIFFERENT SEED)
Random@ r = Random(12345);

// Core vars
BulletHolder@ BulletGrouped = BulletHolder();

Vertex[] v_r_bullet;
Vertex[] v_r_fade;
Vertex[] v_r_reloadBox;

SColor white = SColor(255,255,255,255);
SColor eatUrGreens = SColor(255,0,255,0);
int FireGunID;
int FireShotgunID;

f32 FRAME_TIME = 0;
//

// Set commands, add render:: (only do this once)
void onInit(CRules@ this)
{
	Reset(this);

	if (isClient())
	{
		this.add_u16("temp_id", Render::addScript(Render::layer_postworld, "BulletMain", "GunRender", 0.0f));
		//Render::addScript(Render::layer_prehud, "BulletMain", "GUIStuff", 0.0f);
	}
}

void onReload(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	r.Reset(12345);
	FireGunID     = this.addCommandID("fireGun");
	FireShotgunID = this.addCommandID("fireShotgun");
	v_r_bullet.clear();
	v_r_fade.clear();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	r.Reset(12345);
}

// Handles making every bullet go weeee
void onTick(CRules@ this)
{
	FRAME_TIME = 0;
	BulletGrouped.FakeOnTick(this);
}

void GunRender(int id)
{
	FRAME_TIME += getRenderApproximateCorrectionFactor(); //getRenderSmoothDeltaTime() * getTicksASecond();  // We are using this because ApproximateCorrectionFactor is lerped
	RenderingBullets();
}

void GUIStuff(int id)
{
	renderScreenpls();
}

void RenderingBullets() // Bullets
{
	BulletGrouped.FillArray(); // Fill up v_r_bullets
	if (v_r_bullet.length() > 0) // If there are no bullets on our screen, dont render
	{
		Render::RawQuads("bullet.png", v_r_bullet);

		if (g_debug == 0) // useful for lerp testing
		{
			v_r_bullet.clear();
		}
	}
}

void renderScreenpls() // Bullet ammo gui
{
	/*CBlob@ holder = getLocalPlayerBlob();           
	if (holder !is null) 
	{
		CBlob@ b = holder.getAttachments().getAttachmentPointByName("PICKUP").getOccupied(); 
		CPlayer@ p = holder.getPlayer(); // get player holding this

		if (b !is null && p !is null) 
		{
			if (b.exists("clip")) // make sure its a valid gun
			{
				if (p.isMyPlayer() && b.isAttached())
				{
					uint8 clip = b.get_u8("clip");
					uint8 total = b.get_u8("total"); // get clip and ammo total for easy access later
					CControls@ controls = getControls();
					Vec2f pos = Vec2f(0,getScreenHeight()-80); // controls for screen position
					bool render = false; // used to save render time (more fps basically)

					if (controls !is null)
					{
						int length = (pos - controls.getMouseScreenPos() - Vec2f(-30,-35)).Length();
						// get length for 'fancy' invisiblty when mouse goes near it

						if (length < 256 && length > 0) // are we near it?
						{
							white.setAlpha(length);
							eatUrGreens.setAlpha(length);
							render = true;
						}
						else // check the reverse
						{
							length=-length;
							if(length < 256 && length > 0)
							{
								white.setAlpha(length);
								eatUrGreens.setAlpha(length);
								render = true;
							}
						}
					}
						
					if (v_r_reloadBox.length() < 1 || render) // is it time to render?
					{
						if (render) // lets clear only IF we need to
						{
							v_r_reloadBox.clear();
						}

						v_r_reloadBox.push_back(Vertex(pos.x+112, pos.y,    0, 1, 0, white)); // top right
						v_r_reloadBox.push_back(Vertex(pos.x, pos.y,        0, 0, 0, white)); // top left
						v_r_reloadBox.push_back(Vertex(pos.x, pos.y+80,     0, 0, 1, white)); // bot left
						v_r_reloadBox.push_back(Vertex(pos.x+112, pos.y+80, 0, 1, 1, white)); // bot right
					}

					Render::SetTransformScreenspace(); // set position for render
					Render::SetAlphaBlend(true); // since we are going to be doing the invisiblity thing
					Render::RawQuads("ammoBorder.png", v_r_reloadBox); // render!

					pos = Vec2f(15,getScreenHeight() - 68); // positions for the GUI
					GUI::DrawText(clip+"/"+total, pos, eatUrGreens);

					pos = Vec2f(15,getScreenHeight() - 58);

					if (b.get_bool("doReload")) 
					{
						GUI::DrawText("Reloading...", pos, eatUrGreens);
					} 
					else if (clip == 0 && total > 0 && !b.get_bool("beginReload")) 
					{
						GUI::DrawText("Press R to \nreload or \nshoot again!", pos, eatUrGreens);
					} 
					else if (clip == 0 && total == 0) 
					{
						GUI::DrawText("No more \nammo, find \nanother \nweapon!", pos, eatUrGreens);
					}
				}
			}
			else // We might not be holding a gun, so lets clear the box
			{
				if (v_r_reloadBox.length() > 0)
				{
					v_r_reloadBox.clear();
				}
			}
		}
	}*/
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params) 
{
	if (cmd == FireGunID)
	{
		CBlob@ hoomanBlob = getBlobByNetworkID(params.read_netid());
		CBlob@ gunBlob    = getBlobByNetworkID(params.read_netid());

		if (hoomanBlob !is null && gunBlob !is null)
		{  
			f32 angle = params.read_f32();
			const Vec2f pos = params.read_Vec2f();
			BulletObj@ bullet = BulletObj(hoomanBlob,gunBlob,angle,pos);

			u32 timeSpawnedAt = params.read_u32(); // getGameTime() it spawned at
			CMap@ map = getMap(); 
			for (;timeSpawnedAt < getGameTime(); timeSpawnedAt++) // Catch up to everybody else
			{
				bullet.onFakeTick(map);
			}

			BulletGrouped.AddNewObj(bullet);

			gunBlob.sub_u8("clip",1);

			if (isClient())
			{
				gunBlob.getSprite().PlaySound(gunBlob.get_string("sound"), 2.0f);

				u8 bulletType = gunBlob.get_u8("ammo_type");
				string casing = bulletType == HittersTC::bullet_high_cal ? "rifleCase": 
				                bulletType == HittersTC::bullet_low_cal ? "pistolCase":
				                bulletType == HittersTC::shotgun ? "shotgunCase" : ""; //todo: use frames instead?


				if (hoomanBlob.isFacingLeft())
				{
					f32 oAngle = (angle % 360) + 180;
					ParticleCase2(casing,pos,oAngle);
				}
				else
				{
					ParticleCase2(casing,pos,angle);
				}

				CBlob@ localBlob = getLocalPlayerBlob();
				if(localBlob !is null && localBlob is hoomanBlob) // if we are this blob
				{
					const int recoil = gunBlob.get_s16("recoil");
					const bool rx = gunBlob.get_bool("recoil_random_x");
					const bool ry = gunBlob.get_bool("recoil_random_y");
					const int recoilTime = gunBlob.get_u16("recoilTime");
					const int recoilBackTime = gunBlob.get_u16("recoilBackTime");
					Recoil@ coil = Recoil(localBlob,recoil,recoilTime,recoilBackTime,rx,ry);
					BulletGrouped.NewRecoil(@coil);
				}
			}
		}
	}
	else if (cmd == FireShotgunID)
	{
		CBlob@ hoomanBlob = getBlobByNetworkID(params.read_netid());  
		CBlob@ gunBlob    = getBlobByNetworkID(params.read_netid());

		if (hoomanBlob !is null && gunBlob !is null)
		{  
			const f32 angle  = params.read_f32();
			const Vec2f pos  = params.read_Vec2f();
			const u8 spread  = gunBlob.get_u8("spread");
			const u8 b_count = gunBlob.get_u8("b_count");
			const bool sFLB  = gunBlob.get_bool("sFLB");
			const u32 timeSpawnedAt = params.read_u32(); // getGameTime() it spawned at
			CMap@ map = getMap(); 

			gunBlob.sub_u8("clip",b_count);

			if(sFLB)
			{
				f32 tempAngle = angle;

				for (u8 a = 0; a < b_count; a++)
				{
					tempAngle += r.NextRanged(2) != 0 ? -r.NextRanged(spread) : r.NextRanged(spread);
					BulletObj@ bullet = BulletObj(hoomanBlob,gunBlob,tempAngle,pos);

					for (u32 timeSpawned = timeSpawnedAt; timeSpawned < getGameTime(); timeSpawned++) // Catch up to everybody else
					{
						bullet.onFakeTick(map);
					}

					BulletGrouped.AddNewObj(bullet);
				}
			}
			else
			{
				for (u8 a = 0; a < b_count; a++)
				{
					f32 tempAngle = angle;
					tempAngle += r.NextRanged(2) != 0 ? -r.NextRanged(spread) : r.NextRanged(spread);
					BulletObj@ bullet = BulletObj(hoomanBlob,gunBlob,tempAngle,pos);

					for (u32 timeSpawned = timeSpawnedAt; timeSpawned < getGameTime(); timeSpawned++) // Catch up to everybody else
					{
						bullet.onFakeTick(map);
					}

					BulletGrouped.AddNewObj(bullet);
				}
			}

			if (isClient())
			{
				gunBlob.getSprite().PlaySound(gunBlob.get_string("sound"));

				u8 bulletType = gunBlob.get_u8("ammo_type");
				string casing = bulletType == HittersTC::bullet_high_cal ? "rifleCase": 
				                bulletType == HittersTC::bullet_low_cal ? "pistolCase":
				                bulletType == HittersTC::shotgun ? "shotgunCase" : ""; //can find a better way later

				if (hoomanBlob.isFacingLeft())
				{
					f32 oAngle = (angle % 360) + 180;
					ParticleCase2(casing, pos, oAngle);
				}
				else
				{
					ParticleCase2(casing, pos, angle);
				}

				CBlob@ localBlob = getLocalPlayerBlob();
				if (localBlob != null && localBlob is hoomanBlob)
				{
					const int recoil = gunBlob.get_s16("recoil");
					const bool rx = gunBlob.get_bool("recoil_random_x");
					const bool ry = gunBlob.get_bool("recoil_random_y");
					const int recoilTime = gunBlob.get_u16("recoilTime");
					const int recoilBackTime = gunBlob.get_u16("recoilBackTime");
					Recoil@ coil = Recoil(localBlob,recoil,recoilTime,recoilBackTime,rx,ry);
					BulletGrouped.NewRecoil(@coil);
				}
			}
		}
	}
}