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
		for (int i = 0; i < (5 + XORRandom(5)); i++)
		{
			CBlob@ blob = server_CreateBlob("mat_wood", this.getTeamNum(), this.getPosition() - Vec2f(0, XORRandom(64)));
			blob.server_SetQuantity(1 + XORRandom(4));
			blob.setVelocity(Vec2f(XORRandom(4) - 2, -2 - XORRandom(3)));
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
	
	if (isServer())
	{
		if (hitterBlob !is null)
		{
			if(hitterBlob.getName() != "acidgas")//way too stronk and ends up nuking the server with mat_coal
			{
				MakeMat(hitterBlob, worldPoint, "mat_coal", 1 + XORRandom(3));
				MakeMat(hitterBlob, worldPoint, "mat_wood", 3 + XORRandom(10));	
			}
		}
	}
	
	return damage;
}
