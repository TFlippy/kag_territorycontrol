#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");
	this.Tag("aerial");

	// this.set_f32("map_damage_ratio", 0.5f);
	// this.set_f32("map_damage_radius", 48.0f);
	// this.set_string("custom_explosion_sound", "MithrilBomb_Explode_old.ogg");
		
	// this.set_Vec2f("velocity", Vec2f(0, 0));
	
	this.getShape().SetRotationsAllowed(true);
	this.Tag("allow guns");
	
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ back = sprite.addSpriteLayer("back", sprite.getFilename(), 24, 16);
	if (back !is null)
	{
		back.SetRelativeZ(-1.0f);
		back.SetOffset(Vec2f(0, 0));
		back.SetFrameIndex(1);
	}
	
	AttachmentPoint@ pilot = this.getAttachments().getAttachmentPointByName("PILOT");
	if (pilot !is null)
	{
		pilot.SetKeysToTake(key_left | key_right | key_up | key_down);
		// pilot.SetMouseTaken(true);
	}
	
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.1f);
	
	sprite.SetEmitSound("HoverBike_Loop.ogg");
	sprite.SetEmitSoundVolume(1.25f);
	sprite.SetEmitSoundPaused(false);
}

void onTick(CSprite@ this)
{
	this.SetZ(0.0f);
	
	CSpriteLayer@ back = this.getSpriteLayer("back");
	if (back !is null)
	{	
		back.SetRelativeZ(-20);
	}
	
	CBlob@ blob = this.getBlob();
	blob.setAngleDegrees((10 * (blob.isFacingLeft() ? 1 : -1)) + (blob.getVelocity().x * 2.00f));
	
	this.SetEmitSoundVolume(1.25f);
	this.SetEmitSoundSpeed(0.50f + (Maths::Clamp(blob.getVelocity().getLength() / 15.00f, 0.00f, 1.00f) * 2.00f));
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ seat = this.getAttachments().getAttachmentPointByName("PILOT");
	if (seat !is null)
	{
		CBlob@ pilot = seat.getOccupied();
		if (pilot !is null)
		{
			const bool left = seat.isKeyPressed(key_left);
			const bool right = seat.isKeyPressed(key_right);
			const bool up = seat.isKeyPressed(key_up);
			const bool down = seat.isKeyPressed(key_down);

			f32 h = (left ? -1 : 0) + (right ? 1 : 0); 
			f32 v = (up ? -1 : 0) + (down ? 1 : 0); 
			
			Vec2f vel = Vec2f(h, v);
			
			if (this.exists("gyromat_acceleration"))
			{
				vel *= Maths::Sqrt(this.get_f32("gyromat_acceleration"));
			}

			this.AddForce(vel * this.getMass() * 0.50f);
			this.SetFacingLeft(pilot.getAimPos().x < this.getPosition().x);
			
			// print("vel: " + this.getVelocity().Length());
		}
	}
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		boom.setPosition(this.getPosition());
		boom.set_u8("boom_start", 0);
		boom.set_u8("boom_end", 2);
		boom.set_f32("mithril_amount", 10);
		boom.set_f32("flash_distance", 256);
		boom.set_u32("boom_delay", 0);
		boom.set_u32("flash_delay", 5);
		boom.Tag("no fallout");
		// boom.Tag("no flash");
		boom.Init();
	}
	
	this.getSprite().Gib();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (blob !is null ? !blob.isCollidable() : !solid) return;

		f32 vellen = this.getOldVelocity().Length();

		if (vellen > 5.0f)
		{
			this.server_Hit(this, this.getPosition(), this.getOldVelocity(), vellen * 0.10f, Hitters::fall, true);
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
	if (point is null) return true;
		
	CBlob@ holder = point.getOccupied();
	if (holder is null) return true;
	else return false;
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}





			
