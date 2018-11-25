#include "Hitters.as";
#include "Explosion.as";
//#include "LoaderUtilities.as";
#include "CustomBlocks.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(this.getNetworkID() % 2 == 0);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{

}

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("TreeDestruct.ogg", 1.0f, 1.0f);
	
	if (getNet().isServer())
	{
		for (int i = 0; i < (5 + XORRandom(5)); i++)
		{
			CBlob@ blob = server_CreateBlob("mat_wood", this.getTeamNum(), this.getPosition() - Vec2f(0, XORRandom(64)));
			blob.server_SetQuantity(5 + XORRandom(25));
			blob.setVelocity(Vec2f(XORRandom(4) - 2, -2 - XORRandom(3)));
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::burn || customData == Hitters::fire) damage *= 0.05f;

	if (getNet().isClient())
	{ 
		this.getSprite().PlaySound("TreeChop" + (1 + XORRandom(3)) + ".ogg", 1.0f, 1.0f);
	}
	
	if (getNet().isServer())
	{
		if (hitterBlob !is null)
		{
			MakeMat(hitterBlob, worldPoint, "mat_coal", 1 + XORRandom(3));	
			MakeMat(hitterBlob, worldPoint, "mat_wood", 3 + XORRandom(10));	
		}
	}
	
	return damage;
}