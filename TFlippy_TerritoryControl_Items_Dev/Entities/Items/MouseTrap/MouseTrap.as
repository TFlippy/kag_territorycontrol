#include "Hitters.as";
#include "HittersTC.as";
#include "Knocked.as"

void onInit(CBlob@ this)
{
	this.set_bool("armed", false);
	this.Tag("ignore fall");
	
	this.addCommandID("mousetrap_arm");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("mousetrap_arm"))
	{
		bool state = params.read_bool();
		this.set_bool("armed", state);
		
		this.getSprite().SetFrameIndex(state ? 0 : 1);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() == this.getTeamNum())
	{
		if (this.getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
		
		bool armed = this.get_bool("armed");
		
		CBitStream params;
		params.write_bool(!armed);
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("mousetrap_arm"), (armed ? "Disarm" : "Arm"), params);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{

}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && this.get_bool("armed") && blob.hasTag("flesh"))
	{
		SetKnocked(blob, 255);
		this.getSprite().PlaySound("MouseTrap_Snap.ogg");
		this.set_bool("armed", false);
		this.getSprite().SetFrameIndex(1);
		
		if (isServer())
		{
			this.server_Hit(blob, this.getPosition(), Vec2f(0, 0), 1.0f, Hitters::builder, true);
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return damage;
}

void onThisAddToInventory(CBlob@ this, CBlob@ carrier)
{

}
