#include "Hitters.as";
#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);

	this.set_string("custom_explosion_sound", "bigbomb_explosion.ogg");
	this.set_f32("explosion_volume", 3.0f);
	this.set_bool("map_damage_raycast", true);
	this.set_Vec2f("explosion_offset", Vec2f(0, 16));

	this.set_u8("stack size", 1);
	this.set_f32("bomb angle", 90);

	this.Tag("map_damage_dirt");
	this.Tag("explosive");
	this.Tag("heavy weight");

	this.maxQuantity = 1;
}

void onDie(CBlob@ this)
{
	if (this.hasTag("DoExplode"))
	{
		DoExplosion(this);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage >= this.getHealth() && !this.hasTag("dead"))
	{
		this.Tag("DoExplode");
		this.set_f32("bomb angle", 90);
		this.server_Die();
	}

	return damage;
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob.hasTag("human") || inventoryBlob.getName() == "backpackblob")
	{
		if (inventoryBlob.isMyPlayer()) Sound::Play("NoAmmo");
		return false;
	}
	else return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null ? !blob.isCollidable() : !solid)
	{
		return;
	}

	f32 vellen = this.getOldVelocity().Length();
	if (vellen >= 12.0f) 
	{
		//Vec2f dir = Vec2f(-normal.x, normal.y);

		this.Tag("DoExplode");
		//this.set_f32("bomb angle", dir.Angle());
		this.server_Die();
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

	this.set_f32("map_damage_radius", 48.0f);
	this.set_f32("map_damage_ratio", 0.4f);
	f32 angle = this.getAngleDegrees() - this.get_f32("bomb angle");

	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		if (boom !is null)
		{
			boom.setPosition(this.getPosition());
			boom.set_u8("boom_start", 0);
			boom.set_u8("boom_end", 4);
			boom.set_u8("boom_frequency", 1);
			boom.set_u32("boom_delay", 0);
			boom.set_u32("flash_delay", 0);
			boom.set_string("custom_explosion_sound", "bigbomb_explosion.ogg");
			boom.Tag("no fallout");
			boom.Tag("no flash");
			boom.Tag("no mithril");
			boom.Tag("no side blast");
			boom.Tag("no sound");
			boom.Init();
		}
	}

	Explode(this, 50.0f + XORRandom(10), 15.0f);

	for (int i = 0; i < 4; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 40);
		LinearExplosion(this, dir, 8.0f + XORRandom(16), 8 + XORRandom(24), 3, 0.125f, Hitters::explosion);
	}
	if(!isClient()){return;}

	Vec2f pos = this.getPosition();
	CMap@ map = getMap();

	for (int i = 0; i < 80; i++)
	{
		MakeParticle(this, Vec2f( XORRandom(128) - 64, XORRandom(100) - 50), getRandomVelocity(angle, XORRandom(350) * 0.01f, 90), particles[XORRandom(particles.length)]);
	}

	this.getSprite().Gib();
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 1 + XORRandom(200) * 0.01f, 2 + XORRandom(5), XORRandom(100) * -0.00005f, true);
}
