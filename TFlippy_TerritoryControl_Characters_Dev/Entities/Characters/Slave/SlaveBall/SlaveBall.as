// Minelogic

//for onhit stuff
#include "Hitters.as";

// const u32 PRIMING_TICKS = 45;

f32 maxDistance = 48.0f;

void onInit(CBlob@ this)
{
	this.Tag("medium weight");

	// this.getShape().getVars().waterDragScale = 16.0f;

	// this.set_f32("explosive_radius", 32.0f);
	// this.set_f32("explosive_damage", 7.5f);
	// this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
	// this.set_f32("map_damage_radius", 24.0f);
	// this.set_f32("map_damage_ratio", 0.5f);
	// this.set_bool("map_damage_raycast", true);
	// this.set_u32("priming ticks", 0);

	this.Tag("ignore fall");

	// this.getShape().getConsts().collideWhenAttached = true;

	// this.getCurrentScript().runFlags |= Script::tick_attached;
	// this.getCurrentScript().tickFrequency = 10;
	
	// if (XORRandom(100) > 50) this.Tag("dud");
	
	CSprite@ sprite = this.getSprite();
	
	sprite.RemoveSpriteLayer("chain");
	CSpriteLayer@ chain = sprite.addSpriteLayer("chain", "SlaveBall_Chain.png", 32, 2, this.getTeamNum(), 0);

	if (chain !is null)
	{
		Animation@ anim = chain.addAnimation("default", 0, false);
		anim.AddFrame(0);
		chain.SetRelativeZ(-10.0f);
		chain.SetVisible(false);
	}
}

void onTick(CBlob@ this)
{
	CBlob@ slave = getBlobByNetworkID(this.get_u16("slave_id"));
	
	if (slave !is null && slave.getName() == "slave")
	{		
		Vec2f dir = (this.getPosition() - slave.getPosition());
		f32 distance = dir.Length();
		dir.Normalize();
		
		if (distance > maxDistance) 
		{
			slave.setPosition(this.getPosition() - dir * maxDistance * 0.999f); 
			// slave.AddForce(dir * (distance / maxDistance) * 100);
			
			// slave.setVelocity(Vec2f(slave.getVelocity().x, 0));
			
			// print("gud");
			// slave.AddForce(dir * (distance / maxDistance) * 32);
			
			// if (isServer() && distance > maxDistance * 4) this.server_Hit(slave, slave.getPosition(), dir, (distance / maxDistance) * 0.1f, Hitters::crush, true);
		}
		
		if (isClient()) DrawLine(this.getSprite(), this.getPosition(), distance / 32, -dir.Angle(), true);
	}
	else
	{
		if (isServer()) this.server_Die();
		if (isClient()) this.getSprite().getSpriteLayer("chain").SetVisible(false);
	}
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getName() != "slave";
}

void DrawLine(CSprite@ this, Vec2f startPos, f32 length, f32 angle, bool flip)
{
	CSpriteLayer@ chain = this.getSpriteLayer("chain");
	
	chain.SetVisible(true);
	
	chain.ResetTransform();
	chain.ScaleBy(Vec2f(length, 1.0f));
	chain.TranslateBy(Vec2f(length * 16.0f, 0.0f));
	chain.RotateBy(angle + (flip ? 180 : 0), Vec2f());
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::builder:
			damage *= 0.2f;
			break;
	}

	return damage;

}

// void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
// {
	// this.set_u32("priming ticks", 0);
	// this.getCurrentScript().tickFrequency = 10;
	// this.getSprite().SetFrameIndex(0);
	// this.SetDamageOwnerPlayer(attached.getPlayer());
// }

// bool ExplodeOnContactWith(CBlob@ this, CBlob@ blob)
// {
	// //enemies									//non neutral enemies
	// return (this.getTeamNum() != blob.getTeamNum() && blob.getTeamNum() < 8) &&
	       // //really heavy stuff
	       // (blob.getMass() > 500.0f ||
	        // //vehicles
	        // blob.hasTag("vehicle") ||
	        // //projectiles
	        // blob.hasTag("projectile") ||
	        // //fleshy stuff
	        // blob.hasTag("flesh"));
// }

// bool ExtraCollideBlobs(CBlob@ blob)
// {
	// return blob.hasTag("door") ||
	       // blob.getName() == "wooden_platform";
// }

// bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
// {
	// return (ExtraCollideBlobs(blob) ||  //early out collide with doors
	        // this.getTeamNum() != blob.getTeamNum() &&
	        // !this.isAttachedTo(blob) &&
	        // ExplodeOnContactWith(this, blob));
// }

// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {

// }

// bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
// {
	// return (this.getTeamNum() == byBlob.getTeamNum());
// }

// //1hko damage from builders

// f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
// {
	// f32 dmg = damage;

	// switch (customData)
	// {
		// case Hitters::builder:
			// dmg = this.getHealth();
			// break;
	// }

	// return dmg;

// }