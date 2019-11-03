// Mine.as

#include "Hitters.as";
#include "Explosion.as";

const u8 MINE_PRIMING_TIME = 1;

const string MINE_STATE = "mine_state";
const string MINE_TIMER = "mine_timer";
const string MINE_PRIMING = "mine_priming";
const string MINE_PRIMED = "mine_primed";

enum State
{
	NONE = 0,
	PRIMED
};

void onInit(CBlob@ this)
{
	this.getShape().getVars().waterDragScale = 16.0f;

	this.set_f32("explosive_radius", 32.0f);
	this.set_f32("explosive_damage", 10.0f);
	this.set_f32("map_damage_radius", 48.0f);
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "KegExplosion.ogg");
	this.set_u8("custom_hitter", Hitters::mine);

	this.Tag("ignore fall");

	this.Tag(MINE_PRIMING);

	this.set_u8(MINE_STATE, NONE);
	this.set_u8(MINE_TIMER, 0);
	this.addCommandID(MINE_PRIMED);

	this.getCurrentScript().tickIfTag = MINE_PRIMING;
}

void onTick(CBlob@ this)
{
	if(this.hasTag("collided"))
	{
		CShape@ shape = this.getShape();

		//no collision
		shape.getConsts().collidable = false;

		if (!this.hasTag("_collisions"))
		{
			this.Tag("_collisions");

			// make everyone recheck their collisions with me
			const uint count = this.getTouchingCount();
			for (uint step = 0; step < count; ++step)
			{
				CBlob@ _blob = this.getTouchingByIndex(step);
				_blob.getShape().checkCollisionsAgain = true;
			}
		}

		this.setVelocity(Vec2f(0, 0));
		this.setPosition(this.get_Vec2f("lock"));
		shape.SetStatic(true);

		if(isServer())
		{
			u8 timer = this.get_u8(MINE_TIMER);
			timer++;
			this.set_u8(MINE_TIMER, timer);

			if(timer >= MINE_PRIMING_TIME)
			{
				this.Untag(MINE_PRIMING);
				this.SendCommand(this.getCommandID(MINE_PRIMED));
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID(MINE_PRIMED))
	{
		this.set_u8(MINE_STATE, PRIMED);
		this.getShape().checkCollisionsAgain = true;

		CSprite@ sprite = this.getSprite();
		if(sprite !is null)
		{
			sprite.SetFrameIndex(1);
			sprite.PlaySound("MineArmed.ogg");
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	this.Untag(MINE_PRIMING);
	this.Untag("collided");

	CShape@ shape = this.getShape();
	shape.getConsts().collidable = true;
	shape.SetStatic(false);

	if(this.get_u8(MINE_STATE) == PRIMED)
	{
		this.set_u8(MINE_STATE, NONE);
		this.getSprite().SetFrameIndex(0);
	}

	if(this.getDamageOwnerPlayer() is null)
	{
		CPlayer@ player = attached.getPlayer();
		if(player !is null)
		{
			this.SetDamageOwnerPlayer(player);
		}
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.Untag(MINE_PRIMING);

	if(this.get_u8(MINE_STATE) == PRIMED)
	{
		this.set_u8(MINE_STATE, NONE);
		this.getSprite().SetFrameIndex(0);
	}

	if(this.getDamageOwnerPlayer() is null)
	{
		CPlayer@ player = inventoryBlob.getPlayer();
		if(player !is null)
		{
			this.SetDamageOwnerPlayer(player);
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if(isServer())
	{
		this.Tag(MINE_PRIMING);
		this.set_u8(MINE_TIMER, 0);
	}
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if(isServer() && !this.isAttached())
	{
		this.Tag(MINE_PRIMING);
		this.set_u8(MINE_TIMER, 0);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(!this.isAttached() && (blob is null || doesCollideWithBlob(this, blob))) // hit map
	{
		f32 radius = this.getRadius();

		Vec2f norm = this.getOldVelocity();
		norm.Normalize();
		norm *= (1.5f * radius);
		Vec2f lock = point1 - norm;
		this.set_Vec2f("lock", lock);

		this.Sync("lock", true);

		this.setVelocity(Vec2f(0, 0));
		this.setPosition(lock);
		this.Tag("collided");
	}
}

void onDie(CBlob@ this)
{
	if(isServer() && this.hasTag("exploding"))
	{
		const Vec2f POSITION = this.getPosition();

		CBlob@[] blobs;
		getMap().getBlobsInRadius(POSITION, this.getRadius() + 4, @blobs);
		for(u16 i = 0; i < blobs.length; i++)
		{
			CBlob@ target = blobs[i];
			if(target.hasTag("flesh") &&
			(target.getTeamNum() != this.getTeamNum() || target.getPlayer() is this.getDamageOwnerPlayer()))
			{
				this.server_Hit(target, POSITION, Vec2f_zero, 8.0f, Hitters::mine_special, true);
			}
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() == blob.getTeamNum() || !this.hasTag("collided");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return damage;
}
