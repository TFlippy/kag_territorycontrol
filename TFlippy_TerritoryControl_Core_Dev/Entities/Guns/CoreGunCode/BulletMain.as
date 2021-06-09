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

SColor white = SColor(255,255,255,255);
SColor eatUrGreens = SColor(255,0,255,0);
int FireGunID;

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

	BulletRender::Reset();
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
	BulletRender::Draw();
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
			if (b.hasTag("weapon")) // make sure its a valid gun
			{
				if (p.isMyPlayer() && b.isAttached())
				{
					GunSettings@ settings;
					b.get("gun_settings", @settings);

					CControls@ controls = getControls();
					Vec2f pos = Vec2f(10, getScreenHeight() - 60); // controls for screen position

					GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), pos - Vec2f(10,0));
					GUI::DrawIcon(needs defining, 3, Vec2f(16, 16), pos); //ammo blob
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
