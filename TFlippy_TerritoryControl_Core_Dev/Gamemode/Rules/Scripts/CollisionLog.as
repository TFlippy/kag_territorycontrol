void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		tcpr("[BOC] " + this.getName() + " has collided with " + (blob !is null ? blob.getName() : "World"));
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (isServer())
	{
		tcpr("[BDC] does " + this.getName() + " collide with " + (blob !is null ? blob.getName() : "World"));
	}
	return true;
}