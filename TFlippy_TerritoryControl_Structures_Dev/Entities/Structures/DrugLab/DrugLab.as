#include "Hitters.as";
#include "HittersTC.as";
#include "MakeMat.as";
#include "MaterialCommon.as";
#include "Explosion.as";
#include "Logging.as";

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

	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 10;
	this.getSprite().SetZ(-10.0f);

	this.set_f32("pressure", 0.00f);
	this.set_f32("upgrade", 0.00f);
	this.set_s16("upgrade_cost", 1);
	this.set_f32("pressure_max", 150000.00f);
	this.set_string("inventory_name", "Chemical Laboratory");

	this.addCommandID("lab_react");
	this.addCommandID("lab_add_heat");
	this.addCommandID("upgrade");

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

			//print_log(this, "Heat; P: " + pressure + "; H: " + heat);
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
				u8 cost = Maths::Max(this.get_s16("upgrade_cost"), 1);
				if (carried.getQuantity() >= cost)
				{
					int remain = carried.getQuantity() - cost;
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
					this.add_s16("upgrade_cost", 1);
				}
				else if (caller.isMyPlayer()) client_AddToChat("Not enough copper ingots! Upgrade costs "+cost+" copper ingots.", SColor(0xff444444));
			}
			else if (carried !is null && carried.getName() == "mat_steelingot")	// Stronger foundation
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
					this.add_f32("upgrade", 1000.00f);
					this.add_s16("upgrade_cost", -6);
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
			CButton@ button = caller.CreateGenericButton(11, Vec2f(-4, -2), this, this.getCommandID("lab_react"), "React", params);
			button.SetEnabled(getGameTime() >= this.get_u32("next_react"));
		}
		{
			CButton@ button = caller.CreateGenericButton(11, Vec2f(-4, 6.5f), this, this.getCommandID("lab_add_heat"), "Increase Heat", params);
			button.deleteAfterClick = false;
		}
		{
			CBlob@ carried = caller.getCarriedBlob();

			if (carried != null && (carried.getName() == "mat_copperingot" || carried.getName() == "mat_steelingot"))
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());
				CButton@ button = caller.CreateGenericButton(23, Vec2f(3, -2), this, this.getCommandID("upgrade"), "Upgrade Druglab", params);
				button.deleteAfterClick = false;
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
			const f32 grain_count = inv.getCount("grain");

			const f32 heat = this.get_f32("heat") + Maths::Pow((mithril_count * 3.00f) + (e_mithril_count * 15.00f), 2) / 20000.00f;
			const f32 pressure = Maths::Pow(1000 + (methane_count * 75) + (fuel_count * 100) + (acid_count * 75) + (mustard_count * 25), Maths::Max(1, 1.00f + (heat * 0.0002f)));

			//print_log(this, "React; P: " + pressure + "; H: " + heat);

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
			CBlob@ pumpkin_blob = inv.getItem("pumpkin");
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
			bool hasPumpkin = pumpkin_blob !is null;
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

				this.getSprite().PlaySound("DrugLab_Create_Creamy.ogg", 1.00f, 1.00f);
			}
			// Gooby Recipe
			if (pressure > 25000 && heat > 1000 && hasRippio && hasFiks && hasDangerMeat && dangermeat_count >= 45)
			{
				if (isServer())
				{
					rippio_blob.server_SetQuantity(Maths::Max(rippio_blob.getQuantity() - 1, 0));
					if (rippio_blob.getQuantity() <= 0) rippio_blob.server_Die();
					fiks_blob.server_SetQuantity(Maths::Max(fiks_blob.getQuantity() - 1, 0));
					if (fiks_blob.getQuantity() <= 0) fiks_blob.server_Die();
					dangermeat_blob.server_SetQuantity(Maths::Max(dangermeat_blob.getQuantity() - 45, 0));

					Material::createFor(this, "gooby", 3 + XORRandom(2));
				}

				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

			if (heat < 300 && hasDangerMeat && dangermeat_count >= 15)
			{
				if (isServer())
				{
					dangermeat_blob.server_SetQuantity(Maths::Max(dangermeat_blob.getQuantity() - 15, 0));
					Material::createFor(this, "mat_explodium", 1 + XORRandom(2));
					Material::createFor(this, "mat_meat", 9 + XORRandom(5));
				}

				this.getSprite().PlaySound("DrugLab_Create_Gas.ogg", 1.00f, 1.00f);
			}

			if (heat > 1500 && hasPumpkin)
			{
				if (isServer())
				{
					pumpkin_blob.server_SetQuantity(Maths::Max(pumpkin_blob.getQuantity() - 1, 0));
					if (pumpkin_blob.getQuantity() <= 0) pumpkin_blob.server_Die();
					Material::createFor(this, "mat_acid", 10 + XORRandom(5));
					if (hasMithrilEnriched) Material::createFor(this, "fusk", 1 + XORRandom(2));
				}

				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}

			if (heat > 1000 && hasGrain && hasMithril)
			{
				if (isServer())
				{
					grain_blob.server_SetQuantity(Maths::Max(grain_blob.getQuantity() - 1, 0));
					if (grain_blob.getQuantity() <= 0) grain_blob.server_Die();
					mithril_blob.server_SetQuantity(Maths::Max(mithril_blob.getQuantity() - 100, 0));

					Material::createFor(this, "radpill", 4 + XORRandom(6));
				}

				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}
			else if (heat > 1000 && hasGrain)
			{
				f32 count = Maths::Min(grain_count, pressure * 0.0002f);
				if (isServer())
				{
					grain_blob.server_SetQuantity(Maths::Max(grain_blob.getQuantity() - count, 0));
					if (grain_blob.getQuantity() <= 0) grain_blob.server_Die();
					Material::createFor(this, "vodka", count);
				}

				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}

			if (pressure < 5000 && heat > 500  && hasFiks)
			{
				if (isServer())
				{
					if (XORRandom(100) < 30)
					{
						fiks_blob.server_SetQuantity(Maths::Max(fiks_blob.getQuantity() - 1, 0));
						if (fiks_blob.getQuantity() <= 0) fiks_blob.server_Die();
						Material::createFor(this, "crak", 1);
					}
					else
					{
						Material::createFor(this, "mat_coal", 3 + XORRandom(10));
					}
				}

				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

			if (pressure > 50000 && heat > 1500 && hasFuel && hasCoal && hasVodka && fuel_count >= 50 && coal_count >= 50)
			{
				if (isServer())
				{
					fuel_blob.server_SetQuantity(Maths::Max(fuel_blob.getQuantity() - 50, 0));
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - 50, 0));
					vodka_blob.server_SetQuantity(Maths::Max(vodka_blob.getQuantity() - 1, 0));
					if (vodka_blob.getQuantity() <= 0) vodka_blob.server_Die();

					Material::createFor(this, "sosek", 2 + XORRandom(3));
				}

				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

			if (pressure > 100000 && heat > 500 && hasFuel && hasAcid && hasCoal && fuel_count >= 50 && acid_count >= 50 && coal_count >= 50)
			{
				if (isServer())
				{
					fuel_blob.server_SetQuantity(Maths::Max(fuel_blob.getQuantity() - 50, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 50, 0));
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - 50, 0));

					Material::createFor(this, "fumes", 2 + XORRandom(5));
				}

				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

			if (pressure > 10000 && heat < 500 && hasProtopopov && hasAcid && hasMithril && protopopov_count >= 50 && acid_count >= 50 && mithril_count >= 25)
			{
				if (isServer())
				{
					protopopov_blob.server_SetQuantity(Maths::Max(protopopov_blob.getQuantity() - 50, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 50, 0));
					mithril_blob.server_SetQuantity(Maths::Max(mithril_blob.getQuantity() - 25, 0));

					Material::createFor(this, "dew", 2 + XORRandom(4));
				}

				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}

			if (heat > 1400 && hasProtopopovBulb)
			{
				if (isServer())
				{
					protopopovBulb_blob.server_Die();

					Material::createFor(this, "mat_acid", 50 + XORRandom(75));
					Material::createFor(this, "mat_oil", 25 + XORRandom(100));

					if (XORRandom(100) < 30)
					{
						Material::createFor(this, "fusk", 1 + XORRandom(2));
					}
				}

				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

			if (pressure > 40000 && heat > 750 && hasOil && hasMethane)
			{
				f32 count = Maths::Min(Maths::Min(methane_count, oil_count), pressure * 0.0002f);

				if (isServer())
				{
					oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - count, 0));
					methane_blob.server_SetQuantity(Maths::Max(methane_blob.getQuantity() - count, 0));
					Material::createFor(this, "mat_fuel", count * 1.50f);
				}

				this.getSprite().PlaySound("DrugLab_Create_Gas.ogg", 1.00f, 1.00f);
			}

			if (pressure > 70000 && heat > 1300 && hasCoal)
			{
				f32 count = Maths::Min(coal_count, pressure * 0.0002f);
				//print("coal");

				if (isServer())
				{
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - count, 0));
					Material::createFor(this, "mat_oil", count * 1.75f);
				}

				this.getSprite().PlaySound("DrugLab_Create_Viscous.ogg", 1.00f, 1.00f);
			}

			if (pressure > 5000 && heat > 500 && hasMustard && hasDirt)
			{
				f32 count = Maths::Min(Maths::Min(mustard_count, dirt_count), pressure * 0.00035f);

				if (isServer())
				{
					mustard_blob.server_SetQuantity(Maths::Max(mustard_blob.getQuantity() - count * 0.25f, 0));
					dirt_blob.server_SetQuantity(Maths::Max(dirt_blob.getQuantity() - count, 0));
					Material::createFor(this, "mat_methane", count * 2.00f);
				}

				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}

			if (pressure > 1000 && heat > 300 && meat_blob !is null)
			{
				f32 count = Maths::Min(meat_count, pressure * 0.001f);

				if (isServer())
				{
					meat_blob.server_SetQuantity(Maths::Max(meat_blob.getQuantity() - count * 0.25f, 0));
					Material::createFor(this, "mat_methane", count * 0.75f);
					Material::createFor(this, "mat_acid", count * 0.75f);
				}

				this.getSprite().PlaySound("DrugLab_Create_Fart.ogg", 1.00f, 1.00f);
			}

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

				this.getSprite().PlaySound("DrugLab_Create_Viscous.ogg", 1.00f, 1.00f);
			}

			if (pressure > 25000 && heat > 1500 && hasMithril && hasAcid && mithril_count >= 50 && acid_count >= 25)
			{
				if (isServer())
				{
					mithril_blob.server_SetQuantity(Maths::Max(mithril_blob.getQuantity() - 50, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
					Material::createFor(this, "domino", 9 + XORRandom(6));
					Material::createFor(this, "mat_mithrilenriched", 5 + XORRandom(5));
					Material::createFor(this, "mat_fuel", 20 + XORRandom(20));
				}

				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

			if (pressure > 25000 && heat > 400 && hasSulphur && hasAcid && sulphur_count >= 50 && acid_count >= 50)
			{
				if (isServer())
				{
					sulphur_blob.server_SetQuantity(Maths::Max(sulphur_blob.getQuantity() - 50, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 50, 0));
					Material::createFor(this, "stim", 8 + XORRandom(7));
					Material::createFor(this, "mat_dirt", XORRandom(15));
					Material::createFor(this, "mat_mustard", 5 + XORRandom(15));
				}

				this.getSprite().PlaySound("DrugLab_Create_Liquid.ogg", 1.00f, 1.00f);
			}

			if (pressure > 40000 && heat > 700 && hasAcid && hasMethane && hasMithrilEnriched && hasMeat && acid_count > 25 && methane_count >= 25 && e_mithril_count >= 5 && meat_count >= 10)
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

				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

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

				this.getSprite().PlaySound("DrugLab_Create_Creamy.ogg", 1.00f, 1.00f);
			}

			if (pressure < 50000 && heat > 100 && hasDirt && hasAcid)
			{
				f32 count = Maths::Min(Maths::Min(dirt_count * 0.25f, acid_count), pressure * 0.00035f);

				if (isServer())
				{
					dirt_blob.server_SetQuantity(Maths::Max(dirt_blob.getQuantity() - count, 0));
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - count * 0.25f, 0));
					Material::createFor(this, "mat_sulphur", count * 3.00f);
				}

				this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
			}

			if (pressure > 20000 && heat > 1000 && heat < 2000 && hasAcid && hasOil && acid_count >= 25 && oil_count >= 20)
			{
				CBlob@ bobomax = inv.getItem("bobomax");
				if (bobomax !is null)
				{
					if (isServer())
					{
						acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
						oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - 20, 0));
						bobomax.server_SetQuantity(Maths::Max(bobomax.getQuantity() - 1, 0));
						if (bobomax.getQuantity() <= 0) bobomax.server_Die();

						Material::createFor(this, "foof", 3 + XORRandom(7));
					}


					this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
				}
			}

			if (heat > 2250 && hasOil && oil_count >= 25)
			{
				CBlob@ stim = inv.getItem("stim");
				if (stim !is null)
				{
					if (isServer())
					{
						oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - 25, 0));
						stim.server_SetQuantity(Maths::Max(stim.getQuantity() - 1, 0));
						if (stim.getQuantity() <= 0) stim.server_Die();

						Material::createFor(this, "rippio", 2 + XORRandom(2));
						Material::createFor(this, "mat_rippio", 15 + XORRandom(35));

						if (XORRandom(100) < 30)
						{
							Material::createFor(this, "love", 2);
						}
					}


					this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
				}
			}

			if (pressure < 25000 && heat > 500 && heat < 2000 && hasAcid && hasMithril && acid_count >= 15 && mithril_count >= 5)
			{
				if (isServer())
				{
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 15, 0));
					mithril_blob.server_SetQuantity(Maths::Max(mithril_blob.getQuantity() - 5, 0));

					Material::createFor(this, "fiks", 4 + XORRandom(4));
					Material::createFor(this, "domino", 3 + XORRandom(5));
				}

				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

			if (pressure < 20000 && heat > 100 && heat < 750 && hasAcid && hasCoal && acid_count >= 20 && coal_count >= 15)
			{
				if (isServer())
				{
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 20, 0));
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - 15, 0));

					Material::createFor(this, "babby", 2 + XORRandom(3));
				}

				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

			if (pressure < 100000 && heat > 500 && hasAcid && hasCoal && acid_count >= 25 && sulphur_count >= 100 && coal_count >= 10)
			{
				if (isServer())
				{
					acid_blob.server_SetQuantity(Maths::Max(acid_blob.getQuantity() - 25, 0));
					sulphur_blob.server_SetQuantity(Maths::Max(sulphur_blob.getQuantity() - 100, 0));
					coal_blob.server_SetQuantity(Maths::Max(coal_blob.getQuantity() - 10, 0));

					Material::createFor(this, "propesko", 1 + XORRandom(4));
					if (XORRandom(100) < 10)
					{
						Material::createFor(this, "love", 2);
					}
				}

				this.getSprite().PlaySound("DrugLab_Create_Creamy.ogg", 1.00f, 1.00f);
			}

			if (pressure > 40000 && heat > 2000 && hasOil && hasMithril && oil_count >= 25 && mithril_count >= 25)
			{
				if (isServer())
				{
					oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - 15, 0));
					mithril_blob.server_SetQuantity(Maths::Max(mithril_blob.getQuantity() - 5, 0));

					Material::createFor(this, "schisk", 2 + XORRandom(3));
					Material::createFor(this, "bobomax", 1 + XORRandom(3));
				}

				this.getSprite().PlaySound("DrugLab_Create_Solid.ogg", 1.00f, 1.00f);
			}

			if (heat > 500 && hasOil && oil_count >= 25 && hasVodka)
			{
				if (vodka_blob !is null)
				{
					if (isServer())
					{
						oil_blob.server_SetQuantity(Maths::Max(oil_blob.getQuantity() - 25, 0));
						vodka_blob.server_SetQuantity(Maths::Max(vodka_blob.getQuantity() - 1, 0));
						if (vodka_blob.getQuantity() <= 0) vodka_blob.server_Die();

						Material::createFor(this, "paxilon", 2 + XORRandom(2));
						Material::createFor(this, "mat_paxilon", 15 + XORRandom(35));

						if (XORRandom(100) < 3)
						{
							Material::createFor(this, "fusk", 2 + XORRandom(2));
						}
					}

					this.getSprite().PlaySound("DrugLab_Create_Acidic.ogg", 1.00f, 1.00f);
				}
			}
		}
	}

	this.set_u32("next_react", getGameTime() + 15);
}

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

		//this.setInventoryName();
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
		this.set_f32("heat", Maths::Max(25, heat - 7));

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
