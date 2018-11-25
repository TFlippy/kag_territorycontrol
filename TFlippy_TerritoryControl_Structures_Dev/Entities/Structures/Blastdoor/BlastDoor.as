// Swing Door logic

#include "Hitters.as"
#include "FireCommon.as"
#include "MapFlags.as"
#include "DoorCommon.as"

#include "CustomBlocks.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().getConsts().accurateLighting = true;
	
	this.Tag("blocks sword");
	this.Tag("door");
	this.Tag("blocks water");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("security_set_state"))
	{
		bool state = params.read_bool();
		this.set_bool("security_state", state);
		
		this.getSprite().PlaySound(state ? "Security_TurnOn" : "Security_TurnOff", 0.30f, 1.00f);
		setOpen(this, state);
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;
	
	Vec2f pos = this.getPosition();
	u32 ang = u32(this.getAngleDegrees() / 90.00f) % 2;
	
	CMap@ map = this.getMap();

	for (int i = 0; i < 5; i++)
	{
		if (ang == 0) map.server_SetTile(Vec2f(pos.x, (pos.y - 16) + i * 8), CMap::tile_biron);
		else map.server_SetTile(Vec2f((pos.x - 16) + i * 8, pos.y), CMap::tile_biron);
	}
	
	this.getSprite().PlaySound("/build_door.ogg");
}

bool isOpen(CBlob@ this)
{
	return !this.getShape().getConsts().collidable;
}

void setOpen(CBlob@ this, bool open)
{
	CSprite@ sprite = this.getSprite();
	if (open)
	{
		sprite.SetZ(-100.0f);
		sprite.SetAnimation("open");
		this.getShape().getConsts().collidable = false;
		this.getCurrentScript().tickFrequency = 3;
		
		this.getSprite().PlaySound("/Blastdoor_Buzzer.ogg", 1.00f, 1.00f);
		// this.getSprite().PlaySound("/Blastdoor_Open.ogg", 1.00f, 1.00f);
	}
	else
	{
		sprite.SetZ(100.0f);
		sprite.SetAnimation("close");
		this.getShape().getConsts().collidable = true;
		this.getCurrentScript().tickFrequency = 0;
		Sound::Play("/Blastdoor_Buzzer.ogg", this.getPosition(), 1.00f, 0.80f);
	}
	
	const uint count = this.getTouchingCount();
	uint collided = 0;
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob.isCollidable())
		{
			blob.AddForce(Vec2f(0, 0)); // Hack to awake sleeping blobs' physics
		}
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

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::boulder || hitterBlob.hasTag("neutral")) return 0;
	else if (customData == Hitters::builder) damage *= 2;
	else if (customData == Hitters::saw) damage *= 2;
	else if (customData == Hitters::bomb) damage *= 1.3f;
	else if (customData == Hitters::flying) damage *= 0.10f;

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		u8 frame = 0;

		Animation @destruction_anim = sprite.getAnimation("destruction");
		if (destruction_anim !is null)
		{
			if (this.getHealth() < this.getInitialHealth())
			{
				f32 ratio = (this.getHealth() - damage * getRules().attackdamage_modifier) / this.getInitialHealth();


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
		}

		Animation @close_anim = sprite.getAnimation("close");
		u8 lastframe = close_anim.getFrame(close_anim.getFramesCount() - 1);
		if (lastframe < frame)
		{
			close_anim.AddFrame(frame);
		}
	}

	return damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !isOpen(this);
}