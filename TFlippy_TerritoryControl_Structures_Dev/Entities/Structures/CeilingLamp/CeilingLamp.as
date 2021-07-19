#include "MapFlags.as"
#include "MinableMatsCommon.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().mapCollisions = true;
    this.getSprite().getConsts().accurateLighting = true;  
	this.getShape().SetStatic(true);
	// this.getSprite().SetZ(800); //background

	this.Tag("builder always hit");

	this.SetLight(true);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 255, 240, 210));
	
	this.set_bool("security_state", true);

	HarvestBlobMat[] mats = {};
	mats.push_back(HarvestBlobMat(1.0f, "mat_copperwire"));
	this.set("minableMats", mats);	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("security_set_state"))
	{
		bool state = params.read_bool();
		
		CSprite@ sprite = this.getSprite();
		this.SetLight(state);
		sprite.PlaySound(state ? "Security_TurnOn" : "Security_TurnOff", 0.30f, 1.00f);
		this.set_bool("security_state", state);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return false;
}