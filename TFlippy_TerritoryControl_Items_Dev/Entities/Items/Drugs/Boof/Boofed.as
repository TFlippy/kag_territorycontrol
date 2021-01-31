#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";
#include "EmotesCommon.as"

void onInit(CBlob@ this)
{
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient_boof.png");
}

void onDie(CBlob@ this)
{
	if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	f32 true_level = this.get_f32("boofed");		
	f32 level = 1.00f + true_level;
	
	if (true_level <= 0)
	{
		this.Untag("custom_camera");
		if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		f32 time = f32(getGameTime() * level);
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 0.60f - (true_level * 0.10f);
			moveVars.jumpFactor *= 0.70f;
		}	
		
		if (isClient())
		{
			if (this.isMyPlayer())
			{
				// CCamera@ cam = getCamera();
				// cam.targetDistance = 3.00f + ((1 + Maths::Sin(getGameTime() * 0.015f * level)) * 0.50f) * (level * level * 0.125f);
			
				ShakeScreen2(5.0f, 5.0f, this.getPosition());
				if (getGameTime() % 5 == 0) SetScreenFlash(50, 10, 60, 50);
				
				if (XORRandom(300) == 0)
				{
					this.getSprite().PlaySound("/cough" + XORRandom(5) + ".ogg", 0.6f, this.getSexNum() == 0 ? 1.0f : 2.0f);
					if (this.isMyPlayer()) ShakeScreen(400, 5, this.getPosition());
				}
				
				if (XORRandom(400) == 0)
				{		
					u8 emote = 0;
							
					if (true_level < 0.20f) emote = Emotes::laughcry;
					else if (true_level < 0.50f) emote = Emotes::awkward;
					else if (true_level < 0.80f) emote = Emotes::laugh;
					else emote = Emotes::laugh;
						
					set_emote(this, emote);
				}
			}
		}
		
		this.set_f32("boofed", Maths::Max(0, this.get_f32("boofed") - (0.0002f)));
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 true_level = this.get_f32("boofed");		
	f32 level = 1.00f + true_level;

	if (level > 1)
	{
		return damage / level;
	}
	
	return damage;
}
