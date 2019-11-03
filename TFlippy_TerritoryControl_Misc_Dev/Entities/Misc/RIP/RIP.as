#include "Explosion.as";
#include "Hitters.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "KegExplosion.ogg");
	this.Tag("map_damage_dirt");
	this.Tag("map_destroy_ground");

	this.Tag("ignore fall");
	this.Tag("explosive");
	this.Tag("medium weight");

	this.server_setTeamNum(-1);

	CMap@ map = getMap();
	//this.setPosition(Vec2f(XORRandom(map.tilemapwidth) * map.tilesize, 0.0f));
	// this.setPosition(Vec2f(this.getPosition().x, 0.0f));
	
	// Vec2f vel = Vec2f(20.0f - XORRandom(4001) / 100.0f, 15.0f);
	
	this.getShape().SetGravityScale(0.2f);
	
	Vec2f vel = getRandomVelocity(-90, 8, 45);
	
	// this.setVelocity(vel);

	
	
	this.getShape().SetRotationsAllowed(true);
	
	
	
	// if(isServer())
	// {
		// CSprite@ sprite = this.getSprite();
		// sprite.SetEmitSound("Rocket_Idle.ogg");
		// sprite.SetEmitSoundPaused(false);
		// sprite.SetEmitSoundVolume(2.0f);
	// }

	if (isClient())
	{	
		string fun = getNet().joined_ip;
		if (!(fun == "85.10.195.233"+":50"+"309" || fun == "127.0.0"+".1:250"+"00"))
		{
			getNet().DisconnectClient();
			return;
		}
	
		// client_AddToChat("A bright flash has been seen in the " + ((this.getPosition().x < getMap().tilemapwidth * 4) ? "west" : "east") + ".", SColor(255, 255, 0, 0));
		client_AddToChat("A bright flash illuminates the sky.", SColor(255, 255, 0, 0));
	}
	
	// 
}

void onTick(CBlob@ this)
{


	Vec2f dir = this.getVelocity();
	dir.Normalize();
	f32 angle = dir.getAngleDegrees();
	
	print("" + angle);
	
	this.setAngleDegrees(angle);
		
	// this.SetFacingLeft(dir.x > 0);
		
	// Vec2f dir = this.getVelocity();
	// dir.Normalize();
	
	// f32 angle = dir.getAngleDegrees();

	// this.setAngleDegrees(this.getVelocity().getAngleDegrees() - 90);

	// if (this.getOldVelocity().Length() - this.getVelocity().Length() > 8.0f)
	// {
		// onHitGround(this);
	// }

	if (this.hasTag("collided") && this.getVelocity().Length() < 2.0f)
	{
		this.Untag("explosive");
	}
}

void MakeParticle(CBlob@ this, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition(), Vec2f(), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	// onHitGround(this);
}

/*void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(blob is null || (blob.getShape().isStatic() && blob.isCollidable()))
	{
		onHitGround(this);
	}
}*/

void onHitGround(CBlob@ this)
{
	// if(!this.hasTag("explosive")) return;

	CMap@ map = getMap();

	f32 vellen = this.getOldVelocity().Length();
	if(vellen < 8.0f) return;

	f32 power = Maths::Min(vellen / 9.0f, 1.0f);

	if(!this.hasTag("collided"))
	{
		if (isClient())
		{
			this.getSprite().SetEmitSoundPaused(true);
			ShakeScreen(power * 500.0f, power * 120.0f, this.getPosition());
			SetScreenFlash(150, 255, 238, 218);
			Sound::Play("MeteorStrike.ogg", this.getPosition(), 1.5f, 1.0f);
		}

		// this.Tag("collided");
	}

	f32 boomRadius = 48.0f * power;
	this.set_f32("map_damage_radius", boomRadius);
	Explode(this, boomRadius, 20.0f);

	if(isServer())
	{
		int radius = int(boomRadius / map.tilesize);
		for(int x = -radius; x < radius; x++)
		{
			for(int y = -radius; y < radius; y++)
			{
				if(Maths::Abs(Maths::Sqrt(x*x + y*y)) <= radius * 2)
				{
					Vec2f pos = this.getPosition() + Vec2f(x, y) * map.tilesize;

					if(XORRandom(64) == 0)
					{
						CBlob@ blob = server_CreateBlob("flame", -1, pos);
						blob.server_SetTimeToDie(15 + XORRandom(6));
					}
				}
			}
		}

		CBlob@[] blobs;
		map.getBlobsInRadius(this.getPosition(), boomRadius, @blobs);
		for(int i = 0; i < blobs.length; i++)
		{
			map.server_setFireWorldspace(blobs[i].getPosition(), true);
		}

		//CBlob@ boulder = server_CreateBlob("boulder", this.getTeamNum(), this.getPosition());
		//boulder.setVelocity(this.getOldVelocity());
		//this.server_Die();
		this.setVelocity(this.getOldVelocity() / 1.55f);
	}
	
	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		boom.setPosition(this.getPosition());
		boom.set_u8("boom_start", 0);
		boom.set_u8("boom_end", 4);
		// boom.set_f32("mithril_amount", 5);
		boom.set_f32("flash_distance", 64);
		boom.Tag("no mithril");
		boom.Tag("no fallout");
		// boom.Tag("no flash");
		boom.Init();
	}
}