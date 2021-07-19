// Swing Door logic

#include "Hitters.as"
#include "FireCommon.as"
#include "MapFlags.as"
#include "DoorCommon.as"

#include "CustomBlocks.as"
#include "MinableMatsCommon.as"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	//this.getShape().SetStatic(true);
	
	this.getSprite().getConsts().accurateLighting = true;

	this.set_s16(burn_duration , 300);
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);

	// this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 0;


	//block knight sword
	this.Tag("blocks sword");

	string name = this.getName();
	HarvestBlobMat[] mats = {};

	//HACK
	// for DefaultNoBuild.as
	if (name == "stone_door")
	{
		this.set_TileType("background tile", CMap::tile_castle_back);
		mats.push_back(HarvestBlobMat(25.0f, "mat_stone"));
	}
	else if (name == "iron_door")
	{
		this.set_TileType("background tile", CMap::tile_biron);
		mats.push_back(HarvestBlobMat(2.0f, "mat_ironingot"));
	}
	else if (name == "plasteel_door")
	{
		this.set_TileType("background tile", CMap::tile_bplasteel);
		mats.push_back(HarvestBlobMat(4.0f, "mat_plasteel"));
	}
	else if (name == "neutral_door")
	{
		this.set_TileType("background tile", CMap::tile_wood_back);
		this.server_setTeamNum(-1);
		mats.push_back(HarvestBlobMat(10.0f, "mat_wood"));
	}
	else
	{
		this.set_TileType("background tile", CMap::tile_wood_back);
		mats.push_back(HarvestBlobMat(10.0f, "mat_wood"));
	}

	this.set("minableMats", mats);


	this.Tag("door");
	this.Tag("blocks water");
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;
	this.getSprite().PlaySound("/build_door.ogg");
}

//TODO: fix flags sync and hitting
/*void onDie(CBlob@ this)
{
    SetSolidFlag(this, false);
}*/

bool isOpen(CBlob@ this)
{
	return !this.getShape().getConsts().collidable;
}

void setOpen(CBlob@ this, bool open, bool faceLeft = false)
{
	CSprite@ sprite = this.getSprite();
	if (open)
	{
		sprite.SetZ(-100.0f);
		sprite.SetAnimation("open");
		this.getShape().getConsts().collidable = false;
		this.getCurrentScript().tickFrequency = 3;
		sprite.SetFacingLeft(faceLeft);   // swing left or right
		Sound::Play("/DoorOpen.ogg", this.getPosition());
	}
	else
	{
		sprite.SetZ(100.0f);
		sprite.SetAnimation("close");
		this.getShape().getConsts().collidable = true;
		this.getCurrentScript().tickFrequency = 0;
		Sound::Play("/DoorClose.ogg", this.getPosition());
	}

	//TODO: fix flags sync and hitting
	//SetSolidFlag(this, !open);
}

void onTick(CBlob@ this)
{
	const uint count = this.getTouchingCount();
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob is null) continue;

		if (canOpenDoor(this, blob) && !isOpen(this))
		{
			Vec2f pos = this.getPosition();
			Vec2f other_pos = blob.getPosition();
			Vec2f direction = Vec2f(1, 0);
			direction.RotateBy(this.getAngleDegrees());
			setOpen(this, true, ((pos - other_pos) * direction) < 0.0f);
			break;
		}
	}
	// close it
	if (isOpen(this) && canClose(this))
	{
		setOpen(this, false);
	}
}


bool canClose(CBlob@ this)
{
	const uint count = this.getTouchingCount();
	uint collided = 0;
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob.isCollidable())
		{
			collided++;
		}
	}
	return collided == 0;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		this.getCurrentScript().tickFrequency = 3;
	}
}

void onEndCollision(CBlob@ this, CBlob@ blob)
{
	if (blob !is null)
	{
		if (canClose(this))
		{
			if (isOpen(this))
			{
				setOpen(this, false);
			}
			this.getCurrentScript().tickFrequency = 0;
		}
	}
}


bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

// this is such a pain - can't edit animations at the moment, so have to just carefully add destruction frames to the close animation >_>
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob.hasTag("neutral") && (this.getName() == "iron_door" || this.getName() == "plasteel_door"))
	{
		damage = 0;
	}

	if (customData == Hitters::boulder)
		return 0;

	if (customData == Hitters::builder)
		damage *= 2;
	if (customData == Hitters::saw)
		damage *= 2;
	if (customData == Hitters::bomb)
		damage *= 1.3f;

	return damage;
}

void onHealthChange( CBlob@ this, f32 oldHealth ) //Sprites now change on any health change not just getting hit, this means that healing doors actually returns their closing sprite to previous states
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		u8 frame = 0;

		Animation @destruction_anim = sprite.getAnimation("destruction");
		if (destruction_anim !is null && this.getHealth() < this.getInitialHealth())
		{
			f32 ratio = (this.getHealth() / this.getInitialHealth());


			if (ratio <= 0.0f)
			{
				frame = destruction_anim.getFramesCount() - 1;
			}
			else
			{
				frame = (1.0f - ratio) * (destruction_anim.getFramesCount());
			}

			frame = destruction_anim.getFrame(frame);
		}

		Animation @close_anim = sprite.getAnimation("close");
		u8 lastframe = close_anim.getFrame(close_anim.getFramesCount() - 1);
		if (lastframe < frame)
		{
			close_anim.RemoveFrame(lastframe);
			close_anim.AddFrame(frame);
		}
		else if (lastframe > frame)
		{
			close_anim.RemoveFrame(lastframe);
			close_anim.AddFrame(frame);
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (isOpen(this))
		return false;

	if (canOpenDoor(this, blob))
	{
		Vec2f pos = this.getPosition();
		Vec2f other_pos = blob.getPosition();
		Vec2f direction = Vec2f(1, 0);
		direction.RotateBy(this.getAngleDegrees());
		setOpen(this, true, ((pos - other_pos) * direction) < 0.0f);
		return false;
	}
	return true;
}
