//Made by vamist :>
#define CLIENT_ONLY

class ParticleUI
{
	Vec2f Size;
	Vec2f TopLeft;
	Vec2f BotRight;
	int ImgId;
	Vec2f Vel;
	SColor Col;


	ParticleUI(Vec2f sizeOfImage, Vec2f spawnWorldPos,int imageId)
	{
		Size = sizeOfImage;
		Vec2f temp = Vec2f(sizeOfImage.x / 2,sizeOfImage.y / 2);
		TopLeft = Vec2f(spawnWorldPos.x - temp.x, spawnWorldPos.y - temp.y);
		BotRight = Vec2f(spawnWorldPos.x + temp.x, spawnWorldPos.y + temp.y);
		ImgId = imageId;
		Vel = getRandomVelocity(1, 0.5, 360);	
		Col = SColor(255,1+XORRandom(255),1+XORRandom(255),1 + XORRandom(255));
	}

	void onFakeTick()
	{
		if(Col.getAlpha() != 0)
		{
			Col.setAlpha(Col.getAlpha() - 3);
		}
		//float moveMe = Maths::Sin(getGameTime() / 1.5f);
		
		TopLeft += Vel;
		BotRight += Vel;
		if(Vel.x > 0)
		{
			//Vel += Vec2f(+0.0005,+0.05);
		}
		else
		{
			//Vel += Vec2f(-0.0005,+0.05);
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
		for(int a = 0; a < ParticleUICount.length(); ++a)
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
		return ParticleUICount.length();
	}
}



GroupedParticleUI@ Particles = GroupedParticleUI();
const string mainSpriteName = "testy.png";
Vertex[] v_r_0;
Vertex[] v_r_1;
Vertex[] v_r_2;
Vertex[] v_r_3;
Vertex[] v_r_rajang_0;
Vertex[] v_r_rajang_1;
Vertex[] v_r_rajang_2;

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{

	Particles.Clean();
	Render::addScript(Render::layer_objects, "UIClass", "renderMeHarder", 100.0f);

}

void onTick(CRules@ this)
{
	Particles.onFakeTick();
}

void renderMeHarder(int id)//New onRender
{
	CMap@ map = getMap();
	no(map);
}

void no(CMap@ map)
{
	Render::SetAlphaBlend(true);

	//Check blobs on screen for particle effects
	CBlob@[] blobsInBox;
	map.getBlobsInBox(getDriver().getWorldPosFromScreenPos(Vec2f(0,0)),getDriver().getWorldPosFromScreenPos(Vec2f(getScreenWidth(),getScreenHeight())),@blobsInBox);
	for(int a = 0; a < blobsInBox.length(); ++a)
	{
		CBlob@ blob = blobsInBox[a];
		if(blob !is null)
		{
			CPlayer@ p = blob.getPlayer();
			if(p !is null)
			{
				if(p.hasTag('awootism'))
				{
					if(blob.getTickSinceCreated() % 30 == 0) //TODO spawns more then one (remember its onRender and not onTick)
					{
						int result = XORRandom(4);
						ParticleUI@ newParticle;
						switch(result)
						{
							case 0:
								@newParticle = ParticleUI(Vec2f(10,3),blob.getPosition(),0);
								Particles.AddNewUI(newParticle);
							break;

							case 1:
								@newParticle = ParticleUI(Vec2f(10,5),blob.getPosition(),1);
								Particles.AddNewUI(newParticle);
							break;

							case 2:
								@newParticle = ParticleUI(Vec2f(12,5),blob.getPosition(),2);
								Particles.AddNewUI(newParticle);
							break;

							case 3:
								@newParticle = ParticleUI(Vec2f(10,3),blob.getPosition(),0);
								Particles.AddNewUI(newParticle);
							break;	

						}
						
					}
				}

				if(p.getUsername() == "digga")
				{
					if(blob.getTickSinceCreated() % 30 == 0) //TODO spawns more then one (remember its onRender and not onTick)
					{
						int result = XORRandom(3);
						ParticleUI@ newParticle;
						switch(result)
						{
							case 0:
								@newParticle = ParticleUI(Vec2f(12,3),blob.getPosition(),100);
								Particles.AddNewUI(newParticle);
							break;

							case 1:
								@newParticle = ParticleUI(Vec2f(15,4),blob.getPosition(),101);
								Particles.AddNewUI(newParticle);
							break;

							case 2:
								@newParticle = ParticleUI(Vec2f(18,4),blob.getPosition(),102);
								Particles.AddNewUI(newParticle);
							break;	

						}
					}
				}
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

				case 101:
					v_r_rajang_1.push_back(Vertex(tP.TopLeft.x,  tP.TopLeft.y,  1, 0, 0, tP.Col));
					v_r_rajang_1.push_back(Vertex(tP.BotRight.x, tP.TopLeft.y,  1, 1, 0, tP.Col));
					v_r_rajang_1.push_back(Vertex(tP.BotRight.x, tP.BotRight.y, 1, 1, 1, tP.Col));
					v_r_rajang_1.push_back(Vertex(tP.TopLeft.x,  tP.BotRight.y, 1, 0, 1, tP.Col));
				break;

				case 102:
					v_r_rajang_2.push_back(Vertex(tP.TopLeft.x,  tP.TopLeft.y,  1, 0, 0, tP.Col));
					v_r_rajang_2.push_back(Vertex(tP.BotRight.x, tP.TopLeft.y,  1, 1, 0, tP.Col));
					v_r_rajang_2.push_back(Vertex(tP.BotRight.x, tP.BotRight.y, 1, 1, 1, tP.Col));
					v_r_rajang_2.push_back(Vertex(tP.TopLeft.x,  tP.BotRight.y, 1, 0, 1, tP.Col));
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
			Render::RawQuads("digga0.png", v_r_rajang_0);
			v_r_rajang_0.clear();
		}
		if(v_r_rajang_1.length() > 0)
		{
			Render::RawQuads("digga1.png", v_r_rajang_1);
			v_r_rajang_1.clear();
		}
		if(v_r_rajang_2.length() > 0)
		{
			Render::RawQuads("digga2.png", v_r_rajang_2);
			v_r_rajang_2.clear();
		}
	}
	
}


//other stuff

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	if(player !is null)
	{
		if(player.getUsername() == "digga")
		{
			player.Tag("awootism");
			player.Sync("awootism",false);
		}
	}
}
