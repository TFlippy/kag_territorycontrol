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
		for (int i = 0; i < (7 + XORRandom(7)); i++)
		{
			{
				CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition() - Vec2f(0, XORRandom(64)));
				blob.server_SetQuantity(5 + XORRandom(10));
				blob.setVelocity(Vec2f(XORRandom(4) - 2, -2 - XORRandom(3)));
			}
			{
				CBlob@ blob = server_CreateBlob("mat_matter", this.getTeamNum(), this.getPosition() - Vec2f(0, XORRandom(64)));
				blob.server_SetQuantity(35 + XORRandom(15));
				blob.setVelocity(Vec2f(XORRandom(4) - 2, -2 - XORRandom(3)));
			}
			{
				CBlob@ blob = server_CreateBlob("mat_wood", this.getTeamNum(), this.getPosition() - Vec2f(0, XORRandom(64)));
				blob.server_SetQuantity(15 + XORRandom(10));
				blob.setVelocity(Vec2f(XORRandom(4) - 2, -2 - XORRandom(3)));
			}
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
	
	return damage;
}
