void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();

	u16 netID = this.getNetworkID();
	sprite.animation.frame = (netID % sprite.animation.getFramesCount());
	sprite.SetFacingLeft(((netID % 13) % 2) == 0);
	sprite.SetZ(-5.0f);
	
	this.Tag("nature");
	// this.setPosition(this.getPosition() + Vec2f(0, 4));
}
