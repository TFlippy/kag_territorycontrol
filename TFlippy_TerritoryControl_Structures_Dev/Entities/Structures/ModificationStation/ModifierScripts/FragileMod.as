
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null ? !blob.isCollidable() : !solid)
	{
		return;
	}

	f32 vellen = this.getOldVelocity().Length();
	//print(" "+vellen);
	if (vellen >= 8.0f) //Dies when colliding with too much velocity
	{
		this.Tag("DoExplode"); //Can explode in case this is a bomb
		this.server_Die();
	}
}
