#include "BrainCommon.as"
#include "Hitters.as";
#include "RunnerCommon.as";
#include "BirdCommon.as";
#include "MiscCommon.as";

void onInit(CBrain@ this)
{
	if (isServer())
	{
		InitBrain( this );
		this.server_SetActive(true); // always running
	}
}

void Move(CBrain@ this, CBlob@ blob, Vec2f pos)
{
	Vec2f dir = blob.getPosition() - pos;
	dir.Normalize();

	blob.setKeyPressed(key_left, dir.x > 0);
	blob.setKeyPressed(key_right, dir.x < 0);
	blob.setKeyPressed(key_up, dir.y > 0);
	blob.setKeyPressed(key_down, dir.y < 0);
}