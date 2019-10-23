// A script by TFlippy & Pirate-Rob

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "BuilderHittable.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 45;
	
	this.set_bool("isActive", false);
	this.addCommandID("sv_toggle");
	this.addCommandID("cl_toggle");
}

void onInit(CSprite@ this)
{
	this.SetEmitSound("siren_leveled.ogg");
	this.SetEmitSoundVolume(2.0f);
	this.SetEmitSoundSpeed(1.0f);
	
	this.SetEmitSoundPaused(!this.getBlob().get_bool("isActive"));
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		CBlob@[] blobs;
		getBlobsByTag("aerial", @blobs);
		
		Vec2f pos = this.getPosition();
		
		for (int i = 0; i < blobs.length; i++)
		{
			if ((blobs[i].getPosition() - pos).LengthSquared() < (1000.0f * 1000.0f) && blobs[i].getTeamNum() != this.getTeamNum())
			{
				if (this.get_bool("isActive")) return;
			
				this.set_bool("isActive", true);
			
				CBitStream stream;
				stream.write_bool(true);
				this.SendCommand(this.getCommandID("cl_toggle"), stream);
	
				return;
			}
		}
		
		if (!this.get_bool("isActive")) return;
		
		this.set_bool("isActive", false);
	
		CBitStream stream;
		stream.write_bool(false);
		this.SendCommand(this.getCommandID("cl_toggle"), stream);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("sv_toggle"))
		{
			bool active = params.read_bool();
			
			this.set_bool("isActive", active);

			CBitStream stream;
			stream.write_bool(active);
			this.SendCommand(this.getCommandID("cl_toggle"), stream);
		}
	}
	
	if (isClient())
	{
		if (cmd == this.getCommandID("cl_toggle"))
		{		
			bool active = params.read_bool();
		
			this.set_bool("isActive", active);
		
			CSprite@ sprite = this.getSprite();
		
			sprite.PlaySound("LeverToggle.ogg");
			sprite.SetEmitSoundPaused(!active);
			sprite.SetAnimation(active ? "on" : "off");
		}
	}
}

// void GetButtonsFor(CBlob@ this, CBlob@ caller)
// {
	// if (!this.isOverlapping(caller)) return;
	
	// CBitStream params;
	// params.write_bool(!this.get_bool("isActive"));
	
	// CButton@ buttonEject = caller.CreateGenericButton(11, Vec2f(0, -8), this, this.getCommandID("sv_toggle"), (this.get_bool("isActive") ? "Turn Off" : "Turn On"), params);
// }