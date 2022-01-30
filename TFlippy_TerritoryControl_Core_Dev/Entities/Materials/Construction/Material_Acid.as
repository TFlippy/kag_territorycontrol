#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.maxQuantity = 100;
	this.Tag("mat_gas");
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}
	
	if (!this.hasTag("dead"))
	{
		f32 quantity = this.getQuantity();
		if (quantity > 0)
		{
			if (isServer())
			{
				for (int i = 0; i < (quantity / 15) + XORRandom(quantity / 15) ; i++)
				{
					CBlob@ blob = server_CreateBlobNoInit("acidgas");
					blob.server_setTeamNum(-1);
					blob.setPosition(this.getPosition());
					blob.setVelocity(Vec2f(XORRandom(16) - 8, -XORRandom(5)));
					blob.set_u16("acid_strength", 100);
					blob.Init();
					blob.server_SetTimeToDie(30 + XORRandom(30));
				}
			}
		}
		
		this.Tag("dead");
		this.getSprite().Gib();
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire || customData == Hitters::burn)
	{
		if (isServer()) this.server_Die();
	}

	return damage;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (blob !is null ? !blob.isCollidable() : !solid) return;
		f32 vellen = this.getOldVelocity().Length();

		if (vellen > 3.0f)
		{
			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}
