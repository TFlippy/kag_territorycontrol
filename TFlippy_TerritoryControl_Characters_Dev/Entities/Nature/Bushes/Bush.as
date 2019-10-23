// Bush logic

#include "canGrow.as";

void onInit(CBlob@ this)
{
	this.set_bool("grown", true);
	this.Tag("nature");
}

//sprite

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	u16 netID = blob.getNetworkID();
	this.animation.frame = (netID % this.animation.getFramesCount());
	this.SetFacingLeft(((netID % 13) % 2) == 0);
	this.SetZ(10.0f);
}

// #include "MakeSeed.as";
// #include "MakeMat.as";

// void onDie(CBlob@ this)
// {
	// if (isServer())
	// {
		// for (int i = 0; i <= 1; i++)
		// {
			// CBlob@ seed = server_MakeSeed(this.getPosition() + Vec2f(0, -12),"bush");
			// if (seed !is null)
			// {
				// seed.setVelocity(Vec2f(XORRandom(5) - 2.5f, XORRandom(5) - 2.5f));
			// }
		// }
		// // MakeMat(this, this.getPosition(), "mat_hemp", XORRandom(2)+5);
	// }
// }