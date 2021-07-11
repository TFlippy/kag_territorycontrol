// A script by TFlippy & Pirate-Rob

#include "MinableMatsCommon.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.set_bool("isActive", true);
	
	this.addCommandID("sv_toggle");
	this.addCommandID("cl_toggle");
	
	SetState(this, this.get_bool("isActive"));

	HarvestBlobMat[] mats = {};
	mats.push_back(HarvestBlobMat(15.0f, "mat_stone")); 
	mats.push_back(HarvestBlobMat(20.0f, "mat_wood")); 
	mats.push_back(HarvestBlobMat(1.0f, "mat_copperwire")); //Get the full wire back
	this.set("minableMats", mats);	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("sv_toggle"))
		{
			this.set_bool("isActive", !this.get_bool("isActive"));
			bool isActive = this.get_bool("isActive");

			CBitStream stream;
			stream.write_bool(isActive);
			this.SendCommand(this.getCommandID("cl_toggle"), stream);
		}
	}
	
	if (isClient())
	{
		if (cmd == this.getCommandID("cl_toggle"))
		{		
			this.getSprite().PlaySound("LeverToggle.ogg");
			SetState(this, params.read_bool());
		}
	}
}

void SetState(CBlob@ this, bool inState)
{
	this.SetLight(inState);
	this.SetLightRadius(120.0f);
	this.SetLightColor(SColor(255, 255, 200, 110));

	CSprite@ sprite = this.getSprite();
	sprite.SetAnimation(inState ? "on" : "off");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
	
	CBitStream params;
	CButton@ buttonEject = caller.CreateGenericButton((this.get_bool("isActive") ? 27 : 23), Vec2f(-0.5f, -4), this, this.getCommandID("sv_toggle"), (this.get_bool("isActive") ? "Turn Off" : "Turn On"), params);
}