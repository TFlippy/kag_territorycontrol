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

Random@ RAND = Random();
Clouds@[] C_CLOUDS;
Vertex[] V_CLOUDS;

const Vec2f MOVE_VEL = Vec2f(0.5,0);
const u16 CLOUD_COOLDOWN = 150;
const u16 PADDING = 250;

SColor CLOUDS_COL = SColor(200,0 ,0 ,0);

f32 FRAME_TIME = 0.0f;
f32 CAMERA_X = 0.0f;
f32 CAMERA_Y = 0.0f;
f32 PARRALEX_EFFECT = 0.2f;
u16 CLEAR_WIDTH_POS = 0;
u16 SPAWN_VARIATION_HEIGHT = 0;
u16 LAST_ATTEMPT = 0;

void onInit(CRules@ this)
{
	this.addCommandID("new_cloud"); 

	int callback = Render::addScript(Render::layer_background, "Clouds", "RenderClouds", -10000.0f);
	this.set_u16("callback", callback);

	onRestart(this);
}

void onRestart(CRules@ this)
{
	LAST_ATTEMPT = 0;
	CLEAR_WIDTH_POS = (getMap().tilemapwidth * 8) + PADDING;
	SPAWN_VARIATION_HEIGHT = getMap().tilemapwidth / 2;
}

// Very useful for debugging, don't remove 
void onReload(CRules@ this)
{
	onRestart(this);

	if (isClient())
	{
		Render::RemoveScript(this.get_u16("callback"));
		int callback = Render::addScript(Render::layer_background, "Clouds", "RenderClouds", -10000.0f);
		this.set_u16("callback", callback);
	}
}
//

void onTick(CRules@ this) 
{
	if (isServer())
	{
		uint gametime = getGameTime();
		if (LAST_ATTEMPT < gametime)
		{
			LAST_ATTEMPT = gametime + CLOUD_COOLDOWN;
			if (RAND.NextRanged(100) < 50)
			{
				CBitStream cbs;
				cbs.write_s16(RAND.NextRanged(SPAWN_VARIATION_HEIGHT)); // only send y, saves space
				cbs.write_u16(getGameTime());
				cbs.write_u8(RAND.NextRanged(5));

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
			if (!C_CLOUDS[a].MoveCloud()) // return's false if its out the map
			{
				C_CLOUDS.erase(a);
				a--;
			}
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (!isClient()) { return; }

	if (cmd == this.getCommandID("new_cloud"))
	{
		s16 yPos = params.read_s16();
		u16 gameTime = params.read_u16();
		u16 spriteType = params.read_u8();

		C_CLOUDS.push_back(Clouds(Vec2f(-PADDING, yPos), gameTime, spriteType));
	}
}


void RenderClouds(int id)
{
	int size = C_CLOUDS.size();

	if (size == 0) { return; } // dont waste a draw call on an empty size

	CCamera@ camera = getCamera();

	if (camera is null) { return; }

	Vec2f pos = camera.getPosition();

	CAMERA_X = pos.x;
	CAMERA_Y = pos.y;

	FRAME_TIME += Render::getRenderDeltaTime() * getTicksASecond(); 

	for (int a = 0; a < size; a++)
	{
		C_CLOUDS[a].SendToRenderer();
	}

	Render::SetAlphaBlend(true);
	Render::SetZBuffer(true, true);
	Render::RawQuads("cloudsall.png", V_CLOUDS);
	V_CLOUDS.clear();
}




class Clouds
{
	Vec2f goalPos;
	Vec2f oldPos;
	f32 spriteXPos;

	Clouds (Vec2f position, u16 creationTick, u8 spriteType) 
	{
		goalPos = position;
		oldPos = position;
		for (int a = 0; a < spriteType; a++)
		{
			spriteXPos += 0.25;
		}

		for (int a = creationTick; a < getGameTime(); a++) // maybe add some sort of cap, could cause stutters if we get a packet that was delayed
		{
			MoveCloud(); // sync clouds
		}  
	}

	bool MoveCloud() // done per tick
	{
		if (goalPos.x > CLEAR_WIDTH_POS)
		{
			return false;
		}

		goalPos += MOVE_VEL;
		return true;
	}

	void SendToRenderer()
	{
		Vec2f TopLeft = Vec2f_lerp(oldPos, goalPos, FRAME_TIME);
		oldPos = TopLeft;

		TopLeft.x += (CAMERA_X * PARRALEX_EFFECT);

		Vec2f BotRight = TopLeft + Vec2f(200, 200);

		V_CLOUDS.push_back(Vertex(TopLeft.x,  TopLeft.y,  1, spriteXPos,          0, CLOUDS_COL));
		V_CLOUDS.push_back(Vertex(BotRight.x, TopLeft.y,  1, spriteXPos + 0.25,   0, CLOUDS_COL));
		V_CLOUDS.push_back(Vertex(BotRight.x, BotRight.y, 1, spriteXPos + 0.25,   1, CLOUDS_COL));
		V_CLOUDS.push_back(Vertex(TopLeft.x,  BotRight.y, 1, spriteXPos,          1, CLOUDS_COL));
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
		worldTime -= (worldTime % 255) * 2.0f;
	}

	worldTime = Maths::Min(150, worldTime);

	CLOUDS_COL.set(
		worldTime,
		255,
		255,
		255
	);
}