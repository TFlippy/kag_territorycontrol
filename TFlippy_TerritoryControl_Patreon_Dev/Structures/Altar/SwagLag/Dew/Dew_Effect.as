#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";
#include "RgbStuff.as";

const f32 max_time = 3.00f;
const f32 base_radius = 32.00f;

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
	
	f32 true_level = this.get_f32("dew_effect");		
	f32 level = 1.00f + true_level;
	
	this.set_f32("voice pitch", (this.getSexNum() == 0 ? 0.9f : 1.5f) + true_level);
	
	// print("" + true_level);
	
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 1.00f + (true_level * 0.50f);
		moveVars.jumpFactor *= 1.00f + (true_level * 1.85f);
	}
	
	if (true_level <= 0)
	{
		if (this.isMyPlayer())
		{
			SetScreenFlash(255, 255, 255, 255, 1);
			getMap().CreateSkyGradient("skygradient.png");
			
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSound("");
			sprite.SetEmitSoundVolume(1.00f);
			sprite.SetEmitSoundSpeed(1.00f);
			sprite.SetEmitSoundPaused(true);
					
			// Sound::Play("MLG_Airhorn.ogg");
		}
		
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		if (this.isMyPlayer())
		{
			f32 camX = Maths::Sin(getGameTime()) * 0.01f * (level);
			f32 camY = Maths::Cos(getGameTime()) * 0.01f * (level);
			f32 camZ = Maths::Sin(getGameTime() * 0.125f) * 2 * (level);

			f32 time = getGameTime(); // * true_level * 10.00f;
			f32 angle = (time * 0.50f) % 180;
			// print("" + angle);

			f32 value = (1.00f + Maths::Sin(angle)) * 0.50f;
			
			SColor col = HSVToRGB(83, 1.00f, 0.70f + (value * 0.30f));
			SetScreenFlash(Maths::Min(25 + (25 * true_level), 150), col.getRed(), col.getGreen(), col.getBlue(), 1);
			
			ShakeScreen(50.0f * true_level, 5, this.getPosition());
			
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSoundVolume(Maths::Min(true_level * 3.00f, 1.00f));
			sprite.SetEmitSoundSpeed(Maths::Min(true_level * 3.00f, 1.00f));
		}
		
	
		CPlayer@ player = this.getPlayer();
		if (player !is null && player.isMyPlayer())
		{
			// Shitcode ahead
			CControls@ controls = getControls();
			Driver@ driver = getDriver();
			
			Vec2f wpos = controls.getMouseWorldPos();
			const u8 team = this.getTeamNum();
			
			f32 radius = base_radius * true_level;
			f32 dist = radius;
			u16 closest_id = 0;
			
			CBlob@[] blobs;
			if (this.getMap().getBlobsInRadius(wpos, radius, @blobs))
			{
				for (int i = 0; i < blobs.length; i++)
				{
					CBlob@ b = blobs[i];
					f32 d = (b.getPosition() - wpos).getLength();
					
					if (d < dist && b.getTeamNum() != team && b.isCollidable() && (b.hasTag("flesh") || b.hasTag("npc") || b.hasTag("vehicle") || b.hasTag("explosive") || b.hasTag("projectile")) && !b.hasTag("invincible") && !b.hasTag("dead"))
					{
						closest_id = b.getNetworkID();
						dist = d;
					}
				}
					
				if (closest_id > 0)
				{
					CBlob@ blob = getBlobByNetworkID(closest_id);
					if (blob !is null)
					{
						Vec2f bpos = blob.getPosition();
						Vec2f dir = (bpos - this.getPosition());
						f32 factor = dist / radius;
						
						Vec2f spos = driver.getScreenPosFromWorldPos(bpos);
						Vec2f sdir = (controls.getMouseScreenPos() - spos);
						
						controls.setMousePosition(controls.getMouseScreenPos() - (sdir * 1.00f));
					}
				}
			}
			this.set_u16("mlg_target", closest_id);
		}
	
		// print("" + modifier);
		// print("" + level / max_time);
		this.set_f32("dew_effect", Maths::Max(0, this.get_f32("dew_effect") - (0.001f)));
	}
	
	// print("" + true_level);
	// print("" + (1.00f / (level)));
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (this !is null && this is getLocalPlayerBlob())
	{
		Sound::Play("MLG_Hit");
		
		CParticle@ particle = ParticleAnimated("HitMarker", worldPoint, Vec2f((100 - XORRandom(200)) * 0.03f, -4), 0, 0.50f, 60, 0.40f, false);
		if (particle !is null)
		{
			particle.growth = -0.01f;
		}
	}
}