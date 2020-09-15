void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	tcpr("[LOG] " + this.getName() + " has collided with " + (blob !is null ? blob.getName() : "World"));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	tcpr("[LOG] does " + this.getName() + " collide with " + (blob !is null ? blob.getName() : "World"));
	return true;
}