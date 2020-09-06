#include "Explosion.as";
#include "Hitters.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	this.getShape().SetStatic(true);
	
	if (isClient())
	{
		client_AddToChat("You hear several distant explosions.", SColor(255, 255, 0, 0));
	}
	
	
	this.set_u8("shots fired", 0);
	this.set_u8("shots spawned", 0);
	
	if (!this.exists("max shots fired")) this.set_u8("max shots fired", 10);
	if (!this.exists("delay between shells")) this.set_u32("delay between shells", 15);
	if (!this.exists("shell blob")) this.set_string("shell blob", "chickencannonshell");
	
	this.set_u32("next shot", getGameTime() + 150);
	this.set_u32("next spawn", getGameTime() + 150);
}

void onTick(CBlob@ this)
{
	const u8 shotsFired = this.get_u8("shots fired");
	const u8 maxShotsFired = this.get_u8("max shots fired");
	const u32 delay = this.get_u32("delay between shells");
	
	if (isClient() && getGameTime() >= this.get_u32("next shot") && shotsFired < maxShotsFired)
	{
		CCamera@ cam = getCamera();
		if (cam !is null)
		{
			Sound::Play("Bombardment_Far" + XORRandom(4) + ".ogg", cam.getPosition(), 1.00f, 0.80f);
			ShakeScreen(20, 30, this.getPosition());
			this.set_u32("next shot", (getGameTime() + 20 + XORRandom(delay)));
		
			this.set_u8("shots fired", shotsFired + 1);
		}
	}
	
	if (isServer())
	{
		const u32 ticks = this.getTickSinceCreated();
		const u8 shotsSpawned = this.get_u8("shots spawned");
		
		if (ticks >= 150 + 300 && getGameTime() >= this.get_u32("next spawn"))
		{
			f32 angle = 30 + XORRandom(30);
		
			// CBlob@ b = server_CreateBlob("tankshell", 250, Vec2f(this.getPosition().x + 150 - XORRandom(300), 0));
			CBlob@ b = server_CreateBlobNoInit(this.get_string("shell blob"));
			b.server_setTeamNum(250);
			b.setPosition(Vec2f(this.getPosition().x + 100 - XORRandom(200) + 250, 0));
			b.setVelocity(Vec2f(0, 1).RotateBy(angle) * 20.00f);
			b.setAngleDegrees(angle);
			b.Init();
			
			this.set_u8("shots spawned", shotsSpawned + 1);
			this.set_u32("next spawn", (getGameTime() + 20 + XORRandom(delay)));
		}
		
		if (shotsSpawned >= maxShotsFired)
		{
			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
}