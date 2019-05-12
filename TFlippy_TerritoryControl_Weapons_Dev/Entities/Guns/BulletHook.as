//Hooked into gamemode.cfg
//Required for guns
//We use CRules so we only need to run ONE
//could define server only

#include "BulletClasses.as";

BulletHolder@ BulletGrouped = BulletHolder();//We only need one
Vertex[] v_r_bullet;
//Vertex[] v_r_fade; //Was planned, i might work on it for TC, its the particle for bullet travel

void onInit(CRules@ this)
{
	Reset(this);
	Render::addScript(Render::layer_postworld, "BulletHook", "BulletMainRender", 0.0f);//Only add once
}

void onRestart(CRules@ this)
{
	Reset(this);
}

/*void onTick(CRules@ this)
{
	//BulletGrouped.FakeOnTick(this); //This is used to calc each bullet pos
}*/

void Reset(CRules@ this)
{
	v_r_bullet.clear();//Clear each array just incase
	//v_r_fade.clear();// ^
}

void BulletMainRender(int id)//New onRender
{
	//We use this area to add arguments, currently not needed
	RenderMe();//and pass it to get rendered
}

void RenderMe()//Bullets
{

	//Render::SetAlphaBlend(true);//If you want alpha at the expensive of no Z control
	
	BulletGrouped.FillArray();//fill up the vortex with what we need
	if(v_r_bullet.length() > 0)//if we didnt do that no reason
	{
		Render::RawQuads("Bullet.png", v_r_bullet);//r e n d e r my child
		v_r_bullet.clear();//and we clean all
	}

}

void AddBullet(Vec2f Startpos, Vec2f EndPos, SColor col = SColor(255,255,255,255), float x = 0.7, float y = 3)
{
	BulletGrouped.AddNewBullet(BulletObj(Startpos,EndPos,col,x,y));
}