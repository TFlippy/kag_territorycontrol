#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "EmotesCommon.as"

const int crak_duration = 30 * 60 * 1.30f;
const f32 crak_step = 1.00f / crak_duration;

void onInit(CBlob@ this)
{
	// Driver@ driver = getDriver();
	// driver.RemoveShader("hq2x");
	// driver.AddShader("palette", 1001.0f);
	
	CSprite@ sprite = this.getSprite();
	string config = this.getConfig();
	
	Animation@ animation_run = sprite.getAnimation("run");
	if (animation_run !is null) animation_run.time = 2;
	
	Animation@ animation_strike = sprite.getAnimation("strike");
	if (animation_strike !is null) animation_strike.time = 1;
	
	Animation@ animation_build = sprite.getAnimation("build");
	if (animation_build !is null) animation_build.time = 1;
	
	this.set_u8("charge_increment", 5);
	this.set_u32("build delay", 1);
	this.set_f32("voice pitch", 1.60f);
	this.set_u8("override head", 106);
	
	this.getSprite().PlaySound("Huuu.ogg", 1.0f, 0.8f);
	
	this.SendCommand(this.getCommandID("reload_head"));
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
		
	f32 true_level = this.get_f32("crak_effect");		
	f32 level = 1.00f + true_level;
	f32 withdrawal = 1.00f - Maths::Min(true_level, 1);
	
	if (true_level <= 0.00f)
	{
		if (isServer() && !this.hasTag("transformed"))
		{
			if (this.hasTag("human") && this.getConfig() != "hobo")
			{
				CBlob@ blob = server_CreateBlob("hobo", this.getTeamNum(), this.getPosition());
				if (this.getPlayer() !is null) blob.server_SetPlayer(this.getPlayer());
			}
			else if (this.hasTag("chicken"))
			{
				CBlob@ blob = server_CreateBlob("chicken", this.getTeamNum(), this.getPosition());
				if (this.getPlayer() !is null) blob.server_SetPlayer(this.getPlayer());
			}
			else if (this.getConfig() == "kitten")
			{
				CBlob@ blob = server_CreateBlob("badger", this.getTeamNum(), this.getPosition());
				if (this.getPlayer() !is null) blob.server_SetPlayer(this.getPlayer());
			}
			
			this.Tag("transformed");
			this.server_Die();
		}
	
		if (isClient() && this.isMyPlayer()) getMap().CreateSkyGradient("skygradient.png");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 1.50f - (withdrawal * 1.00f);
			moveVars.jumpFactor *= 1.50f - (withdrawal * 1.00f);
			
			if (true_level > 3.00f)
			{
				moveVars.walkFactor = 1.25f;
				moveVars.jumpFactor = 0.00f;
			}
		}	
		
		if (true_level > 3.00f)
		{
			if (this.getTickSinceCreated() % (30 + XORRandom(60)) == 0)
			{
				SetKnocked(this, 20);

				if (isServer())
				{
					this.server_Hit(this, this.getPosition(), Vec2f(0, 0), 0.25f, Hitters::flying, true);
				}
				
				if (isClient())
				{
					this.getSprite().PlaySound("TraderScream.ogg", 0.8f, this.get_f32("voice pitch") + (XORRandom(50) * 0.01f));
					
					if (this.isMyPlayer())
					{
						this.getSprite().PlaySound("Thunder2", 1.50f, 1.00f + (XORRandom(100) * 0.01f));
					
						SetScreenFlash(255, 255, 255, 255, 0.25f);
					}
				}
			}
			
			Vec2f vel = this.getVelocity();
			if (Maths::Abs(vel.x) > 0.1)
			{
				f32 angle = this.get_f32("angle");
				angle += vel.x * this.getRadius();
				if (angle > 360.0f) angle -= 360.0f;
				else if (angle < -360.0f) angle += 360.0f;
				
				this.set_f32("angle", angle);
				this.setAngleDegrees(angle);
			}
		}
		else
		{
			if (isClient())
			{
				if (this.isMyPlayer())
				{
					if (XORRandom(500 * true_level) == 0)
					{
						if (true_level < 0.50f)
						{
							SetScreenFlash(255 * withdrawal, 0, 0, 0, 0.40f);
						}
					
						u8 emote = 0;
						
						if (true_level < 0.20f) emote = Emotes::attn;
						else if (true_level < 0.50f) emote = Emotes::disappoint;
						else if (true_level < 0.80f) emote = Emotes::wat;
						else emote = Emotes::troll;
						
						set_emote(this, emote);
					}
				}
			}
		}
		
		this.add_f32("crak_effect", -crak_step);
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob is null || this is null) return;
	CPlayer@ p = this.getPlayer();
	
	if (p is null || p.getUsername() != "Turtlecake") return;
	if (this.hasTag("dead")) return;

	if (blob.getName() == "mat_mithrilenriched" && blob.getQuantity() > 5)
	{
		if (isServer() && !this.hasTag("transformed"))
		{
			CBlob@ blob = server_CreateBlob("boowb", this.getTeamNum(), this.getPosition());
			if (this.getPlayer() !is null) blob.server_SetPlayer(this.getPlayer());
			
			this.Tag("transformed");
			this.server_Die();
		}
		else
		{
			ParticleZombieLightning(this.getPosition());

			Sound::Play("thunder_distant" + XORRandom(4));
			SetScreenFlash(100, 255, 255, 255);
		}
	}
}