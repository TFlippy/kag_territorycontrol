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

Vertex[] clouds;

void onInit(CRules@ this)
{
    onReload(this);
}

void onReload(CRules@ this)
{

    if (isClient())
    {
        Render::RemoveScript(this.get_u16("callback"));
        int callback = Render::addScript(Render::layer_background, "Clouds", "RenderClouds", -10000.0f);
        this.set_u16("callback", callback);
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

    Render::SetAlphaBlend(true);
    Render::SetZBuffer(true, true);
    Render::RawQuads("cloud1.png", clouds);
}