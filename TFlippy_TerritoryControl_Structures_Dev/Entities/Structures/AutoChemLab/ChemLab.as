#include "Hitters.as";
#include "HittersTC.as";
#include "MakeMat.as";
#include "MaterialCommon.as";
#include "Explosion.as";
#include "Logging.as";
#include "CustomBlocks.as";

// A script by TFlippy

void onInit(CBlob@ this)
{
// building

	this.set_TileType("background tile", CMap::tile_biron);
	this.getShape().getConsts().mapCollisions = false;
	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 10;
	this.getSprite().SetZ(-10.0f);

	this.set_f32("pressure", 0.00f);
	this.set_f32("upgrade", 0.00f);
	this.set_f32("pressure_max", 180000.00f);
	this.set_string("inventory_name", "Chemical Machine");

	this.addCommandID("lab_add_heat");
	this.addCommandID("lab_remove_heat");
	this.addCommandID("upgrade");

	this.set_u32("next_react", getGameTime());

	this.set_u32(timing, time_max); //reaction timer

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.SetEmitSound("DrugLab_Loop.ogg");
		sprite.SetEmitSoundVolume(0.25f);
		sprite.SetEmitSoundSpeed(1.0f);
		sprite.SetEmitSoundPaused(false);
	}

	{
		sprite.RemoveSpriteLayer("gear1");
		CSpriteLayer@ gear = sprite.addSpriteLayer("gear1", "ChemLab.png" , 18, 18, sprite.getBlob().getTeamNum(), sprite.getBlob().getSkinNum());

		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(3);
			gear.SetOffset(Vec2f(-15.0f, -10.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
		}
	}

	{
		sprite.RemoveSpriteLayer("gear2");
		CSpriteLayer@ gear = sprite.addSpriteLayer("gear2", "ChemLab.png" , 18, 18, sprite.getBlob().getTeamNum(), sprite.getBlob().getSkinNum());

		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(3);
			gear.SetOffset(Vec2f(15.0f, -10.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
		}
	}
}

void onTick(CSprite@ this)
{
	if(this.getSpriteLayer("gear1") !is null){
		this.getSpriteLayer("gear1").RotateBy(5, Vec2f(0.0f,0.0f));
	}
	if(this.getSpriteLayer("gear2") !is null){
		this.getSpriteLayer("gear2").RotateBy(-5, Vec2f(0.0f,0.0f));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("lab_add_heat"))
	{
		this.add_f32("heat", 100);
	}
	else if (cmd == this.getCommandID("lab_remove_heat"))
	{
		this.add_f32("heat", -100);

		CInventory@ inv = this.getInventory();
		if (inv !is null)
		{
			const f32 mithril_count = inv.getCount("mat_mithril");
			const f32 e_mithril_count = inv.getCount("mat_mithrilenriched");
			const f32 methane_count = inv.getCount("mat_methane");
			const f32 fuel_count = inv.getCount("mat_fuel");
			const f32 acid_count = inv.getCount("mat_acid");
			const f32 mustard_count = inv.getCount("mat_mustard");
			const f32 heat = this.get_f32("heat") + Maths::Pow((mithril_count * 3.00f) + (e_mithril_count * 15.00f), 2) / 20000.00f;
			const f32 pressure = Maths::Pow(1000 + (methane_count * 75) + (fuel_count * 100) + (acid_count * 75) + (mustard_count * 25), Maths::Max(1, 1.00f + (heat * 0.0002f)));

			//print_log(this, "Heat; P: " + pressure + "; H: " + heat); //Disabled due to rcon spam unfortunately
		}
	}
	else if (cmd == this.getCommandID("upgrade"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			CBlob@ carried = caller.getCarriedBlob();
			if (carried !is null && carried.getName() == "mat_copperingot")
			{
				if (carried.getQuantity() >= 1)
				{
					
					int remain = carried.getQuantity() - 1;
					if (remain > 0)
					{
						carried.server_SetQuantity(remain);
					}
					else
					{
						carried.Tag("dead");
						carried.server_Die();
					}
					this.add_f32("upgrade", 2000.00f);
				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller))
	{
		CBitStream params;

		{
			CButton@ button = caller.CreateGenericButton(16, Vec2f(-8, 0.0f), this, this.getCommandID("lab_add_heat"), "Increase Heat", params);
			button.deleteAfterClick = false;
		}
		{
			CButton@ button = caller.CreateGenericButton(19, Vec2f(8, 0.0f), this, this.getCommandID("lab_remove_heat"), "Decrease Heat", params);
			button.deleteAfterClick = false;
		}
		{
			CBlob@ carried = caller.getCarriedBlob();

			if (carried != null && carried.getName() == "mat_copperingot")
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());
				CButton@ button = caller.CreateGenericButton(23, Vec2f(0, -6), this, this.getCommandID("upgrade"), "Upgrade Druglab", params);
			}
		}
	}
}

void React(CBlob@ this)
{
	if (getGameTime() >= this.get_u32("next_react"))
	{
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
			const f32 dangermeat_count = inv.getCount("mat_dangerousmeat");
			const f32 methane_count = inv.getCount("mat_methane");
			const f32 mustard_count = inv.getCount("mat_mustard");
			const f32 dirt_count = inv.getCount("mat_dirt");
			const f32 coal_count = inv.getCount("mat_coal");
			const f32 protopopov_count = inv.getCount("mat_protopopov");
			const f32 ganja_count = inv.getCount("mat_ganja");

			const f32 heat = this.get_f32("heat") + Maths::Pow((mithril_count * 3.00f) + (e_mithril_count * 15.00f), 2) / 20000.00f;
			const f32 pressure = Maths::Pow(1000 + (methane_count * 75) + (fuel_count * 100) + (acid_count * 75) + (mustard_count * 25), Maths::Max(1, 1.00f + (heat * 0.0002f)));

			//print_log(this, "React; P: " + pressure + "; H: " + heat); //Disabled due to rcon spam

			CBlob@ oil_blob = inv.getItem("mat_oil");
			CBlob@ methane_blob = inv.getItem("mat_methane");
			CBlob@ acid_blob = inv.getItem("mat_acid");
			CBlob@ fuel_blob = inv.getItem("mat_fuel");
			CBlob@ mustard_blob = inv.getItem("mat_mustard");
			CBlob@ meat_blob = inv.getItem("mat_meat");
			CBlob@ dangermeat_blob = inv.getItem("mat_dangerousmeat");
			CBlob@ mithril_blob = inv.getItem("mat_mithril");
			CBlob@ sulphur_blob = inv.getItem("mat_sulphur");
			CBlob@ dirt_blob = inv.getItem("mat_dirt");
			CBlob@ e_mithril_blob = inv.getItem("mat_mithrilenriched");
			CBlob@ coal_blob = inv.getItem("mat_coal");
			CBlob@ protopopov_blob = inv.getItem("mat_protopopov");
			CBlob@ protopopovBulb_blob = inv.getItem("protopopovbulb");
			CBlob@ vodka_blob = inv.getItem("vodka");
			CBlob@ fiks_blob = inv.getItem("fiks");
			CBlob@ grain_blob = inv.getItem("grain");
			CBlob@ rippio_blob = inv.getItem("rippio");
			CBlob@ ganja_blob = inv.getItem("mat_ganja");
			CBlob@ ganjapod_blob = inv.getItem("ganjapod");

			bool hasOil = oil_blob !is null;
			bool hasMethane = methane_blob !is null;
			bool hasFuel = fuel_blob !is null;
			bool hasAcid = acid_blob !is null;
			bool hasMithrilEnriched = e_mithril_blob !is null;
			bool hasMeat = meat_blob !is null;
			bool hasDangerMeat = dangermeat_blob !is null;
			bool hasDirt = dirt_blob !is null;
			bool hasSulphur = sulphur_blob !is null;
			bool hasMustard = mustard_blob !is null;
			bool hasMithril = mithril_blob !is null;
			bool hasCoal = coal_blob !is null;
			bool hasProtopopov = protopopov_blob !is null;
			bool hasProtopopovBulb = protopopovBulb_blob !is null;
			bool hasVodka = vodka_blob !is null;
			bool hasFiks = fiks_blob !is null;
			bool hasGrain = grain_blob !is null;
			bool hasRippio = rippio_blob !is null;
			bool hasGanja = ganja_blob !is null;
			bool hasGanjaPod = ganjapod_blob !is null;

			// Boof Gas Recipe
			if (pressure > 1000 && heat > 700 && hasGanjaPod)
			{
				if (isServer())
				{
					ganjapod_blob.server_Die();

					Material::createFor(this, "mat_boof", 15 + XORRandom(5));
				}

				ShakeScreen(20.0f, 30, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Gas.ogg", 1.00f, 1.00f);
			}
			// Boof Recipe
			if (pressure > 1000 && heat < 500 && hasGanja && hasDirt && ganja_count >= 20 && dirt_count >= 20)
			{
				if (isServer())
				{
					ganja_blob.server_SetQuantity(Maths::Max(ganja_blob.getQuantity() - 20, 0));
					dirt_blob.server_SetQuantity(Maths::Max(dirt_blob.getQuantity() - 20, 0));

					Material::createFor(this, "boof", 1 + XORRandom(2));
				}

				ShakeScreen(20.0f, 30, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Creamy.ogg", 1.00f, 1.00f);
			}
			// Gooby Recipe
			/*if (pressure > 25000 && heat > 1000 && hasRippio && hasFiks && hasDangerMeat && dangermeat_count >= 45)
			{
				if (isServer())
				{
					rippio_blob.server_Die();
					fiks_blob.server_Die();
					dangermeat_blob.server_SetQuantity(Maths::Max(dangermeat_blob.getQuantity() - 45, 0));

					Material::createFor(this, "gooby", 1 + XORRandom(2));
				}

				ShakeScreen(20.0f, 30, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}*/
			// Explodium Recipe
			if (heat < 300 && hasDangerMeat && dangermeat_count >= 15)
			{
				if (isServer())
				{
					dangermeat_blob.server_SetQuantity(Maths::Max(dangermeat_blob.getQuantity() - 15, 0));
					Material::createFor(this, "mat_explodium", 1 + XORRandom(2));
					Material::createFor(this, "mat_meat", 9 + XORRandom(5));
				}

				ShakeScreen(40.0f, 30, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Gas.ogg", 1.00f, 1.00f);
			}
			// Vodka Recipe
			if (heat > 1000 && hasGrain)
			{
				if (isServer())
				{
					grain_blob.server_Die();
					Material::createFor(this, "vodka", 1);
				}

				ShakeScreen(30.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}
			// Crack Recipe
			if (pressure < 5000 && heat > 500  && hasFiks)
			{
				if (isServer())
				{
					if (XORRandom(100) < 30)
					{
						fiks_blob.server_Die();
						Material::createFor(this, "crak", 1);
					}
					else
					{
						Material::createFor(this, "mat_coal", 3 + XORRandom(10));
					}
				}

				ShakeScreen(60.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}
			// Sosek Recipe
			if (pressure > 50000 && heat > 1500 && hasFuel && hasCoal && hasVodka && fuel_count >= 50 && coal_count >= 50)
			{
				if (isServer())
				{
					fuel_blob.server_SetQuantity(Maths::Max(fuel_blob.getQuantity() - 50, 0));
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - 50, 0));
					vodka_blob.server_Die();

					Material::createFor(this, "sosek", 2 + XORRandom(3));
				}

				ShakeScreen(20.0f, 30, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

			/*if (pressure > 100000 && heat > 500 && hasFuel && hasAcid && hasCoal && fuel_count >= 50 && acid_count >= 50 && coal_count >= 50)
			{
				if (isServer())
				{
					fuel_blob.server_SetQuantity(Maths::Max(fuel_blob.getQuantity() - 50, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 50, 0));
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - 50, 0));

					Material::createFor(this, "fumes", 2 + XORRandom(5));
				}

				ShakeScreen(20.0f, 30, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}*/
			// Dew Recipe
			if (pressure > 10000 && heat < 500 && hasProtopopov && hasAcid && hasMithril && protopopov_count >= 50 && acid_count >= 50 && mithril_count >= 25)
			{
				if (isServer())
				{
					protopopov_blob.server_SetQuantity(Maths::Max(protopopov_blob.getQuantity() - 50, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 50, 0));
					mithril_blob.server_SetQuantity(Maths::Max(mithril_blob.getQuantity() - 25, 0));

					Material::createFor(this, "dew", 2 + XORRandom(4));
				}

				ShakeScreen(20.0f, 30, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}
			// Acid & Oil Recipe
			if (heat > 1400 && hasProtopopovBulb)
			{
				if (isServer())
				{
					protopopovBulb_blob.server_Die();

					Material::createFor(this, "mat_acid", 50 + XORRandom(75));
					Material::createFor(this, "mat_oil", 25 + XORRandom(100));

					/*if (XORRandom(100) < 30)
					{
						Material::createFor(this, "fusk", 1 + XORRandom(2));
					}*/
				}

				ShakeScreen(60.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}
			// Fuel Mat Recipe
			if (pressure > 40000 && heat > 750 && hasOil && hasMethane)
			{
				f32 count = Maths::Min(Maths::Min(methane_count, oil_count), pressure * 0.0002f);

				if (isServer())
				{
					oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - count, 0));
					methane_blob.server_SetQuantity(Maths::Max(methane_blob.getQuantity() - count, 0));
					Material::createFor(this, "mat_fuel", count * 1.50f);
				}

				ShakeScreen(60.0f, 30, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Gas.ogg", 1.00f, 1.00f);
			}
			// Oil Mat Recipe
			if (pressure > 70000 && heat > 1300 && hasCoal)
			{
				f32 count = Maths::Min(coal_count, pressure * 0.0002f);
				//print("coal");

				if (isServer())
				{
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - count, 0));
					Material::createFor(this, "mat_oil", count * 1.75f);
				}

				ShakeScreen(20.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Viscous.ogg", 1.00f, 1.00f);
			}
			// Acid Mat Recipe
			if (pressure > 20000 && heat > 300 && hasMustard && hasFuel)
			{
				f32 count = Maths::Min(Maths::Min(mustard_count, fuel_count), pressure * 0.00015f);

				if (isServer())
				{
					mustard_blob.server_SetQuantity(Maths::Max(mustard_blob.getQuantity() - count, 0));
					fuel_blob.server_SetQuantity(Maths::Max(fuel_blob.getQuantity() - count, 0));
					Material::createFor(this, "mat_acid", count * 2.00f);
				}

				ShakeScreen(20.0f, 90, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}
			// Methane & Acid mat Recipe
			if (pressure > 1000 && heat > 300 && meat_blob !is null)
			{
				f32 count = Maths::Min(meat_count, pressure * 0.001f);

				if (isServer())
				{
					meat_blob.server_SetQuantity(Maths::Max(meat_blob.getQuantity() - count * 0.25f, 0));
					Material::createFor(this, "mat_methane", count * 0.75f);
					Material::createFor(this, "mat_acid", count * 0.75f);
				}

				ShakeScreen(10.0f, 20, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Fart.ogg", 1.00f, 1.00f);
			}
			// Fuel & Acid Mat Recipe
			if (pressure > 10000 && pressure < 50000 && heat > 1000 && hasOil)
			{
				f32 count = Maths::Min(oil_count, pressure * 0.0004f);

				if (isServer())
				{
					oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - count * 0.50f, 0));
					Material::createFor(this, "mat_fuel", count * 0.75f);
					Material::createFor(this, "mat_acid", count * 0.25f);
					Material::createFor(this, "mat_dirt", count * 0.50f);
				}

				ShakeScreen(10.0f, 10, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Viscous.ogg", 1.00f, 1.00f);
			}
			// Domino Drug, Fuel, Enrichedmithril Recipe
			/*if (pressure > 25000 && heat > 1500 && hasMithril && hasAcid && mithril_count >= 50 && acid_count >= 25)
			{
				if (isServer())
				{
					mithril_blob.server_SetQuantity(Maths::Max(mithril_blob.getQuantity() - 50, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
					Material::createFor(this, "domino", 2 + XORRandom(3));
					Material::createFor(this, "mat_mithrilenriched", XORRandom(10));
					Material::createFor(this, "mat_fuel", XORRandom(40));
				}

				ShakeScreen(20.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}*/
			// Stim Drug Recipe
			/*if (pressure > 25000 && heat > 400 && hasSulphur && hasAcid && sulphur_count >= 50 && acid_count >= 50)
			{
				if (isServer())
				{
					sulphur_blob.server_SetQuantity(Maths::Max(sulphur_blob.getQuantity() - 50, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 50, 0));
					Material::createFor(this, "stim", 1 + XORRandom(3));
					Material::createFor(this, "mat_dirt", XORRandom(15));
					Material::createFor(this, "mat_mustard", 5 + XORRandom(15));
				}

				ShakeScreen(10.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Liquid.ogg", 1.00f, 1.00f);
			}*/

			/*if (pressure > 40000 && heat > 700 && hasAcid && hasMethane && hasMithrilEnriched && hasMeat && acid_count > 25 && methane_count >= 25 && e_mithril_count >= 5 && meat_count >= 10)
			{
				if (isServer())
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
			}*/
			// Bobongo Recipe
			if (heat > 500 && dirt_blob !is null && meat_blob !is null && hasAcid && dirt_count >= 50 && meat_count > 15 && acid_count >= 25)
			{
				if (isServer())
				{
					dirt_blob.server_SetQuantity(Maths::Max(dirt_blob.getQuantity() - 50, 0));
					meat_blob.server_SetQuantity(Maths::Max(meat_blob.getQuantity() - 15, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));

					Material::createFor(this, "bobongo", 3 + XORRandom(5));
					Material::createFor(this, "mat_methane", XORRandom(50));

					if (XORRandom(100) < 5)
					{
						Material::createFor(this, "fusk", 2 + XORRandom(2));
					}
				}

				ShakeScreen(20.0f, 15, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Creamy.ogg", 1.00f, 1.00f);
			}
			// Sulphur Mat Recipe
			if (pressure < 50000 && heat > 100 && hasDirt && hasAcid)
			{
				f32 count = Maths::Min(Maths::Min(dirt_count * 0.25f, acid_count), pressure * 0.00035f);

				if (isServer())
				{
					dirt_blob.server_SetQuantity(Maths::Max(dirt_blob.getQuantity() - count, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - count * 0.25f, 0));
					Material::createFor(this, "mat_sulphur", count * 3.00f);
				}

				ShakeScreen(20.0f, 30, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}
			//Foof Drug Recipe
			if (pressure > 20000 && heat > 1000 && heat < 2000 && hasAcid && hasOil && acid_count >= 25 && oil_count >= 20)
			{
				CBlob@ bobomax = inv.getItem("bobomax");
				if (bobomax !is null)
				{
					if (isServer())
					{
						acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
						oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - 20, 0));
						bobomax.server_Die();

						Material::createFor(this, "foof", 1 + XORRandom(2));
					}

					ShakeScreen(60.0f, 15, this.getPosition());
					this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
				}
			}
			// Rippio Recipe
			if (heat > 2250 && hasOil && oil_count >= 25)
			{
				CBlob@ stim = inv.getItem("stim");
				if (stim !is null)
				{
					if (isServer())
					{
						oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - 25, 0));
						stim.server_Die();

						Material::createFor(this, "rippio", 1 + XORRandom(2));
						Material::createFor(this, "mat_rippio", 10 + XORRandom(35));

						//if (XORRandom(100) < 30)
						//{
							//Material::createFor(this, "love", 2);
						//}
					}

					ShakeScreen(100.0f, 15, this.getPosition());
					this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
				}
			}
			// Fiks & Domino Drug Recipe
			/*if (pressure < 25000 && heat > 500 && heat < 2000 && hasAcid && hasMithril && acid_count >= 15 && mithril_count >= 5)
			{
				if (isServer())
				{
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 15, 0));
					mithril_blob.server_SetQuantity(Maths::Max(mithril_blob.getQuantity() - 5, 0));

					Material::createFor(this, "fiks", 2 + XORRandom(2));
					Material::createFor(this, "domino", XORRandom(3));
				}

				ShakeScreen(30.0f, 60, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}*/
			// Babby Drug Recipe
			if (pressure < 20000 && heat > 100 && heat < 750 && hasAcid && hasCoal && acid_count >= 20 && coal_count >= 15)
			{
				if (isServer())
				{
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 20, 0));
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - 15, 0));

					Material::createFor(this, "babby", 2 + XORRandom(3));
				}

				ShakeScreen(10.0f, 10, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}
			// Propesko Drug Recipe
			if (pressure < 100000 && heat > 500 && hasAcid && hasCoal && acid_count >= 25 && sulphur_count >= 100 && coal_count >= 10)
			{
				if (isServer())
				{
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
					sulphur_blob.server_SetQuantity(Maths::Max(sulphur_blob.getQuantity() - 100, 0));
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - 10, 0));

					Material::createFor(this, "propesko", 1 + XORRandom(4));
					/*if (XORRandom(100) < 10)
					{
						Material::createFor(this, "love", 2);
					}*/
				}

				ShakeScreen(60.0f, 90, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Creamy.ogg", 1.00f, 1.00f);
			}
			// Schisk & bobomax recipe
			if (pressure > 40000 && heat > 2000 && hasOil && hasMithril && oil_count >= 25 && mithril_count >= 25)
			{
				if (isServer())
				{
					oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - 15, 0));
					mithril_blob.server_SetQuantity(Maths::Max(mithril_blob.getQuantity() - 5, 0));

					Material::createFor(this, "schisk", 2 + XORRandom(2));
					Material::createFor(this, "bobomax", 1 + XORRandom(2));
				}

				ShakeScreen(30.0f, 60, this.getPosition());
				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

			/*if (heat > 500 && hasOil && oil_count >= 25 && hasVodka)
			{
				CBlob@ vodka = inv.getItem("vodka");
				if (vodka !is null)
				{
					if (isServer())
					{
						oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - 25, 0));
						vodka.server_Die();

						Material::createFor(this, "paxilon", 2 + XORRandom(2));
						Material::createFor(this, "mat_paxilon", 15 + XORRandom(35));

						if (XORRandom(100) < 3)
						{
							Material::createFor(this, "fusk", 2 + XORRandom(2));
						}
					}

					ShakeScreen(100.0f, 15, this.getPosition());
					this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
				}
			}*/
		}
	}

	this.set_u32("next_react", getGameTime() + 15);
}

//reaction timer
const string timing = "reacttimer";
const u32 time_max = 5;


void onRender(CSprite@ this)
{
	CBlob@ local = getLocalPlayerBlob();
	CBlob@ b = this.getBlob();
	if(local !is null && local.isMyPlayer() && getMap().getBlobAtPosition(getControls().getMouseWorldPos()) is b)
	{
		GUI::SetFont("MENU");
		GUI::DrawText(b.get_string("drawText"), b.getInterpolatedScreenPos() + Vec2f(16,-24), SColor(255,255,50,50).getInterpolated(SColor(255,50,255,50), b.get_f32("percentageToMax")));
	}
}

void onTick(CBlob@ this)
{

  const u32 time = this.get_u32(timing);
  if (time > 0) {
     this.add_u32(timing, -1);
  }
  else {
    this.set_u32(timing, time_max);
    React(this);
  }

  if (this.hasTag("dead")) return;

	CInventory@ inv = this.getInventory();
	if (inv !is null)
	{
		f32 modifier = 1.00f;
		const f32 max_pressure = this.get_f32("pressure_max") + this.get_f32("upgrade");

		const f32 mithril_count = inv.getCount("mat_mithril");
		const f32 e_mithril_count = inv.getCount("mat_mithrilenriched");
		const f32 fuel_count = inv.getCount("mat_fuel");
		const f32 acid_count = inv.getCount("mat_acid");
		const f32 methane_count = inv.getCount("mat_methane");
		const f32 mustard_count = inv.getCount("mat_mustard");

		const f32 heat = this.get_f32("heat") + Maths::Pow((mithril_count * 3.00f) + (e_mithril_count * 15.00f), 2) / 20000.00f;
		const f32 pressure = Maths::Pow(1000 + (methane_count * 75) + (fuel_count * 100) + (acid_count * 75) + (mustard_count * 25), Maths::Max(1, 1.00f + (heat * 0.0002f)));

		//this.setInventoryName(this.get_string("inventory_name") + "\n\nPressure: " + Maths::Round(pressure) + " / " + max_pressure + "\nHeat: " + heat);
		this.set_string("drawText",this.get_string("inventory_name") + "\n\nPressure: " + Maths::Round(pressure) + " / " + max_pressure + "\nHeat: " + heat);
		this.set_f32("percentageToMax", pressure/max_pressure);
		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			if (sprite !is null)
			{
				sprite.SetEmitSoundVolume(0.30f);
				sprite.SetEmitSoundSpeed(0.75f + pressure / 50000.00f);
			}
		}

		this.set_f32("pressure", pressure);
		this.set_f32("heat", Maths::Max(25, heat - 0));

		if (pressure > max_pressure)
		{
			this.Tag("dead");
			if (isServer())
			{
				print_log(this, "Exploding due to overheating; P: " + pressure + "; H: " + heat);
				this.server_Die();
			}
		}
		else if (pressure > max_pressure * 0.50f)
		{
			const f32 rmod = (pressure - (max_pressure * 0.50f)) / (max_pressure * 0.50f);

			if (isClient())
			{
				ShakeScreen(20 * rmod, 100 * rmod, this.getPosition());
			}
		}
	}
}

const string[] chemNames = {
	"mat_oil",
	"mat_methane",
	"mat_acid",
	"mat_fuel",
	"mat_mustard",
	"mat_meat",
	"mat_dangerousmeat",
	"mat_mithril",
	"mat_sulphur",
	"mat_dirt",
	"mat_mithrilenriched",
	"mat_coal",
	"mat_protopopov",
	"protopopovbulb",
	//"vodka",
	//"fiks",
	"grain",
	//"rippio",
	"mat_ganja",
	"ganjapod"
};

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if (!blob.isAttached())
	{
		string config = blob.getName();
		for (int i = 0; i < chemNames.length; i++)
		{
			if (config == chemNames[i])
			{
				if (isServer()) this.server_PutInInventory(blob);
				if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
			}
		}
	}
}

void onDie(CBlob@ this)
{
	if (isServer())
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
