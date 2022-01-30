// TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";
#include "MinableMatsCommon.as";

int openRecursion = 0;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	this.set_bool("open", false);
	this.Tag("place norotate");

	//block knight sword
	this.Tag("builder always hit");
	this.Tag("blocks sword");
	this.Tag("blocks water");

	this.set_TileType("background tile", CMap::tile_castle_back);

	MakeDamageFrame(this);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	CSprite@ sprite = this.getSprite();
	sprite.SetAnimation("forward");

	this.addCommandID("use");

	HarvestBlobMat[] mats = {};
	mats.push_back(HarvestBlobMat(5.0f, "mat_stone")); 
	mats.push_back(HarvestBlobMat(10.0f, "mat_wood"));
	this.set("minableMats", mats);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.getConsts().accurateLighting = true;

	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	if (!isOpen(this))
	{
		MakeDamageFrame(this);
	}
}

void MakeDamageFrame(CBlob@ this)
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ((hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}

bool isOpen(CBlob@ this)
{
	return !this.getShape().getConsts().collidable;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.hasTag("player")) return;
	if (blob.getPosition().y > this.getPosition().y) return;
	
	blob.setVelocity(Vec2f(this.isFacingLeft() ? -1 : 1, -6));
	
	if(isClient()) this.getSprite().PlaySound("/launcher_boing" + XORRandom(2) + ".ogg", 0.5f, 0.9f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (caller !is null && this.isOverlapping(caller) && (caller.getPosition() - this.getPosition()).Length() <= 64)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		int icon = 17;
		if (!this.isFacingLeft()) icon = 18;
		
		CButton@ button = caller.CreateGenericButton(icon, Vec2f(0,0), this, this.getCommandID("use"), "Use", params);
	}
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if (caller !is null)
	{
		if (cmd == this.getCommandID("use"))
		{
			this.SetFacingLeft(!this.isFacingLeft());
		}
	}
}