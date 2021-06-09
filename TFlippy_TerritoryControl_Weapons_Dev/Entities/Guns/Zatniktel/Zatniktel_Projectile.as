#include "Hitters.as";
#include "HittersTC.as";
#include "Knocked.as"

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(0, 255, 255, 0));

	this.getShape().SetGravityScale(0.0f);
	this.getSprite().setRenderStyle(RenderStyle::additive);
}

void onTick(CBlob@ this)
{
	this.setAngleDegrees(-this.getVelocity().Angle() - 180);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum() && blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		if (doesCollideWithBlob(this, blob) && blob.hasTag("flesh"))
		{
			u8 counter = blob.get_u8("zat counter");

			//print("" + counter);

			switch (counter)
			{
				case 0:
					SetKnocked(blob, 150);
					this.getSprite().PlaySound("/Zatniktel_Hit.ogg", 0.5f, 1.0f);
					break;
				case 1:
					blob.Tag("dead");
					if (isServer()) this.server_Hit(blob, blob.getPosition(), Vec2f(), blob.getHealth() * 0.95f, HittersTC::magix);
					break;
				case 2:
				default:
					if (isServer()) blob.server_Die();
					break;
			}

			blob.set_u8("zat counter", blob.get_u8("zat counter") + 1);

			if (isServer()) this.server_Die();
		}
	}
	else if (isServer()) this.server_Die();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}
