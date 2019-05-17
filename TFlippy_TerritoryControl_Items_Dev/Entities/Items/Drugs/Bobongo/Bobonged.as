#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

void onInit(CBlob@ this)
{

}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	f32 true_level = this.get_f32("bobonged");		
	f32 level = 1.00f + true_level;
	
	if (true_level <= 0)
	{
		this.Untag("custom_camera");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		f32 time = f32(getGameTime() * level);

		this.Tag("custom_camera");
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 0.75f;;
			moveVars.jumpFactor *= 0.90f;
		}	
		
		if (this.isMyPlayer())
		{
			// CCamera@ cam = getCamera();
			// cam.targetDistance = 3.00f + ((1 + Maths::Sin(getGameTime() * 0.015f * level)) * 0.50f) * (level * level * 0.125f);
			
			if (getGameTime() % 5 == 0) SetScreenFlash(50, 50, 25, 0);
		}
					
		this.setKeyPressed(key_action2, true);
		this.set_f32("bobonged", Maths::Max(0, this.get_f32("bobonged") - (0.0002f)));
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 true_level = this.get_f32("bobonged");		
	f32 level = 1.00f + true_level;

	if (level > 1)
	{
		return damage / level;
	}
	
	return damage;
}