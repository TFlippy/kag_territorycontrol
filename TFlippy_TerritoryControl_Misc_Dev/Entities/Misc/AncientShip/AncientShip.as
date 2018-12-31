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

	this.server_setTeamNum(-1);

	if (getNet().isServer())
	{
		if (XORRandom(100) < 75)
		{
			CBlob@ blob = server_CreateBlob("chargerifle", this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(blob);
		}

		if (XORRandom(100) < 25)
		{
			CBlob@ blob = server_CreateBlob("chargerifle", this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(blob);
		}
		
		if (XORRandom(100) < 25)
		{
			CBlob@ blob = server_CreateBlob("callahan", this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(blob);
		}
		
		if (XORRandom(100) < 25)
		{
			CBlob@ blob = server_CreateBlob("callahan", this.getTeamNum(), this.getPosition());
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

		if (XORRandom(100) < 10)
		{
			CBlob@ blob = server_CreateBlob("chargelance", this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(blob);

			MakeMat(this, this.getPosition(), "mat_lancerod", 50 + XORRandom(50));
		}
		
		if (XORRandom(100) < 5)
		{
			CBlob@ blob = server_CreateBlob("exosuititem", this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(blob);
		}
		
		if (XORRandom(100) < 2)
		{
			CBlob@ blob = server_CreateBlob("oof", this.getTeamNum(), this.getPosition());
			MakeMat(this, this.getPosition(), "mat_antimatter", 10 + XORRandom(25));
			this.server_PutInInventory(blob);
		}

		if (XORRandom(100) < 25)
		{
			CBlob@ blob = server_CreateBlob("chargeblaster", this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(blob);

			MakeMat(this, this.getPosition(), "mat_mithril", 50 + XORRandom(150));
		}
		
		if (XORRandom(100) < 25)
		{
			CBlob@ blob = server_CreateBlob("mat_mithrilbomb", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(1 + XORRandom(2));
			
			this.server_PutInInventory(blob);
		}

		MakeMat(this, this.getPosition(), "mat_lancerod", 50 + XORRandom(50));
		MakeMat(this, this.getPosition(), "mat_matter", 50 + XORRandom(200));
		MakeMat(this, this.getPosition(), "mat_plasteel", 25 + XORRandom(50));
		MakeMat(this, this.getPosition(), "mat_antimatter", XORRandom(10));
	}

	this.inventoryButtonPos = Vec2f(6, 0);
	
	CMap@ map = getMap();
	this.setPosition(Vec2f(this.getPosition().x, 0.0f));
	this.setVelocity(Vec2f((15 + XORRandom(5)) * (XORRandom(2) == 0 ? 1.00f : -1.00f), 5));
	// this.getShape().SetGravityScale(0.0f);

	if (getNet().isClient())
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
		client_AddToChat("A strange object has fallen out of the sky!", SColor(255, 255, 0, 0));
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
		if (getNet().isServer()) 
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
		this.Untag("scyther inside");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
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
		
		if (getNet().isServer())
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
				print("scyther");
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
				
				if (blob is null) return;
			   
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
}

void MakeParticle(CBlob@ this, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition(), Vec2f(), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onTick(CBlob@ this)
{
	if(this.getOldVelocity().Length() - this.getVelocity().Length() > 8.0f)
	{
		onHitGround(this);
	}

	if(this.hasTag("collided") && this.getVelocity().Length() < 2.0f)
	{
		this.Untag("explosive");
	}

	if (getNet().isClient() && this.getTickSinceCreated() < 60) MakeParticle(this, XORRandom(100) < 10 ? "LargeSmoke.png" : "Explosion.png");

	if(this.hasTag("collided"))
	{
		this.getShape().SetGravityScale(1.0f);
		if (!this.hasTag("sound_played") && getGameTime() > (sound_delay * getTicksASecond()))
		{
			this.Tag("sound_played");

			f32 modifier = 1.00f - (sound_delay / 3.0f);
			print("modifier: " + modifier);

			if (modifier > 0.01f && getNet().isClient())
			{
				Sound::Play("Nuke_Kaboom.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), 1.0f - (0.7f * (1 - modifier)), modifier);
			}

			this.getCurrentScript().tickFrequency = 30;
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
		if (getNet().isClient())
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

	if(getNet().isServer())
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
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData != Hitters::builder && customData != Hitters::drill)
		return 0.0f;

	if (getNet().isServer())
	{	
		if (XORRandom(2) == 0) MakeMat(hitterBlob, worldPoint, "mat_steelingot", (XORRandom(1)));
		if (XORRandom(2) == 0) MakeMat(hitterBlob, worldPoint, "mat_ironingot", (XORRandom(2)));
		if (XORRandom(2) == 0) MakeMat(hitterBlob, worldPoint, "mat_plasteel", (XORRandom(4)));

		if (XORRandom(100) < 70)
		{
			CBlob@ blob = server_CreateBlob("mat_matter", -1, this.getPosition());
			blob.server_SetQuantity(5);
			blob.setVelocity(Vec2f(100 - XORRandom(200), 100 - XORRandom(200)) / 25.0f);
		}
	}
	
	return damage;
}
