void onInit(CBlob@ this)
{
	this.Tag("smoke");
	this.Tag("gas");

	this.getShape().SetGravityScale(-0.1f);

	this.getSprite().SetZ(10.0f);

	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 5;

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	if (!this.exists("toxicity")) this.set_f32("toxicity", 0.50f);
	
	this.server_SetTimeToDie(6);
}

void onTick(CBlob@ this)
{
	if (isServer() && this.getPosition().y < 0) this.server_Die();

	MakeParticle(this);
}

void MakeParticle(CBlob@ this, const string filename = "LargeSmoke")
{
	if (!isClient() && !this.isOnScreen()) return;

	ParticleAnimated(filename, this.getPosition() + Vec2f(XORRandom(200) / 10.0f - 10.0f, XORRandom(200) / 10.0f - 10.0f), Vec2f(), float(XORRandom(360)), 1.0f + (XORRandom(50) / 100.0f), 3, 0.0f, false);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
   return blob.hasTag("smoke");
}
