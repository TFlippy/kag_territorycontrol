#include "Hitters.as";
#include "Explosion.as";
//#include "LoaderUtilities.as";
#include "CustomBlocks.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(this.getNetworkID() % 2 == 0);
	this.getSprite().SetZ(-100.0f);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{

}

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("TreeDestruct.ogg", 1.0f, 1.0f);
	
	if (isServer())
	{
		for (int i = 0; i < (5 + XORRandom(15)); i++)
		{
			CBlob@ blob = server_CreateBlob(XORRandom(3) == 0 ? "mat_mithril" : "mat_matter", this.getTeamNum(), this.getPosition() - Vec2f(0, XORRandom(64)));
			blob.server_SetQuantity(5 + XORRandom(10));
			blob.setVelocity(Vec2f(XORRandom(4) - 2, -2 - XORRandom(3)));
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isClient())
	{ 
		this.getSprite().PlaySound("dig_stone.ogg", 0.8f, 1.2f);
		this.getSprite().PlaySound("TreeChop" + (1 + XORRandom(3)) + ".ogg", 1.0f, 1.0f);
	}
	
	if (isServer())
	{
		if (hitterBlob !is null)
		{
			MakeMat(hitterBlob, worldPoint, "mat_matter", 3 + XORRandom(15));	
			MakeMat(hitterBlob, worldPoint, "mat_wood", 2 + XORRandom(10));	
		}
	}
	
	return damage;
}
