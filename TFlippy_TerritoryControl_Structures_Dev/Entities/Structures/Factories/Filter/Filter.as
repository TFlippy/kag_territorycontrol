
#include "FilteringCommon.as";
#include "CustomBlocks.as";
#include "Hitters.as";
#include "MapFlags.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(50);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().waterPasses = true;
	
	this.Tag("place norotate");

	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	this.Tag("builder always hit");
	
	this.Tag("ignore blocking actors");
	this.Tag("conveyor");
	this.Tag("inline_block");
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;
	
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	
	if(isServer()){
		CMap@ map = getMap();
		if(map.getTile(this.getPosition()).type == 0)map.server_SetTile(this.getPosition(), CMap::tile_biron);
	}
	
	if(!this.hasTag("no_up"))this.setPosition(this.getPosition()-Vec2f(0,3.5));
	this.Tag("no_up");

	sprite.SetOffset(Vec2f(0,-0.5));
	sprite.SetZ(300);
	
	sprite.PlaySound("/build_door.ogg");
	
	CSpriteLayer@ Case = sprite.addSpriteLayer( "case","ConveyorBelt.png", 8, 1);
	if(Case !is null)
	{
		Case.addAnimation("default",1,true);
		int[] frames = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
		Case.animation.AddFrames(frames);
		Case.SetRelativeZ(1);
		Case.SetOffset(Vec2f(0,-1));
		Case.SetFrameIndex(getGameTime() % 16);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.isKeyPressed(key_down))return false;
	if(blob.hasTag("player")) return true;
	if(server_isItemAccepted(this, blob.getName()))return false;
	if(blob.getPosition().y > this.getPosition().y) return false;
	
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.hasTag("player")) return;
	if (blob.getPosition().y > this.getPosition().y) return;
	if (blob.getShape().isStatic() || blob.hasTag("building"))return;
	if (blob.isAttached() || blob.isInWater())return;
	
	if(server_isItemAccepted(this, blob.getName())){
		blob.setVelocity(Vec2f(0.0f, 0.0f));
		blob.setPosition(this.getPosition()+Vec2f(0,4));
		this.getSprite().PlaySound("bridge_open.ogg");
	} else {
		if (Maths::Abs(blob.getVelocity().y) < 2.0f){
			blob.setVelocity(Vec2f(this.isFacingLeft() ? -0.6f : 0.6f, -1.0f));
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	this.getSprite().SetZ(300);
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::builder) damage *= 30.0f;
	return damage;
}