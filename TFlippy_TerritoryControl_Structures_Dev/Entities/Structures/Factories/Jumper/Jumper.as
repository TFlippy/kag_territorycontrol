
#include "FilteringCommon.as";

void onInit(CBlob@ this){
	this.Untag("whitelist");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.hasTag("player")) return;
	if (blob.getPosition().y > this.getPosition().y) return;
	if (blob.getShape().isStatic())return;
	if (blob.isAttached() || blob.isInWater())return;
	if (!server_isItemAccepted(this, blob.getName()))return;
	
	if (Maths::Abs(blob.getVelocity().y) < 2.0f){
		if(blob.getPosition().x > this.getPosition().x-1 && blob.getPosition().x < this.getPosition().x+1){
			blob.setVelocity(Vec2f(0.0f, -8.0f));
		} else {
			blob.setVelocity(Vec2f(0.0f, -8.0f));
			blob.setPosition(Vec2f(this.getPosition().x,blob.getPosition().y));
		}
		if(isClient()) 
		if(this.getSprite() !is null){
			this.getSprite().SetAnimation("jump");
			this.getSprite().SetFrameIndex(0);
			this.getSprite().PlaySound("/launcher_boing" + XORRandom(2) + ".ogg", 0.5f, 0.9f);
		}
	}
}


