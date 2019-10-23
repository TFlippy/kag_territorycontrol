#include "Knocked.as";
#include "RunnerCommon.as";

const u32 incubation_time = 30 * 60 * 1;

void onInit(CBlob@ this)
{
	this.getSprite().PlaySound("MigrantScream1.ogg", 1.00f, this.getSexNum() == 0 ? 1.0f : 2.0f);
	this.set_u32("pigger_init", getGameTime());
	
	this.Tag("dangerous");
	
	print("piggered");
}

void onTick(CBlob@ this)
{
	if (this.get_u16("drunk") > 2)
	{
		print("depiggered");
	
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		
		if (isClient() && this.isMyPlayer())
		{
			CCamera@ cam = getCamera();
			cam.setRotation(0);
		}
	}
	
	f32 timeLeft = Maths::Max(f32(this.get_u32("pigger_init")) + incubation_time - (this.get_u16("pigger_bite_counter") * 30) - getGameTime(), 0);
	
	f32 mod = Maths::Clamp(f32(timeLeft) / f32(30 * 60 * 1), 0, 1);
	f32 invmod = 1.00f - Maths::Clamp(f32(timeLeft) / f32(incubation_time), 0, 1);
	
	// print("" + mod);
	
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= mod;
		moveVars.jumpFactor *= mod;
	}
	
	if (getGameTime() > this.get_u32("next pigger scream"))
	{
		this.set_u32("next pigger scream", getGameTime() + 300 + XORRandom(600));
		this.getSprite().PlaySound(XORRandom(100) < 50 ? "MigrantScream1.ogg" : "man_scream", 1.00f, this.getSexNum() == 0 ? 0.25f : 1.25f + (0.75f * mod));
		// print("scream");
	}
	
	if (mod < 0.15f)
	{
		SetKnocked(this, 30);
	}
	
	if (isClient())
	{
		if (this.isMyPlayer())
		{
			SetScreenFlash(255 * invmod, 0, 0, 0);
		
			f32 rot;
			rot += Maths::Sin(getGameTime() / 50.0f) * invmod * 4.0f;
			rot += Maths::Cos(getGameTime() / 25.0f) * invmod * 2.3f;
			rot += Maths::Sin(380 + getGameTime() / 40.0f) * invmod * 1.5f;
			
			CCamera@ cam = getCamera();
			cam.setRotation(rot);
			// cam.setPosition(cam.getPosition() + Vec2f(rot * 0.10f, -rot * 0.10f));
		}
	}
	
	if (mod == 0 && !this.hasTag("transformed"))
	{
		this.Tag("transformed");
	
		this.getSprite().PlaySound("Pigger_Gore", 0.50f, 1.00f);
		this.getSprite().Gib();
	
		if (isServer())
		{
			CPlayer@ ply = this.getPlayer();
			this.server_Die();
			
			int eggs = Maths::Min(Maths::Ceil(this.get_u16("pigger_bite_counter") / 30), 10);
			
			for (int i = 0; i < eggs; i++)
			{
				CBlob@ pigger = server_CreateBlob("pigger", this.getTeamNum(), this.getPosition());
				pigger.setVelocity(getRandomVelocity(90, 5, 90));
			}
			
			CBlob@ man = server_CreateBlob("mithrilguy", this.getTeamNum(), this.getPosition());
			if (ply !is null) man.server_SetPlayer(ply);
		}
	}
	
	// if (this.hasTag("dead")) return;
	// u16 level = this.get_u16("drunk");
		
	// if (this.get_u32("next sober") < getGameTime() && XORRandom(1000) == 0)
	// {
		// this.set_u16("drunk", Maths::Max(this.get_u16("drunk") - 1, 0));
	// }
	
	// if (level > 0 && getKnocked(this) < 10 && XORRandom(4000 / (1 + level * 1.5f)) == 0)
	// {
		// u8 knock = 5 + XORRandom(20) * level;
	
		// SetKnocked(this, knock);
		// this.getSprite().PlaySound("drunk_fx" + XORRandom(5), 0.8f, this.getSexNum() == 0 ? 1.0f : 2.0f);
	// }
	
	// if (isClient())
	// {
		// if (this.isMyPlayer())
		// {
			// f32 rot;
			// rot += Maths::Sin(getGameTime() / 30.0f) * level * 1.8f;
			// rot += Maths::Cos(getGameTime() / 25.0f) * level * 1.3f;
			// rot += Maths::Sin(380 + getGameTime() / 40.0f) * level * 2.5f;
			
			// CCamera@ cam = getCamera();
			// cam.setRotation(rot);
		// }
	// }
	
	// if (level == 0)
	// {
		// print("sober");
	
		// this.getCurrentScript().runFlags |= Script::remove_after_this;
		
		// if (isClient() && this.isMyPlayer())
		// {
			// CCamera@ cam = getCamera();
			// cam.setRotation(0);
		// }
	// }
}

void onDie(CBlob@ this)
{
	if (isClient() && this.isMyPlayer())
	{
		CCamera@ cam = getCamera();
		cam.setRotation(0);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 modifier = Maths::Max(0.3f, Maths::Min(1, Maths::Pow(0.80f, this.get_u16("drunk"))));
	// print("" + modifier);
	return damage * modifier;
}