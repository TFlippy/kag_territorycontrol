void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	print("" + this.getName() + " has collided with " + (blob !is null ? blob.getName() : "World"));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	print("does " + this.getName() + " collide with " + (blob !is null ? blob.getName() : "World"));
	return true;
}