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

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("TreeDestruct.ogg", 1.0f, 1.0f);
	
	if (isServer())
	{
		for (int i = 0; i < 5; i++)
		{
			{
				CBlob@ blob = server_CreateBlob("mat_wood", this.getTeamNum(), this.getPosition() - Vec2f(0, XORRandom(64)));
				blob.server_SetQuantity(30 + XORRandom(50));
				blob.setVelocity(Vec2f(XORRandom(4) - 2, -2 - XORRandom(3)));
			}
			{
				CBlob@ blob = server_CreateBlob("mat_coal", this.getTeamNum(), this.getPosition() - Vec2f(0, XORRandom(64)));
				blob.server_SetQuantity(10 + XORRandom(10));
				blob.setVelocity(Vec2f(XORRandom(4) - 2, -2 - XORRandom(3)));
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::burn || customData == Hitters::fire) damage *= 0.05f;

	if (isClient())
	{ 
		this.getSprite().PlaySound("TreeChop" + (1 + XORRandom(3)) + ".ogg", 1.0f, 1.0f);
	}
	
	return damage;
}
