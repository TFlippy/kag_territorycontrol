#include "CombatChickenCommon.as"
#include "Hitters.as";
#include "RunnerCommon.as";
#include "Knocked.as";

const f32 cursor_lerp_speed = 0.50f;

void onInit(CBrain@ this)
{
	InitBrain( this );
	this.server_SetActive( true ); // always running
	//this.plannerMaxSteps = 100;
	//this.plannerMaxSteps = 100;

	this.lowLevelSteps = 1000;
	this.lowLevelMaxSteps = 1000;

	
	CBlob@ blob = this.getBlob();
}

void onTick(CBrain@ this)
{
	CBlob@ blob = this.getBlob();

	if (getKnocked(blob) > 0 || blob.getPlayer() !is null) return;
	
	const u8 strat = blob.get_u8("stratergy");

	switch(strat)
	{
		case Strategy::idle:
			StratIdle(this, blob);
		break;

		case Strategy::searching:
			StratSearching(this, blob);
		break;

		case Strategy::relocating:
			StratRelocating(this, blob);
		break;

		case Strategy::attack:
			StratAttack(this, blob);
		break;

		case Strategy::hold_off:
			StratHoldOff(this, blob);
		break;

		case Strategy::last_stand:
			StratLastStand(this, blob);
		break;

		case Strategy::retreat:
			StratRetreat(this, blob);
		break;

		case Strategy::victory:
			StratVictory(this, blob);
		break;
	}
}

// !scoutchicken
// TODO:
// Convert ZombieSearchNdoe position2di to Vec2f
// Air time
// Cleanup

void StratIdle(CBrain@ this, CBlob@ blob)
{
	if (!(blob.getScreenPos().x > 0 && blob.getScreenPos().x < 1920))
	{	
		return;
	}

	this.getCurrentScript().tickFrequency = 1;
	//print(getLocalPlayerBlob().getPosition().x + " | " + this.getVars().lastPathPos2.x);
	//print(this.getHighPathSize() + " | " + this.getPathSize());
	//print(this.getState() + '');

	//print(this.getPathPosition().x + ' | ' );
	print(this.getState() + ' | ' + this.getPathPositionAtIndex(this.getPathSize()) + ' | ' + this.getPathSize());
	if (getGameTime() % 150 == 0 && (this.getState() != CBrain::has_path || blob.getPosition().Length() < 20 && this.getPathPositionAtIndex(this.getPathSize()).Length() < 20) )
	{
		print("new path set!");
		//this.SetPathTo(getLocalPlayerBlob().getPosition(), 4);
		this.SetLowLevelPath(blob.getPosition(), getLocalPlayerBlob().getPosition());
	}

	SuggestedKeys(this, blob);
	//this.SetSuggestedKeys();
	//SuggestedKeys(this, blob);
	//Move(blob, blob.getPosition() + Vec2f(-10, -20));
	//blob.setAimPos(blob.getPosition() + Vec2f(-10, -20));
}

void StratSearching(CBrain@ this, CBlob@ blob)
{

}

void StratRelocating(CBrain@ this, CBlob@ blob)
{

}

void StratAttack(CBrain@ this, CBlob@ blob)
{

}

void StratHoldOff(CBrain@ this, CBlob@ blob)
{

}

void StratLastStand(CBrain@ this, CBlob@ blob)
{

}

void StratRetreat(CBrain@ this, CBlob@ blob)
{

}

void StratVictory(CBrain@ this, CBlob@ blob)
{

}