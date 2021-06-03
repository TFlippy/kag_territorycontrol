
void onTick(CBlob@ this)
{
	Vec2f vel = this.getVelocity();
	if (!this.isOnGround() && vel.Length() > 0.5f)
	{
		vel.Normalize();
		this.AddForce(vel * this.getMass() * 0.2f);
	}
}
