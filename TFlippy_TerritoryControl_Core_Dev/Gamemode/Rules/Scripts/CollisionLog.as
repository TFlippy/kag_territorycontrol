void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	print("" + this.getConfig() + " has collided with " + (blob !is null ? blob.getConfig() : "World"));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	print("does " + this.getConfig() + " collide with " + (blob !is null ? blob.getConfig() : "World"));
	return true;
}