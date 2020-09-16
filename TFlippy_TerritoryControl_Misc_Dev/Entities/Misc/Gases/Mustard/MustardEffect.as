#include "Hitters.as";
#include "RunnerCommon.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 1;
	
	if (this.hasTag("mustarded")) this.getCurrentScript().runFlags |= Script::remove_after_this;
	this.Tag("mustarded");
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) this.getCurrentScript().runFlags |= Script::remove_after_this;

	if (this.get_u8("mustard value") < 5) return;
	
	const int ticks = getGameTime() - this.get_u32("mustard time");
	const f32 mod = f32(this.get_u8("mustard value") / 50.0f);
	const f32 mod_inv = 1.00f - mod;

	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 0.80f;
		moveVars.jumpFactor *= 0.85f;
	}	
	
	if (ticks % u32(5 + 200 * mod_inv) == 0) 
	{
		if (isServer()) 
		{
			this.server_Hit(this, this.getPosition(), Vec2f(0, 0), Maths::Min(ticks, 300) * 0.00125f * mod, Hitters::burn);
		}
		
		if (isClient()) 
		{
			this.getSprite().PlaySound("/cough" + XORRandom(5) + ".ogg", 0.6f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			if (this.isMyPlayer()) ShakeScreen(60 * mod_inv, 5, this.getPosition());
		}
	}
}

void onDie(CBlob@ this)
{
	this.RemoveScript("MustardEffect.as");
}

void onDie(CSprite@ this)
{
	this.RemoveScript("MustardEffect.as");
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	const int ticks = getGameTime() - blob.get_u32("mustard time");
	const f32 mod = f32(blob.get_u8("mustard value") / 35.0f);
	
	Driver@ driver = getDriver();
	Vec2f screenSize(driver.getScreenWidth(), driver.getScreenHeight());
	GUI::DrawRectangle(Vec2f(0, 0), screenSize, SColor(Maths::Clamp((ticks * mod) / 3, 0, 255), 10, 8, 0));
}