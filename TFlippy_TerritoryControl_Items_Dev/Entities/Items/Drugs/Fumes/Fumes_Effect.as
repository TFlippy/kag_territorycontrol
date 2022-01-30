#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";
#include "RgbStuff.as";

const f32 max_time = 3.00f;
const f32 base_radius = 32.00f;

void onInit(CBlob@ this)
{

	CSpriteLayer@ wings = this.getSprite().addSpriteLayer("fumes_wings", "Fumes_Wings.png", 32, 32);
	if (wings !is null)
	{
		Animation@ anim = wings.addAnimation("flap", 2, false);
		anim.AddFrame(2);
		anim.AddFrame(2);
		anim.AddFrame(1);
		anim.AddFrame(0);
	
		wings.SetOffset(Vec2f(0, -4));
		wings.SetRelativeZ(-10);
	}
}

void onDie(CBlob@ this)
{
	if (isClient() && this.isMyPlayer())
	{	
		getMap().CreateSkyGradient("skygradient.png");
	}
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	f32 true_level = this.get_f32("fumes_effect");		
	f32 level = 1.00f + true_level;
	
	// this.set_f32("voice pitch", (this.getSexNum() == 0 ? 0.9f : 1.5f) + true_level);
	
	// print("" + true_level);
	
	// RunnerMoveVars@ moveVars;
	// if (this.get("moveVars", @moveVars))
	// {
		// moveVars.walkFactor *= 1.00f + (true_level * 0.50f);
		// moveVars.jumpFactor *= 1.00f + (true_level * 1.85f);
	// }
	
	if (true_level <= 0)
	{
		if (this.isMyPlayer())
		{
			SetScreenFlash(255, 0, 0, 0, 1);
		}
		
		CSpriteLayer@ wings = this.getSprite().getSpriteLayer("fumes_wings");
		if (wings !is null)
		{
			wings.SetVisible(false);
		}
		
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		if (isClient())
		{
			CSpriteLayer@ wings = this.getSprite().getSpriteLayer("fumes_wings");
			if (wings !is null)
			{
				wings.SetVisible(true);
			}
			
			ParticleAnimated("SmallSmoke", this.getPosition() + Vec2f(+8 + XORRandom(4), 8 - XORRandom(16)), this.getVelocity() * 0.10f, 0, 1.00f, 3 + XORRandom(2), 0, false);
			ParticleAnimated("SmallSmoke", this.getPosition() + Vec2f(-8 - XORRandom(4), 8 - XORRandom(16)), this.getVelocity() * 0.10f, 0, 1.00f, 3 + XORRandom(2), 0, false);
		}
	
		const bool isknocked = isKnocked(this);
		if (getGameTime() >= this.get_u32("nextFumesJump"))
		{
			if (this.isKeyJustPressed(key_action3) && !isknocked)
			{
				Vec2f vel = this.getAimPos() - this.getPosition();
				vel.Normalize();
				vel.x *= 2.00f;
				vel.y = -6.00f;
			
				this.setVelocity((this.getVelocity() * 0.25f) + vel);

				this.getSprite().PlaySound("Fumes_Fly.ogg");
				this.set_u32("nextFumesJump", getGameTime() + 10);
				
				CSpriteLayer@ wings = this.getSprite().getSpriteLayer("fumes_wings");
				if (wings !is null)
				{
					wings.SetAnimation("flap");
					
					Animation@ animation = wings.getAnimation("flap");
					if (animation !is null)
					{
						animation.SetFrameIndex(0);
					}
				}
			}
		}
			
		// if (this.isMyPlayer())
		// {
			// // f32 camX = Maths::Sin(getGameTime()) * 0.01f * (level);
			// // f32 camY = Maths::Cos(getGameTime()) * 0.01f * (level);
			// // f32 camZ = Maths::Sin(getGameTime() * 0.125f) * 2 * (level);

			// // f32 time = getGameTime(); // * true_level * 10.00f;
			// // f32 angle = (time * 0.50f) % 180;
			// // // print("" + angle);

			// // f32 value = (1.00f + Maths::Sin(angle)) * 0.50f;
			
			// // SColor col = HSVToRGB(83, 1.00f, 0.70f + (value * 0.30f));
			// // SetScreenFlash(Maths::Min(25 + (25 * true_level), 150), col.getRed(), col.getGreen(), col.getBlue(), 1);
			
			// // ShakeScreen(50.0f * true_level, 5, this.getPosition());
			
			// // CSprite@ sprite = this.getSprite();
			// // sprite.SetEmitSoundVolume(Maths::Min(true_level * 3.00f, 1.00f));
			// // sprite.SetEmitSoundSpeed(Maths::Min(true_level * 3.00f, 1.00f));
		// }
		
		// print("" + modifier);
		// print("" + level / max_time);
		this.set_f32("fumes_effect", Maths::Max(0, this.get_f32("fumes_effect") - (0.001f)));
	}
	
	// print("" + true_level);
	// print("" + (1.00f / (level)));
}