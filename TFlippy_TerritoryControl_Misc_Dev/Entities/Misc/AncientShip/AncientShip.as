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
	this.set_string("shop description", "Mysterious Wreckage's Molecular Fabricator");
	this.set_u8("shop icon", 15);

	this.set_f32("map_damage_ratio", 1.0f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "KegExplosion.ogg");
	this.Tag("map_damage_dirt");
	this.Tag("map_destroy_ground");

	this.Tag("ignore fall");
	this.Tag("explosive");
	this.Tag("high weight");
	this.Tag("scyther inside");

	this.set_bool("shop available", false);

	this.server_setTeamNum(-1);

	if (isServer())
	{
		for (int i = 0; i < 5; i++)
		{
			if (XORRandom(100) < 35)
			{
				CBlob@ blob = server_CreateBlob("chargerifle", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);
			}
		}

		for (int i = 0; i < 6; i++)
		{
			if (XORRandom(100) < 50)
			{
				CBlob@ blob = server_CreateBlob("chargepistol", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);
			}
		}

		for (int i = 0; i < 2; i++)
		{
			if (XORRandom(100) < 25)
			{
				CBlob@ blob = server_CreateBlob("callahan", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);
			}
		}

		for (int i = 0; i < 2; i++)
		{
			if (XORRandom(100) < 10)
			{
				CBlob@ blob = server_CreateBlob("chargelance", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);

				MakeMat(this, this.getPosition(), "mat_lancerod", 50 + XORRandom(50));
			}
		}

		for (int i = 0; i < 2; i++)
		{
			if (XORRandom(100) < 50)
			{
				CBlob@ blob = server_CreateBlob("chargeblaster", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);

				MakeMat(this, this.getPosition(), "mat_mithril", 50 + XORRandom(150));
			}
		}

		for (int i = 0; i < 5; i++)
		{
			if (XORRandom(100) < 35)
			{
				CBlob@ blob = server_CreateBlob("exosuititem", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);
			}
		}

		if (XORRandom(100) < 2)
		{
			CBlob@ blob = server_CreateBlob("oof", this.getTeamNum(), this.getPosition());
			MakeMat(this, this.getPosition(), "mat_antimatter", 10 + XORRandom(25));
			this.server_PutInInventory(blob);
		}

		if (XORRandom(100) < 25)
		{
			CBlob@ blob = server_CreateBlob("mat_mithrilbomb", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(1 + XORRandom(2));

			this.server_PutInInventory(blob);
		}

		if (XORRandom(100) < 50)
		{
			for (int i = 0; i < 1 + XORRandom(4); i++)
			{
				CBlob@ blob = server_CreateBlob("bobomax", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);
			}
		}

		MakeMat(this, this.getPosition(), "mat_lancerod", 50 + XORRandom(50));
		MakeMat(this, this.getPosition(), "mat_matter", 250 + XORRandom(1000));
		MakeMat(this, this.getPosition(), "mat_plasteel", 250 + XORRandom(2000));
		MakeMat(this, this.getPosition(), "mat_antimatter", XORRandom(15));
		MakeMat(this, this.getPosition(), "mat_mithril", 50 + XORRandom(750));

		this.set_u8("wreckage_count", 0);
		this.set_u8("wreckage_count_max", 10 + XORRandom(20));

		Vec2f velocity = Vec2f((15 + XORRandom(5)) * (XORRandom(2) == 0 ? 1.00f : -1.00f), 5);
		this.setVelocity(velocity);
		this.set_Vec2f("wreckage_velocity", velocity);
	}

	this.inventoryButtonPos = Vec2f(6, 0);

	CMap@ map = getMap();
	this.setPosition(Vec2f((map.tilemapwidth * 8 * 0.50f) + (400 - XORRandom(800)), 0.0f));

	// this.getShape().SetGravityScale(0.0f);

	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSoundVolume(0.5f);
		sprite.SetEmitSound("AncientShip_Loop.ogg");
		sprite.SetEmitSoundPaused(false);
		sprite.RewindEmitSound();

		sprite.ResetTransform();
		sprite.RotateBy(-this.getVelocity().Angle(), Vec2f());

		Sound::Play("AncientShip_Intro.ogg");

		// client_AddToChat("A strange object has fallen out of the sky in the " + ((this.getPosition().x < getMap().tilemapwidth * 4) ? "west" : "east") + "!", SColor(255, 255, 0, 0));
		client_AddToChat("Various strange debris is falling out of the sky!", SColor(255, 255, 0, 0));
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", (caller.getPosition() - this.getPosition()).Length() < 64.0f);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	// return !this.hasTag("collided");
	return false;
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("scyther inside"))
	{
		if (isServer()) 
		{
			for (int i = 0; i < 1 + XORRandom(2); i++)
			{
				if (XORRandom(100) < 75)
				{
					server_CreateBlob("scyther", -1, this.getPosition());
				}
				else
				{
					server_CreateBlob("centipede", -1, this.getPosition());
				}
			}
		}
		this.Untag("scyther inside");
	}

	this.set_bool("shop available", true);
}

/*void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	// print("" + cmd + " = " + this.getCommandID("shop made item"));

	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

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
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());
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
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition(), Vec2f(), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onTick(CBlob@ this)
{
	if (isServer() && XORRandom(100) == 0)
	{
		const u8 w_count = this.get_u8("wreckage_count");
		const u8 w_count_max = this.get_u8("wreckage_count_max");
		const Vec2f velocity = this.get_Vec2f("wreckage_velocity");

		if (w_count < w_count_max)
		{
			u32 width = getMap().tilemapwidth * 0.50f * 8;
			CBlob@ blob = server_CreateBlob("ancientwreckage", -1, Vec2f(this.getPosition().x + ((width * 0.50f) - XORRandom(width)), 0));
			if (blob !is null)
			{
				Vec2f vel = velocity;
				vel.RotateBy(3 - XORRandom(6));

				blob.setVelocity(vel);

				this.add_u8("wreckage_count", 1);
			}
		}
	}

	if(this.getOldVelocity().Length() - this.getVelocity().Length() > 8.0f)
	{
		onHitGround(this);
	}

	if(this.hasTag("collided") && this.getVelocity().Length() < 2.0f)
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
			// print("modifier: " + modifier);

			if (modifier > 0.01f && isClient())
			{
				Sound::Play("Nuke_Kaboom.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), 1.0f - (0.7f * (1 - modifier)), modifier);
			}

			this.getCurrentScript().tickFrequency = 0; //disable ticks
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

		for (int i = 0; i < 3; i++)
		{
			server_CreateBlob("falloutgas", this.getTeamNum(), this.getPosition() + getRandomVelocity(0, XORRandom(80), 360));
		}

		this.setVelocity(this.getOldVelocity() / 1.55f);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData != Hitters::builder && customData != Hitters::drill)
		return 0.0f;

	if (isServer())
	{
		MakeMat(hitterBlob, worldPoint, "mat_steelingot", XORRandom(4));
		MakeMat(hitterBlob, worldPoint, "mat_ironingot", XORRandom(6));
		MakeMat(hitterBlob, worldPoint, "mat_plasteel", XORRandom(20));

		if (XORRandom(100) < 70)
		{
			CBlob@ blob = server_CreateBlob("mat_matter", -1, this.getPosition());
			blob.server_SetQuantity(5 + XORRandom(30));
			blob.setVelocity(Vec2f(100 - XORRandom(200), 100 - XORRandom(200)) / 25.0f);
		}
	}

	return damage;
}
