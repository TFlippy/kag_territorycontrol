void onInit(CSprite@ this)
{
	Animation@ anim = this.addAnimation("default", 3, true );
	anim.AddFrame(0);
	anim.AddFrame(1);
	anim.AddFrame(2);
	
	this.SetFrameIndex(XORRandom(3));
}