#include "RunnerCommon.as"

void onInit(CMovement@ this)
{
	RunnerMoveVars@ moveVars;
	if (this.getBlob().get("moveVars", @moveVars))
	{
		moveVars.wallrun_length = 20;
		moveVars.wallclimbing = true;
		moveVars.wallsliding = false;
	}
	this.getBlob().set("moveVars", moveVars);
}
