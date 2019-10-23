
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point)
{
	if (isServer() && solid && !this.getShape().isStatic() && !this.isAttached())
	{
		if (this.getOldVelocity().y < 1.0f && !this.hasTag("can settle"))
		{
			this.server_Die();
		}
		else
		{
			this.server_Hit(this, this.getPosition(), this.getVelocity() * -1.0f, 10.0f, 0);
		}
	}
}
