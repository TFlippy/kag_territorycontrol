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
			moveVars.walkFactor *= 2.00f + Maths::Min((true_level * 0.25f), 2);
			moveVars.jumpFactor *= 1.85f;
		}	
		
		if (this.isMyPlayer())
		{
			ShakeScreen(Maths::Min(true_level * 3, 20), 5, this.getPosition());
			SetScreenFlash(Maths::Min(XORRandom(255) * true_level * 0.10f, 25), XORRandom(255), XORRandom(255), XORRandom(255));
		}
					
		if (XORRandom(200 / true_level) == 0)
		{
			this.setKeyPressed(key_action1, true);
		}
					
		this.set_f32("stimed", Maths::Max(0, this.get_f32("stimed") - (0.0005f)));
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