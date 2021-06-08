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

#include "GunCommon.as";
#include "BulletTrails.as";
#include "BulletClass.as";

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
	FireGunID = this.addCommandID("fireGun");
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
		CBlob@ holder = getLocalPlayerBlob();           
		if (holder !is null) 
		{
			CBlob@ b = holder.getAttachments().getAttachmentPointByName("PICKUP").getOccupied(); 
			CPlayer@ p = holder.getPlayer(); // get player holding this

			if (b !is null && p !is null) 
			{
				if (b.hasTag("weapon") && b.isAttached()) // make sure its a valid gun
				{
					string bullet = b.exists("CustomBullet") ? b.get_string("CustomBullet") :"Bullet.png";
					Render::RawQuads(bullet, v_r_bullet);
				}
			}
		}
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
			const f32 angle = params.read_f32();
			const Vec2f pos = params.read_Vec2f();
			u32 timeSpawnedAt = params.read_u32(); // getGameTime() it spawned at
			CMap@ map = getMap(); 

			GunSettings@ settings;
			gunBlob.get("gun_settings", @settings);

			if (settings.B_PER_SHOT > 1) //Shotgun firing
			{
				f32 tempAngle = angle;

				for (u8 a = 0; a < settings.B_PER_SHOT; a++)
				{
					if (!gunBlob.hasTag("CustomSpread")) tempAngle = angle;
					tempAngle += r.NextRanged(2) != 0 ? -r.NextRanged(settings.B_SPREAD) : r.NextRanged(settings.B_SPREAD);
					BulletObj@ bullet = BulletObj(hoomanBlob, gunBlob, tempAngle, pos);

					for (u32 timeSpawned = timeSpawnedAt; timeSpawned < getGameTime(); timeSpawned++) // Catch up to everybody else
					{
						bullet.onFakeTick(map);
					}

					BulletGrouped.AddNewObj(bullet);
				}
			}
			else //Guns that fire only one bullet
			{
				BulletObj@ bullet = BulletObj(hoomanBlob, gunBlob, angle, pos);
				for (;timeSpawnedAt < getGameTime(); timeSpawnedAt++) // Catch up to everybody else
				{
					bullet.onFakeTick(map);
				}

				BulletGrouped.AddNewObj(bullet);
			}
			gunBlob.sub_u8("clip", 1);

			if (isClient())
			{
				CBlob@ localBlob = getLocalPlayerBlob();
				if (localBlob !is null && localBlob is hoomanBlob) // if we are this blob
				{
					Recoil@ coil = Recoil(localBlob, settings.G_RECOIL, settings.G_RECOILT, settings.G_BACK_T, settings.G_RANDOMX, settings.G_RANDOMY);
					BulletGrouped.NewRecoil(@coil);
				}
			}
		}
	}
}
