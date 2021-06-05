#include "Explosion.as";
#include "Hitters.as";
#include "MakeMat.as";
#include "MakeSeed.as";
#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

// Meteor by Koi_

f32 sound_delay = 0;
f32 sound_time = 0;

void onInit(CBlob@ this)
{
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 7, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);

	this.getSprite().SetZ(-25); //background

	this.set_Vec2f("shop offset", Vec2f(-6, 0));
	this.set_Vec2f("shop menu size", Vec2f(5, 4));
	this.set_string("shop description", "Mysterious Object's Molecular Fabricator");
	this.set_u8("shop icon", 15);

	this.set_f32("map_damage_ratio", 1.0f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "KegExplosion.ogg");
	this.Tag("map_damage_dirt");
	this.Tag("map_destroy_ground");

	this.Tag("ignore fall");
	this.Tag("explosive");
	this.Tag("high weight");
	this.Tag("drone inside");
	this.Tag("gas inside");

	this.server_setTeamNum(-1);

	if (isServer())
	{
		if (XORRandom(100) < 75)
		{
			CBlob@ blob = server_CreateBlob("forceray", this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(blob);
		}

		if (XORRandom(100) < 50)
		{
			CBlob@ blob = server_CreateBlob("forceray", this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(blob);
		}

		if (XORRandom(100) < 75)
		{
			for (int i = 0; i < 1 + XORRandom(6); i++)
			{
				CBlob@ blob = server_CreateBlob("bobomax", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);
			}
		}

		if (XORRandom(100) < 10)
		{
			CBlob@ blob = server_CreateBlob("oof", this.getTeamNum(), this.getPosition());
			MakeMat(this, this.getPosition(), "mat_antimatter", 10 + XORRandom(40));
			this.server_PutInInventory(blob);
		}

		if (XORRandom(100) < 25)
		{
			CBlob@ blob = server_CreateBlob("chargelance", this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(blob);

			MakeMat(this, this.getPosition(), "mat_lancerod", 50 + XORRandom(50));
		}

		// if (XORRandom(100) < 75)
		{
			CBlob@ blob = server_CreateBlob("mat_mithrilbomb", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(2 + XORRandom(5));

			this.server_PutInInventory(blob);
		}

		// MakeMat(this, this.getPosition(), "mat_lancerod", 50 + XORRandom(50));
		MakeMat(this, this.getPosition(), "mat_matter", 150 + XORRandom(400));
		MakeMat(this, this.getPosition(), "mat_plasteel", 25 + XORRandom(200));
		MakeMat(this, this.getPosition(), "mat_mithril", 250 + XORRandom(750));
		MakeMat(this, this.getPosition(), "mat_mithrilingot", 16 + XORRandom(32));
		MakeMat(this, this.getPosition(), "mat_antimatter", XORRandom(10));
	}

	this.inventoryButtonPos = Vec2f(6, 0);

	CMap@ map = getMap();
	this.setPosition(Vec2f(this.getPosition().x, 0.0f));
	this.setVelocity(Vec2f((15 + XORRandom(5)) * (XORRandom(2) == 0 ? 1.00f : -1.00f), 5));
	// this.getShape().SetGravityScale(0.0f);

	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSoundVolume(0.5f);
		sprite.SetEmitSound("Ayy_Loop.ogg");
		sprite.SetEmitSoundPaused(false);
		sprite.RewindEmitSound();

		sprite.ResetTransform();
		sprite.RotateBy(-this.getVelocity().Angle(), Vec2f());

		Sound::Play("AncientShip_Intro.ogg");

		// client_AddToChat("A strange object has fallen out of the sky in the " + ((this.getPosition().x < getMap().tilemapwidth * 4) ? "west" : "east") + "!", SColor(255, 255, 0, 0));
		client_AddToChat("A mysterious object has landed nearby!", SColor(255, 255, 0, 0));
	}

	this.set_u8("poison counter", 1);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", (caller.getPosition() - this.getPosition()).Length() < 64.0f);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	// return !this.hasTag("collided");
	return !blob.hasTag("player");
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("drone inside"))
	{
		if (isServer()) 
		{
			for (int i = 0; i < 4 + XORRandom(4); i++)
			{
				server_CreateBlob("drone", -1, this.getPosition() + getRandomVelocity(0, XORRandom(24), 360));
			}
		}

		Sound::Play("PoisonShip_Siren.ogg");
		ShakeScreen(80.0f, 32.00f, this.getPosition());

		this.Untag("drone inside");
	}
}

/*void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	// print("" + cmd + " = " + this.getCommandID("shop made item"));

	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		u16 caller, item;

		if (!params.saferead_netid(caller) || !params.saferead_netid(item)) return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		if (callerBlob is null) return;

		if (isServer())
		{
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if(spl[0] == "scyther")
			{
				server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				CBlob@ mat = server_CreateBlob(spl[0]);

				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (blob is null && callerBlob is null) return;

				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
}*/

void MakeParticle(CBlob@ this, const string filename = "SmallSteam")
{
	ParticleAnimated(filename, this.getPosition(), Vec2f(), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onTick(CBlob@ this)
{
	if (this.getOldVelocity().Length() - this.getVelocity().Length() > 8.0f)
	{
		onHitGround(this);
	}

	if (this.hasTag("collided") && this.getVelocity().Length() < 2.0f)
	{
		this.Untag("explosive");
	}

	if (isClient() && this.getTickSinceCreated() < 60) MakeParticle(this, XORRandom(100) < 10 ? "LargeSmoke.png" : "Explosion.png");

	if (this.hasTag("collided"))
	{
		this.getShape().SetGravityScale(1.0f);
		if (!this.hasTag("sound_played") && getGameTime() > (sound_delay * getTicksASecond()))
		{
			this.Tag("sound_played");

			f32 modifier = 1.00f - (sound_delay / 3.0f);

			if (modifier > 0.01f && isClient())
			{
				Sound::Play("Nuke_Kaboom.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), 1.0f - (0.7f * (1 - modifier)), modifier);
			}
		}

		this.getCurrentScript().tickFrequency = 1;

		u32 time = this.getTickSinceCreated();
		u8 poison_counter = this.get_u8("poison counter");
		u32 next_time = 20 * 60 * poison_counter;

		// print("counter: " + poison_counter + "; next time: " + next_time);

		if (poison_counter <= 20 && time % next_time == 0)
		{
			CMap@ map = this.getMap();

			this.set_u8("poison counter", poison_counter + 1);

			for (int i = 0; i < 2; i++)
			{
				f32 x = this.getPosition().x + (poison_counter * 92 * (i == 0 ? -1 : 1));
				// Vec2f pos;

				// map.rayCastSolid(Vec2f(x, 0), Vec2f(x, map.tilemapheight * 8), pos);

				f32 y  = map.getLandYAtX(x / 8) * 8;

				CBlob@ blob = server_CreateBlob("falloutgas", -1, Vec2f(x, y));
			}

			if (poison_counter == 10)
			{
				CBlob@ blob = server_CreateBlob("info_dead", -1, Vec2f(this.getPosition().x, 0));
			}

			// print("" + y); 
		}
	}
}

void onHitGround(CBlob@ this)
{
	if(!this.hasTag("explosive")) return;

	CMap@ map = getMap();

	f32 vellen = this.getOldVelocity().Length();
	if(vellen < 8.0f) return;

	f32 power = Maths::Min(vellen * 50.0f, 1.0f);

	if(!this.hasTag("collided"))
	{
		if (isClient())
		{
			ShakeScreen(power * 400.0f, power * 100.0f, this.getPosition());
			SetScreenFlash(100, 255, 255, 255);

			Vec2f pos = getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos());
			sound_delay = (Maths::Abs(this.getPosition().x - pos.x) / 8) / (340 * 0.4f);
			sound_time = getGameTime() + sound_delay * 30;
		}

		this.Tag("collided");
	}

	f32 boomRadius = 48.0f * power;
	this.set_f32("map_damage_radius", boomRadius);
	Explode(this, boomRadius, 20.0f);

	if (isServer() && this.hasTag("gas inside"))
	{
		CBlob@ gas = server_CreateBlob("falloutgas", -1, this.getPosition());
		this.Untag("gas inside");

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

		this.setVelocity(this.getOldVelocity() / 1.55f);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// if (customData != Hitters::builder && customData != Hitters::drill) return 0.0f;

	if (isServer())
	{
		if (XORRandom(2) == 0) MakeMat(hitterBlob, worldPoint, "mat_steelingot", (XORRandom(2)));
		if (XORRandom(2) == 0) MakeMat(hitterBlob, worldPoint, "mat_ironingot", (XORRandom(3)));
		if (XORRandom(2) == 0) MakeMat(hitterBlob, worldPoint, "mat_plasteel", (XORRandom(10)));

		if (XORRandom(100) < 70)
		{
			CBlob@ blob = server_CreateBlob("mat_matter", -1, this.getPosition());
			blob.server_SetQuantity(5);
			blob.setVelocity(Vec2f(100 - XORRandom(200), 100 - XORRandom(200)) / 25.0f);
		}
	}

	return damage;
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		boom.setPosition(this.getPosition());
		boom.set_u8("boom_start", 0);
		boom.set_u8("boom_end", 15);
		boom.set_f32("mithril_amount", 175);
		boom.set_f32("flash_distance", 1024);
		// boom.Tag("no mithril");
		// boom.Tag("no flash");
		// boom.Tag("no fallout");
		boom.Init();
	}
}
