#include "Hitters.as";

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
	const f32 mod = f32(this.get_u8("mustard value") / 64.0f);
	const f32 mod_inv = 1.00f - mod;

	
	
	// print("mod: " + mod);
	
	if (ticks % u32(5 + 200 * mod_inv) == 0) 
	{
		// print("mod: " + mod);
	
		if (getNet().isServer()) this.server_Hit(this, this.getPosition(), Vec2f(0, 0), Maths::Min(ticks, 300) * 0.00125f * mod, Hitters::burn);
		if (getNet().isClient()) 
		{
			this.getSprite().PlaySound("/cough" + XORRandom(5) + ".ogg", 0.6f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			if (this.isMyPlayer()) ShakeScreen(60 * mod_inv, 5, this.getPosition());
		}
	}
	
	// if (getNet().isClient())
	// {
		// if (ticks % (150 * Maths::Clamp((150 + 100 * mod_inv) - ticks, 0.5f, 1.0f)) == 0) this.getSprite().PlaySound("/cough" + XORRandom(5) + ".ogg", 0.6f, 1.0f);
	// }
	// GUI::DrawRectangle(Vec2f(50, 50), Vec2f(100, 100), SColor(128, 128, 128, 128));
	
	// if (this.isMyPlayer())
    // {
        // SetScreenFlash(10, 25, 0, Maths::Clamp(ticks / 15, 0, 255));
		// print("" + Maths::Clamp(ticks / 15, 0, 255));
    // }
	
	// print("" + ticks);
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
	if (!blob.isMyPlayer()) return;
	
	const int ticks = getGameTime() - blob.get_u32("mustard time");
	const f32 mod = f32(blob.get_u8("mustard value") / 35.0f);
	
	Driver@ driver = getDriver();
	Vec2f screenSize(driver.getScreenWidth(), driver.getScreenHeight());
	
	GUI::DrawRectangle(Vec2f(0, 0), screenSize, SColor(Maths::Clamp((ticks * mod) / 3, 0, 255), 10, 8, 0));
}