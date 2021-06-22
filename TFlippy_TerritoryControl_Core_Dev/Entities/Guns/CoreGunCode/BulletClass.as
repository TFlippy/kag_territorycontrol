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
#include "BulletParticle.as";
#include "BulletModule.as";
#include "Bullet.as";
#include "Recoil.as";
#include "GunCommon.as";
#include "DeityCommon.as";
#include "Knocked.as";

const SColor trueWhite = SColor(255,255,255,255);

Driver@ PDriver = getDriver();
const int ScreenX = PDriver.getScreenWidth();
const int ScreenY = PDriver.getScreenWidth();

namespace BulletRender
{
	void Reset()
	{
		//v_r_bullet.clear();
		//v_r_fade.clear();
	}

	void Draw()
	{
		BulletGrouped.QueueBullets();
		CRules@ rules = getRules();

		string[]@ vertex_book;
		rules.get("VertexBook", @vertex_book);

		for (int a = 0; a < vertex_book.length(); a++)
		{
			Vertex[]@ bulletVertex;
			string texture = vertex_book[a];
			rules.get(texture, @bulletVertex);

			// Sending empty vertex just eats performance because engine does not check :)
			if (bulletVertex.length() < 1) continue;

			Render::RawQuads(texture, bulletVertex);

			bulletVertex.clear();
		}
	}
}


class BulletHolder
{
	Bullet[] bullets;
	BulletHolder(){}
	Recoil@ localRecoil;

	void onTick(CRules@ this)
	{
		CMap@ map = getMap();
		for (int a = 0; a < bullets.length(); a++)
		{
			Bullet@ bullet = bullets[a];

			if (bullet.onTick(map))
			{
				bullets.erase(a);
				a--;
			}
		}

		if (localRecoil !is null)
		{
			if (localRecoil.TimeToNormal < 1)
			{
				@localRecoil = null;
			}
			else
			{
				localRecoil.onTick();
			}
		}
	}

	void NewRecoil(Recoil@ this)
	{
		@localRecoil = this;
	}

	void QueueBullets()
	{
		CRules@ rules = getRules();
		for (int a = 0; a < bullets.length(); a++)
		{
			Bullet@ bullet = bullets[a];
			bullet.onRender();
		}
	}

	Bullet@ CreateNewBullet(CBlob@ humanBlob, CBlob@ gun, f32 angle, Vec2f pos)
	{
		BulletModule@[] module = {};
		return CreateNewBullet(humanBlob, gun, angle, pos, module);
	}

	Bullet@ CreateNewBullet(CBlob@ humanBlob, CBlob@ gun, f32 angle, Vec2f pos, BulletModule@[] modules)
	{
		Bullet@ bullet = Bullet(humanBlob, gun, angle, pos, modules);
		bullet.onTick(getMap());
		bullets.push_back(bullet);
		return bullet;
	}

	// Don't use this unless you super have to, use CreateNewBullet instead
	void AddNewBullet(Bullet@ bullet)
	{
		bullet.onTick(getMap());
		bullets.push_back(bullet);
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
