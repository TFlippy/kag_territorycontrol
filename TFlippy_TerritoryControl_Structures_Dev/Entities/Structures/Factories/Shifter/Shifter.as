#include "MinableMatsCommon.as";

void onInit(CBlob @ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getShape().SetRotationsAllowed(false);

	this.Tag("builder always hit");

	//Starts offline
	this.set_u32("rechargedTime", getGameTime() + RECHARGETIME);
	CSprite@ sprite = this.getSprite();
	sprite.SetAnimation("off"); 
	sprite.SetZ(-100.0f);

	HarvestBlobMat[] mats = {};
	mats.push_back(HarvestBlobMat(5.0f, "mat_stone")); 
	mats.push_back(HarvestBlobMat(10.0f, "mat_wood")); 
	mats.push_back(HarvestBlobMat(1.0f, "mat_copperwire"));
	this.set("minableMats", mats);
}

const u32 RECHARGETIME = 120; //how many ticks till the shifter can activate again

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (getGameTime() >= blob.get_u32("rechargedTime"))
	{
		this.SetAnimation("on");
		this.SetZ(-100.0f);
	}
	else
	{
		this.SetAnimation("off");
		this.SetZ(-100.0f);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (getGameTime() >= this.get_u32("rechargedTime"))
	{
		this.set_u32("rechargedTime", getGameTime() + RECHARGETIME);
		move(this, blob);
	}
}

void move(CBlob@ this, CBlob@ blob)
{
	//print("moved by shifter");
	f32 angle = this.getAngleDegrees();
	Vec2f dir = Vec2f(1.0f, 0.0f).RotateBy(angle + (this.isFacingLeft() ? 180 : 0));
	if (blob != null)
	{
		Vec2f vecVel = blob.getVelocity();
		if (blob.hasTag("explosive"))
		{
			f32 vel = vecVel.Length();
			blob.AddForce(dir * 3 * Maths::Min(70, blob.getMass()) / Maths::Pow(Maths::Max(vel, 1), 0.90f)); 
		}
		else
		{
			Vec2f convertedVel = Vec2f(Maths::Max(0, vecVel.x * dir.x), Maths::Max(0, vecVel.y * dir.y)); //Dont devide by velocity if velocity is going against this (Slows down non explosives easily)
			f32 vel = convertedVel.Length();
			blob.AddForce(dir * 3 * Maths::Min(70, blob.getMass()) / Maths::Pow(Maths::Max(vel, 1), 0.70f)); 
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}