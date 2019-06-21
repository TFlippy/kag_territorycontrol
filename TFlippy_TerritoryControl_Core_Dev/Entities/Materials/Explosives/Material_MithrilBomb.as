#include "Hitters.as";
#include "Explosion.as";
//#include "LoaderUtilities.as";
#include "CustomBlocks.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png",
	"LargeFire.png",
	"FireFlash.png",
};

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	
	this.set_string("custom_explosion_sound", "MithrilBomb_Explode.ogg");
	this.set_bool("map_damage_raycast", true);
	this.set_Vec2f("explosion_offset", Vec2f(0, 0));
	
	this.set_u8("stack size", 1);
	this.set_f32("bomb angle", 90);
	
	this.Tag("map_damage_dirt");
	this.Tag("explosive");
	
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

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null ? !blob.isCollidable() : !solid)
	{
		return;
	}

	f32 vellen = this.getOldVelocity().Length();
	if (vellen >= 8.0f) 
	{
		Vec2f dir = Vec2f(-normal.x, normal.y);
		
		this.Tag("DoExplode");
		this.set_f32("bomb angle", dir.Angle());
		this.server_Die();
	}
}

void DoExplosion(CBlob@ this)
{
	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	f32 vellen = this.getVelocity().Length();
	
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (64.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);
	
	Explode(this, 64.0f + random, 150.0f);

	for (int i = 0; i < 16 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 80);
		LinearExplosion(this, dir, (16.0f + XORRandom(32) + (modifier * 8)) * vellen, 12 + XORRandom(8), 20 + XORRandom(vellen * 2), 50.0f, Hitters::explosion);
	}
	
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	
	if (getNet().isServer())
	{
		for (int i = 0; i < 24; i++)
		{
			CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(25 + XORRandom(80));
			blob.setVelocity(Vec2f(4 - XORRandom(8), -2 - XORRandom(5)) * (0.5f));
		}
		
		for (int i = 0; i < 256; i++)
		{
			Vec2f tpos = getRandomVelocity(angle, 1, 120) * XORRandom(128);
			if (map.isTileSolid(pos + tpos)) map.server_SetTile(pos + tpos, CMap::tile_matter);
		}
		
		CBlob@[] trees;
		this.getMap().getBlobsInRadius(this.getPosition(), 192.0f, @trees);
		
		for (int i = 0; i < trees.length; i++)
		{
			CBlob@ b = trees[i];
			
			if (b.getConfig() == "tree_bushy" || b.getConfig() == "tree_pine")
			{
				CBlob@ tree = server_CreateBlob("crystaltree", b.getTeamNum(), b.getPosition() + Vec2f(0, -32));
					
				b.Tag("no drop");
				b.server_Die();
			}
		}
	}
	else
	{
		for (int i = 0; i < 60; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(500) * 0.01f, 25), particles[XORRandom(particles.length)]);
		}
	
		SetScreenFlash(50, 255, 255, 255);
		this.getSprite().Gib();
	}
	
	
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + pos, vel, float(XORRandom(360)), 1.8f + XORRandom(100) * 0.01f, 2 + XORRandom(6), XORRandom(100) * -0.00005f, true);
}