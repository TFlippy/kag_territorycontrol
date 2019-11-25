#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";

const f32 max_time = 3.00f;
const f32 base_radius = 32.00f;

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	f32 true_level = this.get_f32("sosek_effect");		
	f32 level = 1.00f + true_level;
		
	this.set_f32("voice pitch", (this.getSexNum() == 0 ? 0.9f : 1.5f));
	if (true_level <= 0)
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{		
		f32 drunk_level = this.get_f32("drunk_effect");
		
		const bool isknocked = isKnocked(this);
		if (this.isKeyPressed(key_down) && this.isKeyPressed(key_action1) && !(getKnocked(this) > 0 || this.get_f32("babbyed") > 0.00f) && drunk_level > 0.50f)
		{
			if (this.isKeyJustPressed(key_action1))
			{
				CSprite@ sprite = this.getSprite();
				sprite.SetEmitSound("FlamethrowerFire");
				sprite.SetEmitSoundVolume(1.00f);
				sprite.SetEmitSoundSpeed(2.00f);
				sprite.SetEmitSoundPaused(false);
				
				this.getSprite().PlaySound("TraderScream.ogg", 2.00f, this.get_f32("voice pitch"));
			}
		
			if (getGameTime() >= this.get_u32("nextSosekBurp"))
			{
				Vec2f vel = this.getAimPos() - this.getPosition();
				vel.Normalize();
				vel *= 4.00f + Maths::Min(Maths::Pow(drunk_level, 0.80f), 10);
				
				if (isServer())
				{
					CBlob@ fireball = server_CreateBlobNoInit("sosekflame");
					fireball.setPosition(this.getPosition());
					fireball.setVelocity(this.getVelocity() + vel);
					fireball.server_setTeamNum(this.getTeamNum());
					fireball.Init();
					fireball.server_SetTimeToDie(0.50f + Maths::Min((Maths::Pow(drunk_level, 0.80f) * 0.10f), 2.00f));
				}

				this.set_f32("drunk_effect", Maths::Max(drunk_level * 0.80f, 0));
				
				this.setVelocity(this.getVelocity() - (vel * 0.40f));
				this.set_u32("nextSosekBurp", getGameTime() + 4);
			}
		}
		else
		{
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSoundPaused(true);
		}
		
		
		this.set_f32("sosek_effect", Maths::Max(0, this.get_f32("sosek_effect") - (0.00001f)));
	}
}