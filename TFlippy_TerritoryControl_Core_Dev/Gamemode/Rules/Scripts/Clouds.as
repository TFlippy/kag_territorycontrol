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
//
// END

Random@ RAND = Random();
Clouds@[] C_CLOUDS;
Vertex[] V_CLOUDS;

const Vec2f MOVE_VEL = Vec2f(0.5,0);
const u16 CLOUD_COOLDOWN = 150;
const u16 PADDING = 250;

SColor CLOUDS_COL = color_white; // temp col, get's changed based on time

f32 FRAME_TIME = 0.0f;
f32 CAMERA_X = 0.0f;
f32 CAMERA_Y = 0.0f;
f32 PARRALEX_EFFECT = 0.2f;
u16 CLEAR_WIDTH_POS = 0;
u16 SPAWN_VARIATION_HEIGHT = 0;
u16 LAST_ATTEMPT = 0;

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
	SPAWN_VARIATION_HEIGHT = 0;

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
				cbs.write_s16(RAND.NextRanged(SPAWN_VARIATION_HEIGHT)); // only send y instead of vec2f, saves space
				cbs.write_u16(getGameTime());
				cbs.write_u8(RAND.NextRanged(5));

				this.SendCommand(this.getCommandID("new_cloud"), cbs); 
			}

		}
	}

	if (isClient())
	{
		CLEAR_WIDTH_POS = (map.tilemapwidth * 8) + PADDING; // TEMP WORK AROUND
		SPAWN_VARIATION_HEIGHT = map.tilemapwidth / 2;

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

	CAMERA_X = getCamera().getPosition().x; // Safe to say we won't be rendering if we don't have a camera
	FRAME_TIME += Render::getRenderDeltaTime() * getTicksASecond();  // We are using this because ApproximateCorrectionFactor is lerped

	for (int a = 0; a < size; a++)
	{
		C_CLOUDS[a].SendToRenderer();
	}

	Render::SetAlphaBlend(true); // alpha required to look more 'cloudy'
	Render::SetZBuffer(true, true); // required to show up being tiles 
	Render::RawQuads("cloudsall.png", V_CLOUDS);

	V_CLOUDS.clear(); // clear after rendering
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

		for (int a = 0; a < spriteType; a++) // Texture uv 'hacks'
		{
			spriteXPos += 0.25;
		}

		for (int a = creationTick; a < getGameTime(); a++) // maybe add some sort of cap, could cause stutters if we get a packet that was delayed
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
		return true;
	}

	void SendToRenderer() // TODO -> Check if its on screen before passing it to be rendered
	{	
		Vec2f TopLeft = Vec2f_lerp(oldPos, goalPos, FRAME_TIME);
		oldPos = TopLeft;

		TopLeft.x += (CAMERA_X * PARRALEX_EFFECT);

		if (!isOnScreen(TopLeft)) 
		{
			return;
		}

		Vec2f BotRight = TopLeft + Vec2f(200, 200);

		V_CLOUDS.push_back(Vertex(TopLeft.x,  TopLeft.y,  1, spriteXPos,          0, CLOUDS_COL));
		V_CLOUDS.push_back(Vertex(BotRight.x, TopLeft.y,  1, spriteXPos + 0.25,   0, CLOUDS_COL));
		V_CLOUDS.push_back(Vertex(BotRight.x, BotRight.y, 1, spriteXPos + 0.25,   1, CLOUDS_COL));
		V_CLOUDS.push_back(Vertex(TopLeft.x,  BotRight.y, 1, spriteXPos,          1, CLOUDS_COL));
	}

	bool isOnScreen(Vec2f parralexPos)
	{
		Driver@ driver = getDriver();
		const Vec2f pos = driver.getScreenPosFromWorldPos(parralexPos + Vec2f(100, 100)); // (+100 100 based on sprite size per cloud)

        if(((pos.x > -300 && pos.x < driver.getScreenWidth() * 1.2) && 
			(pos.y > -150 && pos.y < driver.getScreenHeight() * 1.2))) // Tweak these settings more
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