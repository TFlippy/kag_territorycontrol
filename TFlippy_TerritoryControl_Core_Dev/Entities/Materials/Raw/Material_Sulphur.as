#include "Hitters.as";
#include "Explosion.as";

string[] particles = 
{
	"LargeFire.png",
	"SmallFire1.png",
	"SmallFire2.png",
	"SmallExplosion1.png",
	"SmallExplosion2.png",
	"SmallExplosion3.png"
};

void onInit(CBlob@ this)
{
	this.maxQuantity = 1500;
	
	this.set_bool("map_damage_raycast", true);
	this.set_Vec2f("explosion_offset", Vec2f(0, 0));
	this.set_f32("bomb angle", 90);
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}
	
	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = this.get_f32("bomb angle");

	this.set_f32("map_damage_radius", (40.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);

	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
		
	if (isServer())
	{
		CBlob@[] blobs;
		
		if (map.getBlobsInRadius(pos, 8.0f * modifier, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{		
				CBlob@ blob = blobs[i];
				if (blob !is null) 
				{
					map.server_setFireWorldspace(blob.getPosition(), true);
					blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), modifier * 0.5f, Hitters::fire);
				}
			}
		}
	}	
	
	//print("" + modifier);
	
	if (isClient())
	{
		this.getSprite().PlaySound("Sulphur_Explode.ogg", 1.00f, 1.00f);
	
		for (int i = 0; i < 15 * modifier; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(16) - 8, XORRandom(16) - 8), particles[XORRandom(particles.length)]);
		}
	}
	
	this.getSprite().Gib();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire || customData == Hitters::burn || customData == Hitters::bomb || customData == Hitters::explosion || customData == Hitters::keg)
	{
		this.Tag("DoExplode");
		if (isServer()) this.server_Die();
	}

	return damage;
}

void onDie(CBlob@ this)
{
	if (this.hasTag("DoExplode"))
	{
		DoExplosion(this);
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, Vec2f(XORRandom(4) - 2, -XORRandom(8) - 2), float(XORRandom(360)), 1.0f, 4 + XORRandom(8), XORRandom(100) * 0.01f, true);
}