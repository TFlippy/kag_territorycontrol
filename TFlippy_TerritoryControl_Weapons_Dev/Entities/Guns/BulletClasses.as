
//Bullet


//Main classes for bullets
const SColor trueWhite = SColor(255,255,255,255);
Driver@ PDriver = getDriver();
const int ScreenX = getDriver().getScreenWidth();
const int ScreenY = getDriver().getScreenWidth();


class BulletObj
{
	//Global bullet stuff
	Vec2f Startpos;
	Vec2f Endpos;
	Vec2f CurrentPos;
	Vec2f LastPos;
	
	float sX;//Size x
	float sY;//Size y

	SColor Col;
	//

	BulletObj(Vec2f startPos, Vec2f endPos, SColor colour, float x, float y)//Add stuff you want
	{
		CurrentPos = startPos;
		Startpos = startPos;
		LastPos = startPos;
		Endpos = endPos;
		Col = colour;
		sX = x;
		sY = y;
	}

	void JoinQueue()//every bullet gets forced to join the queue in onRenders, so we use this to calc to position
	{   
		//This will need changing
		//See if the bullet is on our screen, if not, dont render it
		//Saves a lot of fps, but since you only render for 1 tick, it might not be needed

		/*const Vec2f xLast = PDriver.getScreenPosFromWorldPos(LastPos);
		const Vec2f xNew  = PDriver.getScreenPosFromWorldPos(CurrentPos);
		if(!(xNew.x > 0 && xNew.x < ScreenX))//Is our main position still on screen?
		{//No, so lets left if we just 'left'
			if(!(xLast.x > 0 && xLast.x < ScreenX))//Was our last position on screen?
			{//No
				return;
			}
		}*/

		//Lerp
		const float blend = 1 - Maths::Pow(0.5f, getRenderApproximateCorrectionFactor());//EEEE
		const f32 x = lerp(LastPos.x, CurrentPos.x, blend);
		const f32 y = lerp(LastPos.y, CurrentPos.y, blend);
		Vec2f newPos = Vec2f(x,y);
		LastPos.x = x;
		LastPos.y = y;
		//End

		f32 angle = Vec2f(CurrentPos.x-newPos.x, CurrentPos.y-newPos.y).getAngleDegrees();//Sets the angle


		Vec2f TopLeft  = Vec2f(newPos.x -sX, newPos.y-sY);//New positions
		Vec2f TopRight = Vec2f(newPos.x -sX, newPos.y+sY);
		Vec2f BotLeft  = Vec2f(newPos.x +sX, newPos.y-sY);
		Vec2f BotRight = Vec2f(newPos.x +sX, newPos.y+sY);

		angle = -((angle % 360) + 90);

		BotLeft.RotateBy( angle,newPos);
		BotRight.RotateBy(angle,newPos);
		TopLeft.RotateBy( angle,newPos);
		TopRight.RotateBy(angle,newPos);   

		v_r_bullet.push_back(Vertex(TopLeft.x,  TopLeft.y,      0, 0, 0,   Col)); //top left
		v_r_bullet.push_back(Vertex(TopRight.x, TopRight.y,     0, 1, 0,   Col)); //top right
		v_r_bullet.push_back(Vertex(BotRight.x, BotRight.y,     0, 1, 1,   Col)); //bot right
		v_r_bullet.push_back(Vertex(BotLeft.x,  BotLeft.y,      0, 0, 1,   Col)); //bot left
	
	}

	
}


class BulletHolder//Main bullet calc class
{
	BulletObj[] bullets;//Array to view what bullets are alive in game
	BulletHolder(){}//Dont really need to do anything oninit

	/*void FakeOnTick(CRules@ this)//Get each bullet and tell it to do its next tick
	{
		CMap@ map = getMap();
		for(int a = 0; a < bullets.length(); a++)
		{
			BulletObj@ bullet = bullets[a];
			if(bullet.onFakeTick(map))
			{
				bullets.removeAt(a);
			}
		}  
	}*/

  
	void FillArray()
	{
		for(int a = 0; a < bullets.length(); a++)//Tell each bullet to go join the render
		{
			bullets[a].JoinQueue();//Dont need to cahce since we are only using once
		}
	}

	void AddNewBullet(BulletObj@ this)//Add a new bullet, and calc 
	{
		bullets.push_back(this);
	}
	
	void Clean()//Not needed but is useful
	{
		bullets.clear();
	}

	int ArrayCount()//Same as above
	{
		return bullets.length();
	}
}


const float lerp(float v0, float v1, float t)//2 lerps so you can pick what works best
{//Goldenguys would have bigger gaps, where as mine didnt, but you might have different results
	//return (1 - t) * v0 + t * v1; //Golden guys version of lerp
	return v0 + t * (v1 - v0); //vams version
}


const bool CollidesWithPlatform(CBlob@ blob, const Vec2f velocity)//Stolen from rock.as, its to see if we collide with the platform or not at x angle
{
	const f32 platform_angle = blob.getAngleDegrees();	
	Vec2f direction = Vec2f(0.0f, -1.0f);
	direction.RotateBy(platform_angle);
	const float velocity_angle = direction.AngleWith(velocity);

	return !(velocity_angle > -90.0f && velocity_angle < 90.0f);
}

