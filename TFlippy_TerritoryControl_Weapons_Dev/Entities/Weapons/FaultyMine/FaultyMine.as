// Minelogic

//for onhit stuff
#include "Hitters.as";

const u32 PRIMING_TICKS = 45;

void onInit(CBlob@ this)
{
	this.getShape().getVars().waterDragScale = 16.0f;

	this.set_f32("explosive_radius", 32.0f);
	this.set_f32("explosive_damage", 7.5f);
	this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
	this.set_f32("map_damage_radius", 24.0f);
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_bool("map_damage_raycast", true);
	this.set_u32("priming ticks", 0);

	this.Tag("ignore fall");

	this.getShape().getConsts().collideWhenAttached = true;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 10;
	
	if (XORRandom(100) > 50) this.Tag("dud");
}

void onTick(CBlob@ this)
{
	//if (this.isOnGround() || this.isInWater())
	{
		u32 ticks = this.get_u32("priming ticks");
		u32 add = this.getCurrentScript().tickFrequency;
		this.set_u32("priming ticks", ticks + add);
		if (ticks + add >= PRIMING_TICKS)
		{
			this.getShape().checkCollisionsAgain = true;
			this.getCurrentScript().tickFrequency = 0;
			this.getSprite().PlaySound("/MineArmed.ogg");
			this.getSprite().SetFrameIndex(1);
		}
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.set_u32("priming ticks", 0);
	this.getCurrentScript().tickFrequency = 10;
	this.getSprite().SetFrameIndex(0);
	this.SetDamageOwnerPlayer(attached.getPlayer());
}

bool ExplodeOnContactWith(CBlob@ this, CBlob@ blob)
{
	//enemies									//non neutral enemies
	return (this.getTeamNum() != blob.getTeamNum() && blob.getTeamNum() < 8) &&
	       //really heavy stuff
	       (blob.getMass() > 500.0f ||
	        //vehicles
	        blob.hasTag("vehicle") ||
	        //projectiles
	        blob.hasTag("projectile") ||
	        //fleshy stuff
	        blob.hasTag("flesh"));
}

bool ExtraCollideBlobs(CBlob@ blob)
{
	return blob.hasTag("door") ||
	       blob.getName() == "wooden_platform";
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (ExtraCollideBlobs(blob) ||  //early out collide with doors
	        this.getTeamNum() != blob.getTeamNum() &&
	        !this.isAttachedTo(blob) &&
	        ExplodeOnContactWith(this, blob));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && ExplodeOnContactWith(this, blob) &&
	        this.get_u32("priming ticks") >= PRIMING_TICKS)
	{
		if(!this.hasTag("dud"))Boom(this);
		else this.server_Die();
	}
}

void Boom(CBlob@ this)
{
	this.Tag("exploding");
	this.server_SetHealth(-1.0f);
	this.server_Die();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return (this.getTeamNum() == byBlob.getTeamNum());
}

//1hko damage from builders

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;

	switch (customData)
	{
		case Hitters::builder:
			dmg = this.getHealth();
			break;
	}

	return dmg;

}

void onThisAddToInventory(CBlob@ this, CBlob@ carrier)
{
	if (carrier !is null && carrier.getPlayer() !is null)
		this.SetDamageOwnerPlayer(carrier.getPlayer());
}
