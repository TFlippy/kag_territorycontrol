// TFlippy

#include "Hitters.as";
#include "Explosion.as";
#include "ParticleSparks.as";
#include "MakeDustParticle.as";

const Vec2f[] dir =
{
	Vec2f(8, 0),
	Vec2f(-8, 0),
	Vec2f(0, 8),
	Vec2f(0, -8)
};

void onInit(CBlob@ this)
{
	this.getSprite().SetFrameIndex(XORRandom(4));
	
	this.Tag("ignore fall");
	this.Tag("shrapnel");

	this.getShape().getConsts().collideWhenAttached = false;
	// this.getShape().SetGravityScale(0.75f);
	
	this.server_SetTimeToDie(3 + XORRandom(5));
	this.getCurrentScript().tickFrequency = 3;
	
	this.set_u16("tick", 0);
}

void onTick(CBlob@ this)
{
	if (this.get_u16("tick") > 10 && this.getVelocity().x <= 0.5f && this.getVelocity().y <= 0.5f)
	{
		this.server_SetHealth(-1);
		this.server_Die();
	}

	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	
	u16 tick = this.add_u16("tick",1);
	if(isClient())
	{
		if (tick % 2 == 0) ParticleAnimated("Entities/Effects/Sprites/SmallSmoke1.png", pos + Vec2f(0, -4), Vec2f(0, 0.5f), 0.0f, 1.0f, 2, 0.0f, true);
	}
	

	TileType tile = map.getTile(pos).type;
	if (!map.isTileGround(tile) && !map.isTileGroundStuff(tile)) map.server_DestroyTile(pos, 1.0f);
	
	CBlob@[] blobs;
	map.getBlobsInRadius(pos, 4, @blobs);
	
	for (int i = 0; i < blobs.length; i++) if (blobs[i].hasTag("flesh")) this.server_Hit(blobs[i], pos, Vec2f_zero, 2.75f, Hitters::stab, true);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob != null && blob.hasTag("shrapnel")) return;
	
	CMap@ map = getMap();
	for (int i = 0; i < dir.length; i++)
	{
		TileType tile = map.getTile(this.getPosition() + dir[i]).type;
		if (!map.isTileGround(tile) && !map.isTileGroundStuff(tile)) map.server_DestroyTile(this.getPosition() + dir[i], 1.0f);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return false;
}