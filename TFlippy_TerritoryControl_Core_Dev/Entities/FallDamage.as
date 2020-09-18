//fall damage for all characters and fall damaged items
// apply Rules "fall vel modifier" property to change the damage velocity base

#include "Hitters.as";
#include "Knocked.as";
#include "FallDamageCommon.as";

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!solid)
	{
		return;
	}

	if (blob !is null && (blob.hasTag("player") || blob.hasTag("no falldamage")))
	{
		return; //no falldamage when stomping
	}

	f32 vely = this.getOldVelocity().y;

	if (vely < 0 || Maths::Abs(normal.x) > Maths::Abs(normal.y) * 2) { return; }

	f32 damage = FallDamageAmount(vely);
	if (damage != 0.0f) //interesting value
	{
		bool doknockdown = true;

		if (damage > 0.0f)
		{
			// check if we aren't touching a trampoline
			CBlob@[] overlapping;

			if (this.getOverlapping(@overlapping))
			{
				for (uint i = 0; i < overlapping.length; i++)
				{
					CBlob@ b = overlapping[i];

					if (b.hasTag("no falldamage"))
					{
						return;
					}
				}
			}

			if (damage > 0.1f)
			{
				//print("damage: "+damage);
				if (this.hasTag("equipment support"))
				{
					if (this.get_string("equipment_boots") == "combatboots")
					{
						f32 dmg = damage;
						f32 cbootsMaxHealth = 20.0f;
						f32 cbootsHealth = cbootsMaxHealth - this.get_f32("cb_health");
						f32 ratio = cbootsHealth / cbootsMaxHealth * 0.25f;
						f32 cbootsDamage = ratio * dmg;
						f32 curcbootsHp = this.get_f32("mh_health");
			
						this.set_f32("cb_health", curcbootsHp + cbootsDamage);
						
						f32 playerDamage = Maths::Clamp((1.00f - ratio) * dmg, 0, dmg);
						//print("playerDamage: "+playerDamage);
						this.server_Hit(this, point1, normal, playerDamage, Hitters::fall);
					}
					else if (this.get_string("equipment_boots") == "rendeboots")
					{
						this.server_Hit(this, point1, normal, damage * 0.4f, Hitters::fall);
					}
					else
					{
						this.server_Hit(this, point1, normal, damage, Hitters::fall);
					}
				}
				//else
					//this.server_Hit(this, point1, normal, damage, Hitters::fall);
			}
			else
			{
				doknockdown = false;
			}
		}

		// stun on fall
		const u8 knockdown_time = 12;

		if (doknockdown && this.exists("knocked") && getKnocked(this) < knockdown_time)
		{
			if (damage < this.getHealth()) //not dead
				Sound::Play("/BreakBone", this.getPosition());
			else
			{
				Sound::Play("/FallDeath.ogg", this.getPosition());
			}

			SetKnocked(this, knockdown_time);
		}
	}
}
