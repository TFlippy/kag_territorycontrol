/////////////////////////////////////////////
// Cloud controller made by Vamist
// No stealing without perms, its in BETA >:(
// 
//
// Clouds are synced
// Server will send a command when its time to spawn in a new cloud
// Clients just render
//
//
// We can use script wide variables because cloud.as will only ever be in use once.
// This just means we dont need to use rules.get/set everywhere
//
//
// TODO
// -> Different cloud sizes (?)
// -> More cloud sprites (?)
// -> Allow variable editing through .cfg (?)
// -> Colour changes based on rain (?)
// -> Instead of clearing vertex array, edit last values (less resizing) 
// -> Todo: turn it into SMesh to help with performance (will do after next 3d update)
//
// END

// Important vars
Random@ RAND = Random();
Clouds@[] C_CLOUDS;
Vertex[] V_CLOUDS;
//

// Cloud vars
const Vec2f MOVE_VEL = Vec2f(0.4,0); // Base speed
const f32 PARRALEX_EFFECT = 0.2f; // Base effect, each cloud will have a custom one based on this
const u16 CLOUD_COOLDOWN = 100;
const u16 PADDING = 200;

SColor CLOUDS_COL = color_white; // colour that changes over time

Vec2f SPAWN_VARIATION_HEIGHT = Vec2f(-400,0); // x = highest, y = lowest

f32 FRAME_TIME = 0.0f; // last frame time
f32 CAMERA_X = 0.0f; 
f32 CAMERA_Y = 0.0f;

u16 CLEAR_WIDTH_POS = 0;
u16 LAST_ATTEMPT = 0;  // getGameTime() last attempt

u16 SCREEN_HEIGHT = 0;
u16 SCREEN_WIDTH = 0;
//

void onInit(CRules@ this)
{
	this.addCommandID("new_cloud"); // still register command so its in sync with server
	
	if (v_fastrender) // then remove script if we dont want clouds
	{
		this.RemoveScript("clouds.as");
		return;
	}

	int callback = Render::addScript(Render::layer_background, "Clouds", "RenderClouds", -10000.0f);
	this.set_u16("callback", callback);

	onRestart(this);
}

void onRestart(CRules@ this)
{
	C_CLOUDS.clear();
	V_CLOUDS.clear();

	LAST_ATTEMPT = 0;
	CLEAR_WIDTH_POS = 0;
	SPAWN_VARIATION_HEIGHT.y = 0;
}

// Very useful for debugging
void onReload(CRules@ this)
{
	onRestart(this);

	if (isClient()) // Assume we are in localhost mode
	{
		Render::RemoveScript(this.get_u16("callback"));
		int callback = Render::addScript(Render::layer_background, "Clouds", "RenderClouds", -10000.0f);
		this.set_u16("callback", callback);
	}
}
//

void onTick(CRules@ this) 
{
	if (CLEAR_WIDTH_POS == 0) // Required here because map is null in onInit and onRestart
	{
		CLEAR_WIDTH_POS = (getMap().tilemapwidth * 8) + PADDING;
		SPAWN_VARIATION_HEIGHT.y = (getMap().tilemapheight * 8) / 2;
		if (isClient())
		{
			for (int a = 0; a < 50; a++) // TEMP CLOUD SPAWNER, IS DESYNCED FOR NOW
			{
				f32 spawnPosY = RAND.NextRanged(SPAWN_VARIATION_HEIGHT.y + -SPAWN_VARIATION_HEIGHT.x) + SPAWN_VARIATION_HEIGHT.x;
				C_CLOUDS.push_back(Clouds(Vec2f(XORRandom(getMap().tilemapwidth * 8), spawnPosY), getGameTime(), XORRandom(5), XORRandom(20)));
			}
		}
	}

	if (isServer())
	{
		uint gametime = getGameTime();
		if (LAST_ATTEMPT < gametime)
		{
			LAST_ATTEMPT = gametime + CLOUD_COOLDOWN;
			if (RAND.NextRanged(100) < 50)
			{
				s16 spawnPosY = RAND.NextRanged(SPAWN_VARIATION_HEIGHT.y + -SPAWN_VARIATION_HEIGHT.x);
				spawnPosY += SPAWN_VARIATION_HEIGHT.x;

				CBitStream cbs;
				cbs.write_s16(spawnPosY); // only send y instead of vec2f, saves space
				cbs.write_u16(gametime);
				cbs.write_u8(RAND.NextRanged(5));
				cbs.write_u8(RAND.NextRanged(20));

				this.SendCommand(this.getCommandID("new_cloud"), cbs); 
			}
		}
	}

	if (isClient())
	{
		FRAME_TIME = 0;
		UpdateCloudColor();
		
		for (int a = 0; a < C_CLOUDS.size(); a++)
		{
			if (!C_CLOUDS[a].moveCloud()) // return's false if its out the map
			{
				C_CLOUDS.erase(a);
				a--;
			}
		}
	}
}

void RenderClouds(int id)
{
	int size = C_CLOUDS.size();
	if (size == 0) { return; } // dont waste a draw call on an empty size

	// Setting data so we dont need to repeat it multiple times a frame
	FRAME_TIME += Render::getRenderDeltaTime() * getTicksASecond();  // We are using this because ApproximateCorrectionFactor is lerped

	Vec2f camPos = getCamera().getPosition(); // Safe to say we won't be rendering if we don't have a camera
	CAMERA_X = camPos.x; 
	CAMERA_Y = camPos.y; 

	Driver@ driver = getDriver();
	SCREEN_WIDTH = driver.getScreenWidth();
	SCREEN_HEIGHT = driver.getScreenHeight();
	//

	for (int a = 0; a < size; a++)
	{
		C_CLOUDS[a].SendToRenderer();
	}

	if (V_CLOUDS.size() == 0) { return; }
	
	Render::SetAlphaBlend(true); // alpha required to look more 'cloudy'
	Render::SetZBuffer(true, true); // required to show up being tiles 
	Render::RawQuads("cloudsall.png", V_CLOUDS);

	V_CLOUDS.clear(); // clear after rendering
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (!isClient()) { return; }

	if (cmd == this.getCommandID("new_cloud"))
	{
		s16 yPos = params.read_s16();
		u16 gameTime = params.read_u16();
		u8 spriteType = params.read_u8();
		u8 zLayer = params.read_u8();

		C_CLOUDS.push_back(
			Clouds(Vec2f(-PADDING, yPos), gameTime, spriteType, zLayer)
		);
	}
}



class Clouds
{
	Vec2f goalPos = Vec2f(0,0);
	Vec2f oldPos = Vec2f(0,0);
	f32 spriteXPos = 0;
	u8 zLevel = 0; // the higher this is, the lower the z level;

	Clouds (Vec2f position, u16 creationTick, u8 spriteType, u8 zLayer) 
	{
		goalPos = position;
		oldPos = position;
		zLevel = zLayer;

		for (u8 a = 0; a < spriteType; a++) // Texture uv 'hacks'
		{
			spriteXPos += 0.25;
		}

		u16 gametime = getGameTime();
		for (u16 a = creationTick; a <= gametime; a++) // maybe add some sort of cap, could cause stutters if we get a packet that was delayed
		{
			moveCloud(); // sync clouds positions by catching up
		}
	}

	bool moveCloud() // Updated every tick
	{
		if (goalPos.x > CLEAR_WIDTH_POS)
		{
			return false;
		}

		goalPos += MOVE_VEL;
		goalPos.x += ((zLevel/2) * 0.05f); // some move faster based on z level

		return true;
	}

	void SendToRenderer() // Checks that our cloud is on screen then passes it to render
	{	
		Vec2f TopLeft = Vec2f_lerp(oldPos, goalPos, FRAME_TIME);
		oldPos = TopLeft;

		TopLeft.x += CAMERA_X * (PARRALEX_EFFECT - (zLevel * 0.01f));
		TopLeft.y += CAMERA_Y * (PARRALEX_EFFECT - (zLevel * 0.01f)) / 2;

		Vec2f BotRight = TopLeft + Vec2f(200, 200);

		if (!isOnScreen(TopLeft, BotRight)) 
		{
			return;
		}

		V_CLOUDS.push_back(Vertex(TopLeft.x,  TopLeft.y,  1, spriteXPos,          0, CLOUDS_COL));
		V_CLOUDS.push_back(Vertex(BotRight.x, TopLeft.y,  1, spriteXPos + 0.25,   0, CLOUDS_COL));
		V_CLOUDS.push_back(Vertex(BotRight.x, BotRight.y, 1, spriteXPos + 0.25,   1, CLOUDS_COL));
		V_CLOUDS.push_back(Vertex(TopLeft.x,  BotRight.y, 1, spriteXPos,          1, CLOUDS_COL));
	}

	bool isOnScreen(Vec2f &in TopLeft, Vec2f &in BotRight)
	{
		Driver@ driver = getDriver();

		TopLeft  = driver.getScreenPosFromWorldPos(TopLeft);
		BotRight = driver.getScreenPosFromWorldPos(BotRight);
		const Vec2f center = TopLeft + BotRight / 2;

		if (dontBotherChecking(center)) // 
		{
			return false;
		}

		if (isVectorOnScreen(TopLeft) || 
			isVectorOnScreen(BotRight) || 
			isVectorOnScreen(Vec2f(TopLeft.x, BotRight.y)) || 
			isVectorOnScreen(Vec2f(BotRight.x, TopLeft.y)) ||
			isVectorOnScreen(center))
		{
			return true;
		}

		return false;
	}

	bool dontBotherChecking(const Vec2f &in pos)
	{
		const f32 posx = pos.x;
		const f32 posy = pos.y;

		if (posx > SCREEN_HEIGHT + 400 && 
			posy > SCREEN_HEIGHT + 400 ||
			posx < -400 &&
			posy < -400)
		{
			return true;
		}

		return false;
	}

	bool isVectorOnScreen(const Vec2f &in pos)
	{
		const f32 posx = pos.x;
		const f32 posy = pos.y;

		if (posx > 0 && posx < SCREEN_WIDTH && 
			posy > 0 && posy < SCREEN_HEIGHT)
		{
			return true;
		}
		
		return false;
	}
}

// Bit of context needed
// it's day time between 0.3 and 0.7
// so I double the worldtime so we have between 0 and 510
// when we go over 255, we start to go backwards
void UpdateCloudColor()
{
	f32 worldTime = (getMap().getDayTime() * 256.0f) * 2.0f;

	if (worldTime > 255) 
	{
		worldTime -= (worldTime % 256) * 2.0f;
	}

	worldTime = Maths::Min(150, worldTime);

	CLOUDS_COL.set(
		worldTime,
		255,
		255,
		255
	);
}