#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

const f32 increment = 1.00f / (30.00f * 30.00f);

void onInit(CBlob@ this)
{

}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) 
	{
		return;
	}
		
	const f32 value = this.get_f32("fusk_effect");
	const u32 time = getGameTime();
		
	const bool server = isServer();
	const bool client = isClient();

	if (value > 1.00f)
	{
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 0.90f / Maths::Min(1.00f + (value * 0.01f), 1.50f);
			moveVars.jumpFactor *= 0.90f;
		}	
	
		if (client)
		{
			if (time % 5 == 0)
			{
				if (XORRandom(100) < 40)
				{
					f32 mod = XORRandom(100) * 0.01f * value;
					Vec2f pos = this.getPosition() + getRandomVelocity(0, XORRandom(800) * 0.01f, 360);
					
					CParticle@ p = ParticleBlood(pos, Vec2f(0, 0), SColor(255, 100, 200, 255));
					if (p !is null)
					{
						p.timeout = 10 + XORRandom(30);
						p.scale = 0.75f + mod;
						p.fastcollision = true;
						// p.stretches = true;
					}
				}
			}
			
			if (this.isMyPlayer())
			{
				CControls@ controls = getControls();
				Driver@ driver = getDriver();
				controls.setMousePosition(controls.getMouseScreenPos() + getRandomVelocity(0, (100 - XORRandom(200)) * Maths::Min(value, 40.00f) * 0.001f, 360));				
			}
		}
	}
	
	if (value > 2.00f)
	{
		if (time % u32(100 + XORRandom(200)) == 0) 
		{
			SetKnocked(this, 5 + Maths::Min(XORRandom(5) * (value * 0.02f), 50));
		
			this.setKeyPressed(key_action1, true);
			this.setKeyPressed(key_action2, true);
		
			if (server) 
			{
				this.server_Hit(this, this.getPosition(), Vec2f(0, 0), 0.03f + Maths::Min(value * 0.002f, 0.08f), HittersTC::disease);
			}
			
			if (client) 
			{
				this.getSprite().PlaySound("/cough" + XORRandom(5) + ".ogg", 0.7f, this.getSexNum() == 0 ? 1.0f : 2.0f);
				
				f32 mod = XORRandom(100) * 0.01f * value;
				Vec2f pos = this.getPosition();
				int count = Maths::Clamp(time * 0.50f, 3, 20);
				
				for (int i = 0; i < count; i++)
				{
					Vec2f vel = getRandomVelocity(0, XORRandom(400) * 0.01f, 360);
				
					CParticle@ p = ParticleBlood(pos + vel, vel * -1.0f, SColor(255, 126, 0, 0));
					if (p !is null)
					{
						p.timeout = 10 + XORRandom(60);
						p.scale = 0.75f + mod;
						p.fastcollision = true;
						// p.stretches = true;
					}
				}
				
				if (this.isMyPlayer())
				{
					SetScreenFlash(Maths::Clamp((25 + XORRandom(100)) * value, 0, 200), 0, 0, 0, 3);
				}
			}
			
			bool left = this.isFacingLeft();
			
			HitInfo@[] hitInfos;
			if(getMap().getHitInfosFromArc(this.getPosition() + Vec2f(2 * (left ? -1 : 1), -2), left ? 180 : 0, 60, 40, this, true, @hitInfos))
			{
				for (int i = 0; i < hitInfos.length; i++) 
				{
					HitInfo@ hit_info = hitInfos[i];
					CBlob@ blob = hit_info.blob;
					
					if (blob !is null)
					{
						Infect(this, blob, 0.30f);
					}
				}
			}
		}
	}
	
	if (value > 3.00f)
	{
		if (server)
		{
			if (XORRandom(100) < 2 && this.getHealth() > 0.25f)
			{
				this.server_Hit(this, this.getPosition(), Vec2f(0, 0), this.getHealth() * Maths::Min(value * 0.1f, 0.90f), HittersTC::disease);
				// print("ow");
			}
		}
	}

	this.set_f32("fusk_effect", value + increment);
}

void Infect(CBlob@ this, CBlob@ blob, f32 amount)
{
	if (this !is null && blob !is null)
	{
		if (blob.hasTag("flesh") && !blob.hasTag("gas immune") && !blob.hasTag("vaccinated"))
		{
			if (!blob.hasScript("Fusk_Effect.as")) blob.AddScript("Fusk_Effect.as");
			blob.add_f32("fusk_effect", amount);
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attached !is null && attached !is this)
	{
		Infect(this, attached, 0.05f);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && blob !is this)
	{
		Infect(this, blob, 0.01f);
	}
}