#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 8;
	this.server_SetTimeToDie(5);
	this.set_bool("map_damage_raycast", true);
	
	this.Tag("projectile");
	
	this.Tag("map_damage_dirt");
	
	this.getSprite().PlaySound("grenade_pinpull.ogg");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable();
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}

	if (this.hasTag("exploded")) return;

	f32 random = XORRandom(32);
	f32 modifier = 1;
	f32 angle = -this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (64.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.10f);
	
	Explode(this, 48.0f + random, 5.0f);
	
	if (isServer())
	{
		for (int i = 0; i < 4 * modifier; i++) 
		{
			Vec2f dir = getRandomVelocity(angle, 1, 120);
			dir.x *= 2;
			dir.Normalize();
			
			LinearExplosion(this, dir, 1.0f + XORRandom(16) + (modifier * 4), 16 + XORRandom(24), 2, 0.10f, Hitters::explosion);

			CBlob @blob = server_CreateBlob("shrapnel", this.getTeamNum(), this.getPosition()); // + Vec2f(16 - XORRandom(32), -10));
			blob.setVelocity(Vec2f(10-XORRandom(20), -XORRandom(15)));
			blob.SetDamageOwnerPlayer(this.getDamageOwnerPlayer()); 
		}
	}
	
	if (isClient())
	{

	
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		this.Tag("exploded");
		this.getSprite().Gib();
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}