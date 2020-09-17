/////////////////////////////////////////////
// Cloud controller made by Vamist :)
// Oi twat, no stealing without perms 
// 
//
// Clouds are mostly synced
// Server will send a command when its time to spawn in a new cloud
// Clients just render
//
//
// We can use script wide variables because cloud.as will only ever be in use once.

int callback_id = 0;
Vertex[] clouds;

void onInit(CRules@ this)
{
    if (isClient()) 
    {
       //callback_id = Render::addScript(Render::layer_tiles, "Clouds", "RenderClouds", 1.0f);
    }
}


void RenderClouds(int id)
{
    clouds.clear();
    Vec2f TopLeft = getControls().getMouseWorldPos();
    Vec2f BotRight = TopLeft + Vec2f(30, 30);
    clouds.push_back(Vertex(TopLeft.x,  TopLeft.y,  1, 0, 0, color_white));
	clouds.push_back(Vertex(BotRight.x, TopLeft.y,  1, 1, 0, color_white));
	clouds.push_back(Vertex(BotRight.x, BotRight.y, 1, 1, 1, color_white));
	clouds.push_back(Vertex(TopLeft.x,  BotRight.y, 1, 0, 1, color_white));

    //Render::RawQuads("cloud1.png", clouds);
}