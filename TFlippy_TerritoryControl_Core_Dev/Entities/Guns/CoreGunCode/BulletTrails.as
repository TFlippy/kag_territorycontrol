

class BulletFade
{
    SColor Col = SColor(255,255,255,255);
	SColor BackCol = SColor(0,255,255,255);

    Vec2f Back;
    Vec2f Front;
	Vec2f OldFront;
	f32 MaxTime = 30;
	f32 TimeLeft = MaxTime;
	
	string Texture = "Fade.png";

    BulletFade(Vec2f p)
    {
        Back = p;
        Front = p;
		OldFront = p;
    }

    void onRender()
    {
		if(Front == OldFront)TimeLeft -= 3.0f * ((1000.0f/30.0f) * getRenderDeltaTime());
		Col.setAlpha((TimeLeft/MaxTime)*255.0f);
		BackCol.setAlpha((TimeLeft/MaxTime)*128.0f);
		
		OldFront = Front;
		
		if(TimeLeft > 0){
			Vec2f Over = Vec2f(0,1);
			Vec2f Under = Vec2f(0,-1);
			Vec2f Aim = Back-Front;
			Over.RotateByDegrees(-Aim.AngleDegrees());
			Under.RotateByDegrees(-Aim.AngleDegrees());
			
			Vertex[]@ fade_vertex;
			if(getRules().exists(Texture))
			if(getRules().get(Texture, @fade_vertex)){
				fade_vertex.push_back(Vertex(Front.x+Under.x, Front.y+Under.y, 1, 0, 1, Col)); //top left
				fade_vertex.push_back(Vertex(Front.x+Over.x, Front.y+Over.y, 1, 1, 1, Col)); //top right
				fade_vertex.push_back(Vertex(Back.x+Over.x*0.5f, Back.y+Over.y*0.5f,1, 1, 0, BackCol)); //bot right
				fade_vertex.push_back(Vertex(Back.x+Under.x*0.5f, Back.y+Under.y*0.5f,1, 0, 0, BackCol)); //bot left
			}
		}
    }
    
    void Kill()
    {
        TimeLeft = 0;
    }
}
