#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

void onInit(CBlob@ this)
{
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient_stim.png");
}

void onDie(CBlob@ this)
{
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	f32 true_level = this.get_f32("stimed");		
	f32 level = 1.00f + true_level;
	
	if (true_level <= 0)
	{
		if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		f32 time = f32(getGameTime() * level);
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 1.5f + Maths::Min((true_level * 0.25f), 1.5f);
			moveVars.jumpFactor *= 1.4f;
		}

		if (this.isMyPlayer())
		{
			ShakeScreen(5, 5, this.getPosition());
		}
					
		if (XORRandom(200 / true_level) == 0)
		{
			this.setKeyPressed(key_action1, true);
		}
					
		this.set_f32("stimed", Maths::Max(0, this.get_f32("stimed") - (0.001f)));
	}
	
	// print("" + true_level);
	// print("" + (1.00f / (level)));
}

//f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
//{
	//f32 true_level = this.get_f32("stimed");		
	//f32 level = 1.00f + true_level;

	//if (level > 1)
	//{
		//return damage / Maths::Min(level, 2);
	//}
	
	//return damage;
//}