#include "Knocked.as";

void onInit(CBlob@ this)
{
	addShader(this);
}


void addShader(CBlob@ this)
{
	if (isClient() && this.isMyPlayer())
	{
		if (!this.hasTag("drunk_shader"))
		{
			getDriver().SetShader("drunk", true);
			this.Tag("drunk_shader");
		}
	}
}


void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	f32 true_level = this.get_f32("drunk_effect");		
	f32 true_level_lerp = this.get_f32("drunk_effect_lerp");	
	f32 sosek_level = this.get_f32("sosek_effect");
	
	true_level /= Maths::Clamp(sosek_level * 4.00f, 1.00f, 20.00f);
	f32 level = 1.00f + true_level;
	
	if (true_level <= 0)
	{
		onDie(this);

		this.RemoveScript("Drunk_Effect.as");
	}
	else
	{
		if (isClient() && this.isMyPlayer())
		{
			f32 rot;
			rot += Maths::Sin(getGameTime() / 30.0f) * 1.8f;
			rot += Maths::Cos(getGameTime() / 25.0f) * 1.3f;
			rot += Maths::Sin(380 + getGameTime() / 40.0f) * 2.5f;
			
			// print("" + (rot * true_level_lerp));
			
			CCamera@ cam = getCamera();
			cam.setRotation(Maths::Clamp(rot * true_level_lerp, -360, 360));

			Driver@ driver = getDriver();
			if (driver.CanUseShaders())
			{
				addShader(this);
				
				f32 cam_x = getCamera().getPosition().x;
				driver.SetShaderFloat("drunk", "time", getGameTime() / 30.0f);
				driver.SetShaderFloat("drunk", "scroll_x", cam_x);
				driver.SetShaderFloat("drunk", "amount", true_level_lerp * 2);
			}
		}
	
		if (level > 0 && getKnocked(this) < 10 && XORRandom(4000 / (1 + level * 1.5f)) == 0)
		{
			u8 knock = 5 + XORRandom(20) * level;
		
			SetKnocked(this, knock);
			this.getSprite().PlaySound("drunk_fx" + XORRandom(5), 0.8f, this.getSexNum() == 0 ? 1.0f : 2.0f);
		}
		
		this.set_f32("drunk_effect", Maths::Max(0, this.get_f32("drunk_effect") - (0.004f)));
		this.set_f32("drunk_effect_lerp", Maths::Lerp(true_level_lerp, true_level, 0.02f));
	}
}

void onDie(CBlob@ this)
{
	if (isClient() && this.isMyPlayer())
	{
		CCamera@ cam = getCamera();
		cam.setRotation(0);

		getDriver().SetShader("drunk", false);
		this.Untag("drunk_shader");
	}

	this.set_u16("drunk", 0);

	// print("die");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 modifier = Maths::Max(0.3f, Maths::Min(1, Maths::Pow(0.80f, this.get_u16("drunk"))));
	// print("" + modifier);
	return damage * modifier;
}