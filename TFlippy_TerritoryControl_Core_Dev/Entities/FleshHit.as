// Flesh hit

#include "Hitters.as";
#include "HittersTC.as";

void onInit(CBlob@ this)
{
	this.Tag("flesh");
}

f32 getGibHealth(CBlob@ this)
{
	if (this.exists("gib health"))
	{
		return this.get_f32("gib health");
	}

	return 0.0f;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;

	switch (customData)
	{
		// TC		
		case HittersTC::bullet_low_cal:
		case HittersTC::bullet_high_cal:
		case HittersTC::shotgun:
			dmg *= 1.00f;
			break;
			
		case HittersTC::radiation:
			// dmg = Maths::Max((dmg * 2.00f) * (this.get_u8("radpilled") * 0.10f), 0);
			dmg *= 2.00f / (1.00f + this.get_u8("radpilled") * 10.00f);
			break;
		// Vanilla
		case Hitters::builder:
			dmg *= 1.75f;
			break;

		case Hitters::spikes:
		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			dmg *= 1.25f;
			break;

		case Hitters::drill:
		case Hitters::bomb_arrow:
		case Hitters::bomb:
			dmg *= 1.50f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
		case Hitters::crush:
			dmg *= 2.00f;
			break;

		case Hitters::fire:
		case Hitters::cata_stones:
		case Hitters::flying: // boat ram
			dmg *= 4.00f;
			break;
		
		case Hitters::burn:
			dmg *= 2.50f;
			break;

	}

	if (isServer())
	{
		if (customData == HittersTC::radiation)
		{
			if (this.hasTag("human") && !this.hasTag("transformed") && this.getHealth() <= 0.125f && XORRandom(2) == 0)
			{
				CBlob@ man = server_CreateBlob("mithrilman", this.getTeamNum(), this.getPosition());
				if (this.getPlayer() !is null) man.server_SetPlayer(this.getPlayer());
				this.Tag("transformed");
				this.server_Die();
			}
		}
	}
	
	if (this.hasTag("equipment support"))
	{
		bool isBullet = (customData == HittersTC::bullet_low_cal || customData == HittersTC::bullet_high_cal || customData == HittersTC::shotgun || customData == HittersTC::railgun_lance);
		// torso
		if (this.get_string("equipment_torso") == "bulletproofvest" && customData != HittersTC::radiation)
		{
			f32 armorMaxHealth = 25.0f;
			f32 armorHealth = armorMaxHealth - this.get_f32("bpv_health");
			f32 ratio = armorHealth / armorMaxHealth;

			switch (customData)
			{
				case HittersTC::bullet_low_cal:
					ratio *= 0.80f;
					break;

				case HittersTC::bullet_high_cal:
				case HittersTC::railgun_lance:
					ratio *= 0.60f;
					break;

				case HittersTC::shotgun:
					ratio *= 0.85f;
					break;

				default:
					ratio *= 0.40f;
					break;
			}
			
			this.set_f32("bpv_health", this.get_f32("bpv_health") + (ratio*dmg));
			f32 playerDamage = Maths::Clamp((1.00f - ratio) * dmg, 0, dmg);

			dmg = playerDamage;
		}
		else if (this.get_string("equipment_torso") == "keg" && !isBullet && customData != HittersTC::radiation)
		{
			f32 armorMaxHealth = 7.0f;
			f32 armorHealth = armorMaxHealth - this.get_f32("keg_health");
			f32 ratio = armorHealth / armorMaxHealth;

			if ((customData == Hitters::fire || customData == Hitters::burn || customData == Hitters::explosion || 
				customData == Hitters::bomb || customData == Hitters::bomb_arrow) && this.get_f32("keg_explode") == 0.0f)
			{
				this.set_f32("keg_explode", getGameTime() + (30.0f * 1.0f));
				this.SetLightRadius(this.get_f32("explosive_radius") * 0.5f);
				this.getSprite().PlaySound("/Sparkle.ogg", 1.00f, 1.00f);
				this.getSprite().PlaySound("MigrantScream1.ogg", 1.00f, this.getSexNum() == 0 ? 1.0f : 2.0f);
				ratio *= 0.0f;
			}
			else ratio *= 0.50f;
			
			this.set_f32("keg_health", this.get_f32("keg_health") + (ratio*dmg));
			f32 playerDamage = Maths::Clamp((1.00f - ratio) * dmg, 0, dmg);

			dmg = playerDamage;
		}
		// head
		if (this.get_string("equipment_head") == "militaryhelmet" && customData != HittersTC::radiation)
		{
			f32 armorMaxHealth = 20.0f;
			f32 armorHealth = armorMaxHealth - this.get_f32("mh_health");
			f32 ratio = armorHealth / armorMaxHealth;

			switch (customData)
			{
				case HittersTC::bullet_low_cal:
					ratio *= 0.80f;
					break;

				case HittersTC::bullet_high_cal:
				case HittersTC::railgun_lance:
					ratio *= 0.60f;
					break;

				case HittersTC::shotgun:
					ratio *= 0.85f;
					break;

				default:
					ratio *= 0.30f;
					break;
			}
			
			this.set_f32("mh_health", this.get_f32("mh_health") + (ratio*dmg));
			f32 playerDamage = Maths::Clamp((1.00f - ratio) * dmg, 0, dmg);

			dmg = playerDamage;
		}
		else if (this.get_string("equipment_head") == "bucket" && !isBullet && customData != HittersTC::radiation)
		{
			f32 armorMaxHealth = 5.0f;
			f32 armorHealth = armorMaxHealth - this.get_f32("bucket_health");
			f32 ratio = armorHealth / armorMaxHealth;

			switch (customData)
			{
				case Hitters::fire:
				case Hitters::burn:
					ratio *= 0.10f;
					break;

				default: ratio *= 0.30f;
					break;
			}
			
			this.set_f32("bucket_health", this.get_f32("bucket_health") + (ratio*dmg));
			f32 playerDamage = Maths::Clamp((1.00f - ratio) * dmg, 0, dmg);

			dmg = playerDamage;
		}
	}
	
	this.Damage(dmg, hitterBlob);

	f32 gibHealth = getGibHealth(this);

	if (this.getHealth() <= gibHealth)
	{
		this.getSprite().Gib();
		this.Tag("do gib");
		
		this.server_Die();
	}

	return 0.0f; //done, we've used all the damage
}

void onDie(CBlob@ this)
{
	if (this.hasTag("do gib"))
	{
		f32 count = 2 + XORRandom(4);
		int frac = Maths::Min(250, this.getMass() / count) * 0.50f;
		f32 radius = this.getRadius();
		
		f32 explodium_amount = this.get_f32("propeskoed") * 0.50f / count;
		
		for (int i = 0; i < count; i++)
		{
			if (isClient())
			{
				this.getSprite().PlaySound("Pigger_Gore.ogg", 0.3f, 0.9f);
				ParticleBloodSplat(this.getPosition() + getRandomVelocity(0, radius, 360), true);
			}
		
			if (isServer())
			{
				Vec2f vel = Vec2f(XORRandom(4) - 2, -2 - XORRandom(4));
				
				if (explodium_amount > 0.00f)
				{
					CBlob@ blob = server_CreateBlob("mat_dangerousmeat", this.getTeamNum(), this.getPosition());
					blob.server_SetQuantity(1 + (frac * 0.60f + XORRandom(frac)));
					//blob.setVelocity(vel);
				}
				else
				{
					CBlob@ blob = server_CreateBlob("mat_meat", this.getTeamNum(), this.getPosition());

					if (blob !is null)
					{
					//if (explodium_amount > 0.00f) blob.set_f32("explodium_amount", explodium_amount);

					// print("" + explodium_amount);
				
					blob.server_SetQuantity(1 + (frac * 0.25f + XORRandom(frac)));
					blob.setVelocity(vel);
					}
				}
			}
		}
	}
}
