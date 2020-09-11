#include "MakeSeed.as";
#include "MakeMat.as";
#include "Explosion.as";
#include "PlantGrowthCommon.as";

void onInit(CBlob @ this)
{
	this.getCurrentScript().tickFrequency = 30;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this)
{
	if (this.hasTag("has bulb") && XORRandom(10) == 0)
	{
		this.Tag("bulb exploded");
		this.server_Die();
	}
	
	// f32 amount = Maths::Pow(this.get_u8(grown_amount) / f32(growth_max), 2.00f);
	// print("" + amount);
}

void onDie(CBlob@ this)
{
	bool bulb_exploded = false;

	if (this.hasTag("has bulb"))
	{
		bulb_exploded = this.hasTag("bulb exploded");
		
		if (isServer())
		{
			if (!bulb_exploded)
			{
				CBlob@ bulb = server_CreateBlob("protopopovbulb", this.getTeamNum(), this.getPosition() + Vec2f(0, -12));
				if (bulb !is null)
				{
					bulb.setVelocity(Vec2f(XORRandom(5) - 2.5f, XORRandom(5) - 2.5f));
				}
			}
			
			int count = 2 + XORRandom(3);
			for (int i = 0; i < count; i++)
			{
				CBlob@ seed = server_MakeSeed(this.getPosition() + Vec2f(0, -32), "protopopov_plant");
				if (seed !is null)
				{
					seed.setVelocity(Vec2f(16.00f - XORRandom(32), -4.00f - XORRandom(8)));
					seed.Tag("gas immune");
				}
			}
		}
		
		if (bulb_exploded)
		{
			DoExplosion(this);
		}
	}
	
	if (isServer())
	{
		f32 amount = 0.00f;
		
		if (bulb_exploded) amount = 5 + XORRandom(15);
		else amount = 20 + XORRandom(40);

		amount *= Maths::Pow(this.get_u8(grown_amount) / f32(growth_max), 2.00f);

		MakeMat(this, this.getPosition() + Vec2f(0, -3), "mat_protopopov", Maths::Ceil(amount));	
	}
}

void DoExplosion(CBlob@ this)
{

	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}

	this.set_f32("map_damage_radius", 16.0f);
	this.set_f32("map_damage_ratio", 0.20f);
	this.set_Vec2f("explosion_offset", Vec2f(0, -12));

	Explode(this, 24.0f, 1.0f);

	if (!this.hasTag("dead"))
	{
		if (isServer())
		{
			for (int i = 0; i < 3 + XORRandom(5); i++)
			{
				CBlob@ blob = server_CreateBlobNoInit("acidgas");
				blob.server_setTeamNum(-1);
				blob.setPosition(this.getPosition() + Vec2f(0, -12));
				blob.setVelocity(Vec2f(4 - XORRandom(8), -XORRandom(8)));
				blob.set_u16("acid_strength", 25);
				blob.Init();
				blob.server_SetTimeToDie(5 + XORRandom(10));
			}
		}
		
		
		this.Tag("dead");
		this.getSprite().Gib();
	}
}