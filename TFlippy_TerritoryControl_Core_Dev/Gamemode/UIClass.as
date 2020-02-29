//Made by vamist :>
#define CLIENT_ONLY

bool active = false;
int id = 0;

class ParticleUI
{
	Vec2f Size;
	Vec2f TopLeft;
	Vec2f BotRight;
	int ImgId;
	u8 Effect;
	Vec2f Vel;
	SColor Col;
	int TimeMade;

	ParticleUI(Vec2f sizeOfImage, Vec2f spawnWorldPos,int imageId, u8 ParticleEffect = 0)
	{
		Size = sizeOfImage;
		Vec2f temp = Vec2f(sizeOfImage.x / 2,sizeOfImage.y / 2);
		TopLeft = Vec2f(spawnWorldPos.x - temp.x, spawnWorldPos.y - temp.y);
		BotRight = Vec2f(spawnWorldPos.x + temp.x, spawnWorldPos.y + temp.y);
		ImgId = imageId;
		Effect = ParticleEffect;
		if(ParticleEffect == 0)
		{
			Vel = getRandomVelocity(1, 0.5, 360);	
			Col = SColor(255,1+XORRandom(255),1+XORRandom(255),1 + XORRandom(255));
		}
		else
		{
			TimeMade = getGameTime();	
			Vel = getRandomVelocity(1, 0.5, 360);	
			Col = SColor(200,255,255,255);
		}
	}

	void onFakeTick()
	{
		//0 = Rainbow pulse out
		//1 = rajangs heart effect (fade in and out)
		switch(Effect)
		{
			case 0:
			{
				if(Col.getAlpha() != 0)
				{
					Col.setAlpha(Col.getAlpha() - 3);
				}
				//float moveMe = Maths::Sin(getGameTime() / 1.5f);
				
				TopLeft += Vel;
				BotRight += Vel;
			}	
			break;


			case 1:
			{
				int timeAlive = getGameTime() - TimeMade;
				if(timeAlive < 15)
				{
					Col.setAlpha(Col.getAlpha() - 10);
					BotRight -= Vec2f(0.2,0.2);
					TopLeft += Vec2f(0.2,0.2);
				}
				else if (timeAlive < 30)
				{
					Col.setAlpha(Col.getAlpha() + 10);
					BotRight += Vec2f(0.2,0.2);
					TopLeft -= Vec2f(0.2,0.2);
				}
				else
				{
					Col.setAlpha(Col.getAlpha() - 10);
					BotRight -= Vec2f(0.2,0.2);
					TopLeft += Vec2f(0.2,0.2);
				}
				TopLeft += Vel;
				BotRight += Vel;
			}
			break;
			
		}
		
	}

	bool isTimeToDie()
	{
		if(Col.getAlpha() == 0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

}


class GroupedParticleUI
{
	ParticleUI[] ParticleUICount;

	GroupedParticleUI()
	{
	}

	void AddNewUI(ParticleUI UI)
	{
		ParticleUICount.push_back(UI);
	}

	void Clean()
	{
		ParticleUICount.clear();
	}

	void onFakeTick()
	{
		int size = ParticleUICount.size();
		for(int a = 0; a < size; ++a)
		{
			ParticleUICount[a].onFakeTick();
			if(ParticleUICount[a].isTimeToDie())
			{
				ParticleUICount.removeAt(a);
				a++;
			}
		}
	}

	int ArrayCount()
	{
		return ParticleUICount.size();
	}
}



GroupedParticleUI@ Particles = GroupedParticleUI();
Vertex[] v_r_0;
Vertex[] v_r_1;
Vertex[] v_r_2;
Vertex[] v_r_3;
Vertex[] v_r_rajang_0;

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	return;
	CPlayer@ player = getLocalPlayer();
	if (player !is null && player.getUsername() == "Vamist")
	{
		active = true;
		id = Render::addScript(Render::layer_objects, "UIClass", "renderMeHarder", 0.0f);
	}

	Reset(this);
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	return;
	if (player.getUsername() == "Vamist")
	{
		active = true;
		id = Render::addScript(Render::layer_objects, "UIClass", "renderMeHarder", 0.0f);
	}
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	return;
	if (player.getUsername() == "digga")
	{
		active = false;
		Render::RemoveScript(id);
		Reset(this);
	}
}

void Reset(CRules@ this)
{
	Particles.Clean();
}

void onTick(CRules@ this)
{
	if (active)
	{
		Particles.onFakeTick();
	}
}

void renderMeHarder(int id)//New onRender
{
	no(getMap());
}

void no(CMap@ map)
{
	Render::SetAlphaBlend(true);

	CPlayer@ raj = getPlayerByUsername('digga');
	if (raj !is null)
	{
		CBlob@ blob = raj.getBlob();
		if (blob !is null)
		{
			if (blob.getTickSinceCreated() % 30 == 0) //TODO spawns more then one (remember its onRender and not onTick)
			{
				ParticleUI@ newParticle =  ParticleUI(Vec2f(11,12),blob.getPosition(),100,1);
				Particles.AddNewUI(newParticle);
			}
		}
	}
	//End


	//Render any particle effects
	if(Particles.ArrayCount() > 0)
	{
		
		for(int a = 0; a < Particles.ArrayCount(); ++a)
		{
			ParticleUI@ tP = Particles.ParticleUICount[a];
			if(tP.isTimeToDie())
			{
				Particles.ParticleUICount.removeAt(a);
				a++;
				continue;
			}
			switch(tP.ImgId)
			{
				case 0:
					v_r_0.push_back(Vertex(tP.TopLeft.x,  tP.TopLeft.y,  1, 0, 0, tP.Col));
					v_r_0.push_back(Vertex(tP.BotRight.x, tP.TopLeft.y,  1, 1, 0, tP.Col));
					v_r_0.push_back(Vertex(tP.BotRight.x, tP.BotRight.y, 1, 1, 1, tP.Col));
					v_r_0.push_back(Vertex(tP.TopLeft.x,  tP.BotRight.y, 1, 0, 1, tP.Col));
				break;

				case 1:
					v_r_1.push_back(Vertex(tP.TopLeft.x,  tP.TopLeft.y,  1, 0, 0, tP.Col));
					v_r_1.push_back(Vertex(tP.BotRight.x, tP.TopLeft.y,  1, 1, 0, tP.Col));
					v_r_1.push_back(Vertex(tP.BotRight.x, tP.BotRight.y, 1, 1, 1, tP.Col));
					v_r_1.push_back(Vertex(tP.TopLeft.x,  tP.BotRight.y, 1, 0, 1, tP.Col));
				break;

				case 2:
					v_r_2.push_back(Vertex(tP.TopLeft.x,  tP.TopLeft.y,  1, 0, 0, tP.Col));
					v_r_2.push_back(Vertex(tP.BotRight.x, tP.TopLeft.y,  1, 1, 0, tP.Col));
					v_r_2.push_back(Vertex(tP.BotRight.x, tP.BotRight.y, 1, 1, 1, tP.Col));
					v_r_2.push_back(Vertex(tP.TopLeft.x,  tP.BotRight.y, 1, 0, 1, tP.Col));
				break;

				case 3:
					v_r_3.push_back(Vertex(tP.TopLeft.x,  tP.TopLeft.y,  1, 0, 0, tP.Col));
					v_r_3.push_back(Vertex(tP.BotRight.x, tP.TopLeft.y,  1, 1, 0, tP.Col));
					v_r_3.push_back(Vertex(tP.BotRight.x, tP.BotRight.y, 1, 1, 1, tP.Col));
					v_r_3.push_back(Vertex(tP.TopLeft.x,  tP.BotRight.y, 1, 0, 1, tP.Col));
				break;

				case 100:
					v_r_rajang_0.push_back(Vertex(tP.TopLeft.x,  tP.TopLeft.y,  1, 0, 0, tP.Col));
					v_r_rajang_0.push_back(Vertex(tP.BotRight.x, tP.TopLeft.y,  1, 1, 0, tP.Col));
					v_r_rajang_0.push_back(Vertex(tP.BotRight.x, tP.BotRight.y, 1, 1, 1, tP.Col));
					v_r_rajang_0.push_back(Vertex(tP.TopLeft.x,  tP.BotRight.y, 1, 0, 1, tP.Col));
				break;
			}
			
		}
		if(v_r_0.length() > 0)
		{
			Render::RawQuads("face0.png", v_r_0);
			v_r_0.clear();
		}
		if(v_r_1.length() > 0)
		{
			Render::RawQuads("face1.png", v_r_1);
			v_r_1.clear();
		}
		if(v_r_2.length() > 0)
		{
			Render::RawQuads("face2.png", v_r_2);
			v_r_2.clear();
		}
		if(v_r_3.length() > 0)
		{
			Render::RawQuads("face3.png", v_r_3);
			v_r_3.clear();
		}
		if(v_r_rajang_0.length() > 0)
		{
			Render::RawQuads("Heart.png", v_r_rajang_0);
			v_r_rajang_0.clear();
		}
	}
	
}