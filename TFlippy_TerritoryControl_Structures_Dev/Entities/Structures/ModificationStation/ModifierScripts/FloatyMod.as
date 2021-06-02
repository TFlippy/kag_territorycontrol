
void onTick(CBlob@ this)
{
	Vec2f vel = this.getVelocity();
	if (vel.y > 0.5f)
	{
		this.AddForce(Vec2f(0, -0.4f) * this.getMass());
	}
}
