//////////////////////////////////////////////////////
//
//  BulletTrails.as - Vamist
//
//  Never got round to finishing this
//  This just added a fade effect behind the bullets 
//  so it looks a bit better
//

class BulletFade
{
	SColor Col = SColor(255,255,255,255);

	Vec2f TopLeft;
	Vec2f BotLeft;
	Vec2f TopRight;
	Vec2f BotRight;

	BulletFade(Vec2f CurrentPos)
	{
		TopLeft = CurrentPos;
		BotLeft = CurrentPos;
		TopRight = CurrentPos;
		BotRight = CurrentPos;
	}

	void JoinQueue(Vec2f FrontLeft, Vec2f FrontRight)
	{
		/*TimeLeft -=1;
		if(Alpha < 5)
		{
			TimeLeft = 0;
			Alpha = 0;
		}
		Alpha -= 5 * (60 * getRenderDeltaTime());

		Col.setBlue(Col.getBlue() + 1);
		Col.setGreen(Col.getGreen() - 1);
		Col.setAlpha(Alpha);
		float toAdd = 0.20 * ((60 * getRenderDeltaTime()));*/


		/*v_r_fade.push_back(Vertex(FrontLeft.x - 0.7, FrontLeft.y + 0.7,     1, 1, 0, Col)); //top right
		v_r_fade.push_back(Vertex(FrontRight.x - 0.7, FrontRight.y - 0.7,        1, 0, 0, Col)); //top left
		v_r_fade.push_back(Vertex(BotRight.x + 0.7, BotRight.y + 0.7,       1, 0, 1, Col)); //bot left
		v_r_fade.push_back(Vertex(BotLeft.x+ 0.7, BotLeft.y - 0.7,      1, 1, 1, Col)); //bot right*/

		
		//Vec2f TopLeft  = Vec2f(newPos.x -0.7, newPos.y-3);
		//Vec2f TopRight = Vec2f(newPos.x -0.7, newPos.y+3);
		//Vec2f BotLeft  = Vec2f(newPos.x +0.7, newPos.y-3);
		//Vec2f BotRight = Vec2f(newPos.x +0.7, newPos.y+3);
		
		
		//v_r_bullet.push_back(Vertex(TopLeft.x,  TopLeft.y,      1, 0, 0, SColor(255,255,255,255))); //top left
		//v_r_bullet.push_back(Vertex(TopRight.x, TopRight.y,     1, 1, 0, SColor(255,255,255,255))); //top right
		//v_r_bullet.push_back(Vertex(BotRight.x, BotRight.y,     1, 1, 1, SColor(255,255,255,255))); //bot right
		//v_r_bullet.push_back(Vertex(BotLeft.x,  BotLeft.y,      1, 0, 1, SColor(255,255,255,255))); //bot left
	}
}
