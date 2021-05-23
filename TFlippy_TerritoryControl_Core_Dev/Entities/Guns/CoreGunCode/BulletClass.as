//////////////////////////////////////////////////////
//
//  BulletClass.as - Vamist
//
//  CORE FILE
//  
//  A bit messy, stuff gets removed and added as time 
//  goes on. Handles the bullet class, what it hits
//  onTick, onRender etc
//
//  Try not poke around here unless you need to
//  Some code here is messy
//

#include "BulletCase.as";
#include "Recoil.as";
#include "BulletParticle.as";
#include "knocked.as";

const SColor trueWhite = SColor(255,255,255,255);
Driver@ PDriver = getDriver();
const int ScreenX = getDriver().getScreenWidth();
const int ScreenY = getDriver().getScreenWidth();

class BulletObj
{
	CBlob@ hoomanShooter;
	CBlob@ gunBlob;

	BulletFade@ Fade;

	Vec2f TrueVelocity;
	Vec2f CurrentPos;
	Vec2f BulletGrav;
	Vec2f RenderPos;
	Vec2f OldPos;
	Vec2f LastPos;
	Vec2f Gravity;
	Vec2f KB;
	f32 StartingAimPos;
	f32 lastDelta;
	f32 Damage;
	u8 TeamNum;
	u8 Speed;
	u8 AmmoType;
	string FleshHitSound;
	string ObjectHitSound;
	s8 TimeLeft;
	bool FacingLeft;


	BulletObj(CBlob@ humanBlob, CBlob@ gun, f32 angle, Vec2f pos)
	{
		CurrentPos = pos;
		FacingLeft = humanBlob.isFacingLeft();
		BulletGrav = gun.get_Vec2f("grav");
		Damage   = gun.get_f32("damage");
		TeamNum  = gun.getTeamNum();
		TimeLeft = gun.get_u8("TTL");
		KB       = gun.get_Vec2f("KB");
		Speed    = gun.get_u8("speed");
		AmmoType = gun.get_u8("ammo_type");
		FleshHitSound  = gun.get_string("flesh_hit_sound");
		ObjectHitSound = gun.get_string("object_hit_sound");
		@hoomanShooter = humanBlob;
		StartingAimPos = angle;

		OldPos    = CurrentPos;
		LastPos   = CurrentPos;
		RenderPos = CurrentPos;

		@gunBlob  = gun;
		lastDelta = 0;
		//@Fade = BulletGrouped.addFade(CurrentPos);
	}

	void SetStartAimPos(Vec2f aimPos, bool isFacingLeft)
	{
		Vec2f aimvector = aimPos - CurrentPos;
		StartingAimPos = isFacingLeft ? -aimvector.Angle() + 180.0f : -aimvector.Angle();
	}

	bool onFakeTick(CMap@ map)
	{
		//Time to live check
		TimeLeft--;
		if (TimeLeft == 0)
		{
			return true;
		}

		// Angle update
		OldPos = CurrentPos;
		Gravity -= BulletGrav;
		const f32 angle = StartingAimPos * (FacingLeft ? 1 : 1);
		Vec2f dir = Vec2f((FacingLeft ? -1 : 1), 0.0f).RotateBy(angle);
		CurrentPos = ((dir * Speed) - (Gravity * Speed)) + CurrentPos;
		TrueVelocity = CurrentPos - OldPos;


		bool endBullet = false;
		bool breakLoop = false;
		HitInfo@[] list;
		if (map.getHitInfosFromRay(OldPos, -(CurrentPos - OldPos).Angle(), (OldPos - CurrentPos).Length(), hoomanShooter, @list))
		{
			for (int a = 0; a < list.length(); a++)
			{
				breakLoop = false;
				HitInfo@ hit = list[a];
				Vec2f hitpos = hit.hitpos;
				CBlob@ blob = @hit.blob;
				if (blob !is null)
				{   
					int hash = blob.getName().getHash();
					switch (hash)
					{
						/*case 1296319959: // Stone_door
						case 213968596:  // Wooden_door
						case 916369496:  // Trapdoor
						{
							CurrentPos = hitpos;
							breakLoop = true;
							Sound::Play(ObjectHitSound, hitpos, 1.5f);

							if (isServer())
							{
								if (hash == 213968596)
								{
									map.server_DestroyTile(hitpos, Damage);
								}
							}
						}
						break;*/

						case 804095823: // platform
						case 377147311: // iron platform
						{
							if (CollidesWithPlatform(blob,TrueVelocity))
							{
								CurrentPos = hitpos;
								breakLoop = true;

								if (isClient())
								{
									Sound::Play(ObjectHitSound, hitpos, 1.5f);
								}
								if (isServer())
								{
									hoomanShooter.server_Hit(blob, CurrentPos, Vec2f(0, 0), Damage, AmmoType); 
								}
							}
						}
						break;

						default:
						{
							//print(blob.getName() + '\n'+blob.getName().getHash()); useful for debugging new tiles to hit

							//todo: change what bullet hits since it can be odd at times
							if (blob.hasTag("flesh") || blob.isCollidable() || blob.hasTag("vehicle"))
							{
								if (blob.getTeamNum() == TeamNum || blob.hasTag("weapon")) { continue; }
								CurrentPos = hitpos;
								if (!blob.hasTag("invincible") && !blob.hasTag("seated")) 
								{
									if (isServer())
									{
										CPlayer@ p = hoomanShooter.getPlayer();
										int coins = 0;
										hoomanShooter.server_Hit(blob, CurrentPos, Vec2f(0, 0), Damage, AmmoType); 

										if (blob.hasTag("flesh"))
										{
											SetKnocked(blob, KB.x);
											coins = gunBlob.get_u16("coins_flesh");
										}
										else
										{
											coins = gunBlob.get_u16("coins_object");
										}

										if (p !is null)
										{
											p.server_setCoins(p.getCoins() + coins);
										}
									}
									else
									{
										Sound::Play(FleshHitSound, CurrentPos, 1.5f); 
									}

								}
								breakLoop = true;
							}
						}
					}

					if (breakLoop)//So we can break while inside the switch
					{
						endBullet = true;
						break;
					}
				}
				else
				{ 
					if (isServer())
					{
						Tile tile = map.getTile(hitpos);
						map.server_DestroyTile(hitpos, Damage);     
					}

					if (isClient())
					{
						Sound::Play(ObjectHitSound, hitpos, 1.5f);
					}

					CurrentPos = hitpos;
					endBullet = true;
					//ParticleFromBullet("Bullet.png",CurrentPos,-TrueVelocity.Angle());
					ParticleBullet(CurrentPos, TrueVelocity);
				}
			}
		}

		if (endBullet == true)
		{
			TimeLeft = 1;
		}
		return false;
	}

	void JoinQueue() // Every bullet gets forced to join the queue in onRenders, so we use this to calc to position
	{   
		// Are we on the screen?
		const Vec2f xLast = PDriver.getScreenPosFromWorldPos(LastPos);
		const Vec2f xNew  = PDriver.getScreenPosFromWorldPos(CurrentPos);
		if(!(xNew.x > 0 && xNew.x < ScreenX)) // Is our main position still on screen?
		{
			if(!(xLast.x > 0 && xLast.x < ScreenX)) // Was our last position on screen?
			{
				return; // No, lets not stay here then
			}
		}

		// Lerp
		Vec2f newPos = Vec2f_lerp(LastPos, CurrentPos, FRAME_TIME);
		LastPos = newPos;

		f32 angle = Vec2f(CurrentPos.x-newPos.x, CurrentPos.y-newPos.y).getAngleDegrees();//Sets the angle

		Vec2f TopLeft  = Vec2f(newPos.x -0.7, newPos.y-3);
		Vec2f TopRight = Vec2f(newPos.x -0.7, newPos.y+3);
		Vec2f BotLeft  = Vec2f(newPos.x +0.7, newPos.y-3);
		Vec2f BotRight = Vec2f(newPos.x +0.7, newPos.y+3);

		angle = -((angle % 360) + 90);

		BotLeft.RotateBy( angle,newPos);
		BotRight.RotateBy(angle,newPos);
		TopLeft.RotateBy( angle,newPos);
		TopRight.RotateBy(angle,newPos);   

		/*if(FacingLeft)
		{
			Fade.JoinQueue(TopLeft,TopRight);
		}
		else
		{
			//Fade.JoinQueue(newPos,BotRight);
		}*/

		v_r_bullet.push_back(Vertex(TopLeft.x,  TopLeft.y,      0, 0, 0,   trueWhite)); // top left
		v_r_bullet.push_back(Vertex(TopRight.x, TopRight.y,     0, 1, 0,   trueWhite)); // top right
		v_r_bullet.push_back(Vertex(BotRight.x, BotRight.y,     0, 1, 1, trueWhite));   // bot right
		v_r_bullet.push_back(Vertex(BotLeft.x,  BotLeft.y,      0, 0, 1, trueWhite));   // bot left
	}

}


class BulletHolder
{
	BulletObj[] bullets;
	BulletFade[] fade;
	PrettyParticle@[] PParticles;
	Recoil@ localRecoil;
	BulletHolder(){}

	void FakeOnTick(CRules@ this)
	{
		CMap@ map = getMap();
		for (int a = 0; a < bullets.length(); a++)
		{
			BulletObj@ bullet = bullets[a];
			if (bullet.onFakeTick(map))
			{
				bullets.erase(a);
				a--;
			}
		}
		//print(bullets.length() + '');

		for (int a = 0; a < PParticles.length(); a++)
		{
			if (PParticles[a].ttl == 0)
			{
				PParticles.erase(a);
				a--;
				continue;
			}
			PParticles[a].FakeTick();
		}

		if (localRecoil !is null)
		{
			if (localRecoil.TimeToNormal < 1)
			{
				@localRecoil = null;
			}
			else
			{
				localRecoil.onFakeTick();
			}
		}

		/*for(int a = 0; a < recoil.length(); a++)    
		{
			Recoil@ coil = recoil[a];
			if(coil.TimeToNormal < 1)
			{
				recoil.removeAt(a);
				continue;
			}
			else
			{
				coil.onFakeTick();
			}
		}*/

	}

	BulletFade addFade(Vec2f spawnPos)
	{   
		BulletFade@ fadeToAdd = BulletFade(spawnPos);
		fade.push_back(fadeToAdd);
		return fadeToAdd; 
	}

	void addNewParticle(CParticle@ p,const u8 type)
	{
		PParticles.push_back(PrettyParticle(p,type));
	}

	void FillArray()
	{
		for (int a = 0; a < bullets.length(); a++)
		{
			bullets[a].JoinQueue();
		}

		/*for(int a = 0; a < fade.length(); a++)
		{
			if(fade[a].TimeLeft < 1)
			{
				fade.removeAt(a);
				continue;
			}
			//fade[a].JoinQueue();
		}*/
	}

	void NewRecoil(Recoil@ this)
	{
		@localRecoil = this;
	}

	void AddNewObj(BulletObj@ this)
	{
		CMap@ map = getMap();
		this.onFakeTick(map);
		bullets.push_back(this);
	}
	
	void Clean()
	{
		bullets.clear();
	}

	int ArrayCount()
	{
		return bullets.length();
	}
}

const bool CollidesWithPlatform(CBlob@ blob, const Vec2f velocity) // Stolen from rock.as
{
	const f32 platform_angle = blob.getAngleDegrees();	
	Vec2f direction = Vec2f(0.0f, -1.0f);
	direction.RotateBy(platform_angle);
	const float velocity_angle = direction.AngleWith(velocity);

	return !(velocity_angle > -90.0f && velocity_angle < 90.0f);
}
