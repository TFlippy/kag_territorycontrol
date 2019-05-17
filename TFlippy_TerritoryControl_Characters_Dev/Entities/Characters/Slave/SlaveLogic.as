#include "RunnerCommon.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("remote_storage");

	this.Tag("player");
	this.Tag("flesh");
	this.Tag("neutral");
	this.Tag("human");
	
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));
	this.set_f32("mining_multiplier", 3.0f);
	
	if (getNet().isServer())
	{
		this.server_setTeamNum(150);
		
		CBlob@ ball = server_CreateBlobNoInit("slaveball");
		ball.setPosition(this.getPosition());
		ball.server_setTeamNum(-1);
		ball.set_u16("slave_id", this.getNetworkID());
		ball.Init();
	}
}

// void onTick(CBlob@ this)
// {
	// RunnerMoveVars@ moveVars;
	
	// if (!this.get("moveVars", @moveVars))
	// {
		// return;
	// }
	
	// CBlob@ carried = this.getCarriedBlob();
	
	// if (carried !is null && carried.getConfig() == "slaveball")
	// {
		// moveVars.jumpFactor *= 0.5f;
		// moveVars.walkFactor *= 0.5f;
	// }
// }

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob !is this;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	//print("" + customData);

	CPlayer@ player=this.getPlayer();

	if (this.hasTag("invincible") || (player !is null && player.freeze))
	{
		return 0;
	}
	
	switch(customData)
	{
		case Hitters::nothing:
		case Hitters::suicide:
		case Hitters::fall:
			damage = 0;
			break;
	}

	return damage;
}

// bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
// {
	// return byBlob.getConfig() != "slave";
// }