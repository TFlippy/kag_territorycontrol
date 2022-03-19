
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(150);
	this.getShape().SetRotationsAllowed(false);
	
	this.Tag("place norotate");
	this.Tag("blocks sword");
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	this.Tag("builder always hit");
	this.Tag("ignore blocking actors");
	this.Tag("conveyor");
	this.Tag("pipe");
}

void onInit(CSprite @this){
	CSpriteLayer@ Case = this.addSpriteLayer( "case","Climber.png", 8,8 );
	if(Case !is null)
	{
		Case.addAnimation("default",0,false);
		int[] frames = {4};
		Case.animation.AddFrames(frames);
		Case.SetRelativeZ(200);
		Case.SetOffset(Vec2f(0,0));
	}
	this.SetFrameIndex(getGameTime() % 4);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;
	
	if(isServer()){
		CMap@ map = getMap();
		if(map.getTile(this.getPosition()).type == 0)map.server_SetTile(this.getPosition()+Vec2f(0,0), CMap::tile_wood_back);
	}
	
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.PlaySound("/build_door.ogg");
	sprite.SetZ(-50);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob is null) return false;
	//if (blob.getPosition().y > this.getPosition().y) return false;
	
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.hasTag("player")) return;
	if (blob.getPosition().y < this.getPosition().y-4) return;
	if (blob.getShape().isStatic())return;
	if (blob.isAttached())return;
	
	if(blob.getPosition().x > this.getPosition().x-1 && blob.getPosition().x < this.getPosition().x+1){
		blob.setVelocity(Vec2f(0.0f, -4.0f));
	} else {
		blob.setVelocity(Vec2f(0.0f, -4.0f));
		blob.setPosition(Vec2f(this.getPosition().x,blob.getPosition().y));
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::builder) damage *= 30.0f;
	return damage;
}