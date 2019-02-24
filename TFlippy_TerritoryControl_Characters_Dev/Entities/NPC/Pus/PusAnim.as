void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead"))
	{
		this.SetAnimation("dead");
		return;
	}
	
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	
	if (!blob.isOnGround())
	{
		this.SetAnimation("air");
		
		if (getGameTime() > blob.get_u32("nextScream"))
		{
			this.PlaySound("Pus_Pissed_" + XORRandom(2) + ".ogg", 4, 1.0f);
			blob.set_u32("nextScream", getGameTime() + 150);
		}
	}
	else if (right || left)
	{
		this.SetAnimation("walk");
	}
	else this.SetAnimation("idle");
}