void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		tcpr("[LOG] " + this.getName() + " has collided with " + (blob !is null ? blob.getName() : "World"));
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (isServer())
	{
		tcpr("[LOG] does " + this.getName() + " collide with " + (blob !is null ? blob.getName() : "World"));
	}
	return true;
}