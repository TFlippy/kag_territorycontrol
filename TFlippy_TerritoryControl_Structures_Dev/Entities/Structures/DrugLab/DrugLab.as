#include "Hitters.as";
#include "HittersTC.as";
#include "MakeMat.as";
#include "MaterialCommon.as";
#include "Explosion.as"; 

// A script by TFlippy

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.SetEmitSound("DrugLab_Loop.ogg");
		sprite.SetEmitSoundVolume(0.25f);
		sprite.SetEmitSoundSpeed(1.0f);
		sprite.SetEmitSoundPaused(false);
	}
	
	this.inventoryButtonPos = Vec2f(7, 13);
	
	this.getCurrentScript().tickFrequency = 10;
	this.getSprite().SetZ(-10.0f);
	
	this.set_f32("pressure", 0.00f);
	this.set_f32("pressure_max", 150000.00f);
	this.set_string("inventory_name", "Chemical Laboratory");
	
	this.addCommandID("lab_react");
	this.addCommandID("lab_add_heat");
	
	this.set_u32("next_react", getGameTime());
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("lab_react"))
	{
		React(this);
	}
	else if (cmd == this.getCommandID("lab_add_heat"))
	{
		this.add_f32("heat", 100);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;

	{
		CButton@ button = caller.CreateGenericButton(11, Vec2f(-4, -2), this, this.getCommandID("lab_react"), "React", params);
		button.SetEnabled(getGameTime() >= this.get_u32("next_react"));
	}
	
	{
		CButton@ button = caller.CreateGenericButton(11, Vec2f(-4, 6.5f), this, this.getCommandID("lab_add_heat"), "Increase Heat", params);
		button.deleteAfterClick = false;
	}
}

void React(CBlob@ this)
{
	if (getGameTime() >= this.get_u32("next_react"))
	{
		print("" + XORRandom(1));
	
		CInventory@ inv = this.getInventory();
		if (inv !is null)
		{
			const f32 mithril_count = inv.getCount("mat_mithril");
			const f32 e_mithril_count = inv.getCount("mat_mithrilenriched");
			const f32 fuel_count = inv.getCount("mat_fuel");
			const f32 acid_count = inv.getCount("mat_acid");
			const f32 oil_count = inv.getCount("mat_oil");
			const f32 sulphur_count = inv.getCount("mat_sulphur");
			const f32 meat_count = inv.getCount("mat_meat");
			const f32 methane_count = inv.getCount("mat_methane");
			const f32 mustard_count = inv.getCount("mat_mustard");
			const f32 dirt_count = inv.getCount("mat_dirt");
			const f32 coal_count = inv.getCount("mat_coal");
			
			const f32 heat = this.get_f32("heat") + Maths::Pow((mithril_count * 3.00f) + (e_mithril_count * 15.00f), 2) / 20000.00f;
			const f32 pressure = Maths::Pow(1000 + (methane_count * 75) + (fuel_count * 100) + (acid_count * 75) + (mustard_count * 25), Maths::Max(1, 1.00f + (heat * 0.0002f)));
			
			CBlob@ oil_blob = inv.getItem("mat_oil");
			CBlob@ methane_blob = inv.getItem("mat_methane");
			CBlob@ acid_blob = inv.getItem("mat_acid");
			CBlob@ fuel_blob = inv.getItem("mat_fuel");
			CBlob@ mustard_blob = inv.getItem("mat_mustard");
			CBlob@ meat_blob = inv.getItem("mat_meat");
			CBlob@ mithril_blob = inv.getItem("mat_mithril");
			CBlob@ sulphur_blob = inv.getItem("mat_sulphur");
			CBlob@ dirt_blob = inv.getItem("mat_dirt");
			CBlob@ e_mithril_blob = inv.getItem("mat_mithrilenriched");
			CBlob@ coal_blob = inv.getItem("mat_coal");

			bool hasOil = oil_blob !is null;
			bool hasMethane = methane_blob !is null;
			bool hasFuel = fuel_blob !is null;
			bool hasAcid = acid_blob !is null;
			bool hasMithrilEnriched = e_mithril_blob !is null;
			bool hasMeat = meat_blob !is null;
			bool hasDirt = dirt_blob !is null;
			bool hasSulphur = sulphur_blob !is null;
			bool hasMustard = mustard_blob !is null;
			bool hasMithril = mithril_blob !is null;
			bool hasCoal = coal_blob !is null;
						
			if (pressure > 40000 && heat > 750 && hasOil && hasMethane)
			{
				f32 count = Maths::Min(Maths::Min(methane_count, oil_count), pressure * 0.0002f);
				
				if (getNet().isServer())
				{
					oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - count, 0));
					methane_blob.server_SetQuantity(Maths::Max(methane_blob.getQuantity() - count, 0));
					Material::createFor(this, "mat_fuel", count * 1.50f);
				}
				
				ShakeScreen(60.0f, 30, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Gas.ogg", 1.00f, 1.00f);
			}
			
			if (pressure > 70000 && heat > 1300 && hasCoal)
			{
				f32 count = Maths::Min(coal_count, pressure * 0.0002f);
				print("coal");
				
				if (getNet().isServer())
				{
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - count, 0));
					Material::createFor(this, "mat_oil", count);
				}
				
				ShakeScreen(20.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Viscous.ogg", 1.00f, 1.00f);
			}
			
			if (pressure > 20000 && heat > 300 && hasMustard && hasFuel)
			{
				f32 count = Maths::Min(Maths::Min(mustard_count, fuel_count), pressure * 0.00015f);
				
				if (getNet().isServer())
				{
					mustard_blob.server_SetQuantity(Maths::Max(mustard_blob.getQuantity() - count, 0));
					fuel_blob.server_SetQuantity(Maths::Max(fuel_blob.getQuantity() - count, 0));
					Material::createFor(this, "mat_acid", count * 2.00f);
				}
				
				ShakeScreen(20.0f, 90, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}
			
			if (pressure > 1000 && heat > 300 && meat_blob !is null)
			{
				f32 count = Maths::Min(meat_count, pressure * 0.001f);
				
				if (getNet().isServer())
				{
					meat_blob.server_SetQuantity(Maths::Max(meat_blob.getQuantity() - count * 0.25f, 0));
					Material::createFor(this, "mat_methane", count * 0.75f);
					Material::createFor(this, "mat_acid", count * 0.75f);
				}
				
				ShakeScreen(10.0f, 20, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Fart.ogg", 1.00f, 1.00f);
			}
			
			if (pressure > 10000 && pressure < 50000 && heat > 1000 && hasOil)
			{
				f32 count = Maths::Min(oil_count, pressure * 0.0004f);
				
				if (getNet().isServer())
				{
					oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - count * 0.50f, 0));
					Material::createFor(this, "mat_fuel", count * 0.75f);
					Material::createFor(this, "mat_acid", count * 0.25f);
					Material::createFor(this, "mat_dirt", count * 0.50f);
				}
				
				ShakeScreen(10.0f, 10, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Viscous.ogg", 1.00f, 1.00f);
			}
			
			if (pressure > 25000 && heat > 1500 && hasMithril && hasAcid && mithril_count >= 50 && acid_count >= 25)
			{
				if (getNet().isServer())
				{
					mithril_blob.server_SetQuantity(Maths::Max(mithril_blob.getQuantity() - 50, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
					Material::createFor(this, "domino", 3 + XORRandom(6));
					Material::createFor(this, "mat_mithrilenriched", XORRandom(10));
					Material::createFor(this, "mat_fuel", XORRandom(40));
				}
				
				ShakeScreen(20.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}
			
			if (pressure > 25000 && heat > 400 && hasSulphur && hasAcid && sulphur_count >= 25 && acid_count >= 50)
			{
				if (getNet().isServer())
				{
					sulphur_blob.server_SetQuantity(Maths::Max(sulphur_blob.getQuantity() - 25, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 50, 0));
					Material::createFor(this, "stim", 3 + XORRandom(5));
					Material::createFor(this, "mat_dirt", XORRandom(15));
					Material::createFor(this, "mat_mustard", XORRandom(25));
				}
				
				ShakeScreen(10.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Liquid.ogg", 1.00f, 1.00f);
			}
			
			if (heat > 1000 && dirt_blob !is null && meat_blob !is null && hasAcid && dirt_count >= 50 && meat_count > 15 && acid_count >= 25)
			{
				if (getNet().isServer())
				{
					dirt_blob.server_SetQuantity(Maths::Max(dirt_blob.getQuantity() - 50, 0));
					meat_blob.server_SetQuantity(Maths::Max(meat_blob.getQuantity() - 15, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
					
					Material::createFor(this, "bobongo", 3 + XORRandom(5));
					Material::createFor(this, "mat_methane", XORRandom(50));
				}
				
				ShakeScreen(10.0f, 60, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Creamy.ogg", 1.00f, 1.00f);
			}
					
			if (pressure > 40000 && heat > 700 && hasAcid && hasMethane && hasMithrilEnriched && hasMeat && acid_count > 25 && methane_count > 25 && e_mithril_count > 5 && meat_count > 10)
			{
				if (getNet().isServer())
				{
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
					methane_blob.server_SetQuantity(Maths::Max(methane_blob.getQuantity() - 25, 0));
					e_mithril_blob.server_SetQuantity(Maths::Max(e_mithril_blob.getQuantity() - 5, 0));
					meat_blob.server_SetQuantity(Maths::Max(meat_blob.getQuantity() - 10, 0));
					
					Material::createFor(this, "poot", 1 + XORRandom(2));
					Material::createFor(this, "bobomax", XORRandom(2));
					Material::createFor(this, "mat_oil", XORRandom(25));
				}
				
				ShakeScreen(20.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}
			
			if (heat > 1500 && dirt_blob !is null && meat_blob !is null && hasAcid && dirt_count >= 50 && meat_count > 15 && acid_count >= 25)
			{
				if (getNet().isServer())
				{
					dirt_blob.server_SetQuantity(Maths::Max(dirt_blob.getQuantity() - 50, 0));
					meat_blob.server_SetQuantity(Maths::Max(meat_blob.getQuantity() - 15, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
					
					Material::createFor(this, "bobongo", 2 + XORRandom(4));
					Material::createFor(this, "mat_methane", XORRandom(50));
				}
				
				ShakeScreen(20.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Creamy.ogg", 1.00f, 1.00f);
			}
			
			if (pressure < 50000 && heat > 100 && hasDirt && hasAcid)
			{
				f32 count = Maths::Min(Maths::Min(dirt_count * 0.25f, acid_count), pressure * 0.00035f);
				
				if (getNet().isServer())
				{
					dirt_blob.server_SetQuantity(Maths::Max(dirt_blob.getQuantity() - count, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - count * 0.25f, 0));
					Material::createFor(this, "mat_sulphur", count * 1.75f);
				}
				
				ShakeScreen(20.0f, 30, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}
			
			if (pressure > 20000 && heat > 1000 && heat < 2000 && hasAcid && hasOil && acid_count >= 25 && oil_count >= 20)
			{
				CBlob@ bobomax = inv.getItem("bobomax");
				if (bobomax !is null)
				{
					if (getNet().isServer())
					{
						acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
						oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - 20, 0));
						bobomax.server_Die();
						
						Material::createFor(this, "foof", 3 + XORRandom(6));
					}
					
					ShakeScreen(60.0f, 15, this.getPosition());
					this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
				}
			}
			
			if (pressure < 25000 && heat > 100 && heat < 1000 && hasAcid && hasMithril && acid_count >= 15 && mithril_count >= 5)
			{
				if (getNet().isServer())
				{
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 15, 0));
					mithril_blob.server_SetQuantity(Maths::Max(mithril_blob.getQuantity() - 5, 0));
					
					Material::createFor(this, "fiks", 4 + XORRandom(4));
					Material::createFor(this, "domino", XORRandom(7));
				}
				
				ShakeScreen(30.0f, 60, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}
			
			if (pressure < 20000 && heat > 100 && heat < 750 && hasAcid && hasCoal && acid_count >= 20 && coal_count >= 15)
			{
				if (getNet().isServer())
				{
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 20, 0));
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - 15, 0));
					
					Material::createFor(this, "babby", 1 + XORRandom(2));
				}
				
				ShakeScreen(10.0f, 10, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}
			
			if (pressure < 100000 && heat > 500 && hasAcid && hasCoal && acid_count >= 25 && sulphur_count >= 100 && coal_count >= 10)
			{
				if (getNet().isServer())
				{
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
					sulphur_blob.server_SetQuantity(Maths::Max(sulphur_blob.getQuantity() - 100, 0));
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - 10, 0));
					
					Material::createFor(this, "propesko", 1 + XORRandom(4));
				}
				
				ShakeScreen(60.0f, 90, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Creamy.ogg", 1.00f, 1.00f);
			}
		}	
	}
	
	this.set_u32("next_react", getGameTime() + 15);
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	
	CInventory@ inv = this.getInventory();
	if (inv !is null)
	{
		f32 modifier = 1.00f;
		const f32 max_pressure = this.get_f32("pressure_max");
		
		const f32 mithril_count = inv.getCount("mat_mithril");
		const f32 e_mithril_count = inv.getCount("mat_mithrilenriched");
		const f32 fuel_count = inv.getCount("mat_fuel");
		const f32 acid_count = inv.getCount("mat_acid");
		const f32 methane_count = inv.getCount("mat_methane");
		const f32 mustard_count = inv.getCount("mat_mustard");
		
		const f32 heat = this.get_f32("heat") + Maths::Pow((mithril_count * 3.00f) + (e_mithril_count * 15.00f), 2) / 20000.00f;
		const f32 pressure = Maths::Pow(1000 + (methane_count * 75) + (fuel_count * 100) + (acid_count * 75) + (mustard_count * 25), Maths::Max(1, 1.00f + (heat * 0.0002f)));
		
		this.setInventoryName(this.get_string("inventory_name") + "\n\nPressure: " + Maths::Round(pressure) + " / " + max_pressure + "\nHeat: " + heat);
				
		if (getNet().isClient())
		{
			CSprite@ sprite = this.getSprite();
			if (sprite !is null)
			{
				sprite.SetEmitSoundVolume(0.30f);
				sprite.SetEmitSoundSpeed(0.75f + pressure / 50000.00f);
			}
		}
		
		this.set_f32("pressure", pressure);
		this.set_f32("heat", Maths::Max(25, heat - 7));
		
		if (pressure > max_pressure)
		{
			this.Tag("dead");
			if (getNet().isServer())
			{	
				this.server_Die();
			}
		}
		else if (pressure > max_pressure * 0.50f)
		{
			const f32 rmod = (pressure - (max_pressure * 0.50f)) / (max_pressure * 0.50f);
		
			if (getNet().isClient()) 
			{
				ShakeScreen(20 * rmod, 100 * rmod, this.getPosition());	
			}
		}
	}
}

void onDie(CBlob@ this)
{
	if (getNet().isServer()) 
	{
		for (int i = 0; i < 2; i++)
		{
			CBlob@ blob = server_CreateBlob("firegas", -1, this.getPosition());
			blob.server_SetTimeToDie(60 + XORRandom(60));
		}
	}

	Explode(this, Maths::Sqrt(this.get_f32("pressure") * 0.005f), this.get_f32("pressure") * 0.0001f);
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return !this.getMap().rayCastSolid(forBlob.getPosition(), this.getPosition());
}