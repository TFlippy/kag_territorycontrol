
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob !is this && this.hasTag("invincible"))
	{
		return 0.0f;
	}

	// could be this.getHealth() -= damage; but we need to modify this value by Rules::attackdamage_modifier
	// to help with this we call this helper function, which also sets the hitter
	this.Damage(damage, hitterBlob);
	// set the destruction frames if available

	if (this.getHealth() <= 0.0f)
	{
		this.server_Die();
	}

	return 0.0f;
}

void onHealthChange( CBlob@ this, f32 oldHealth ) //Sprites now change on any health change not just getting hit, this means that healing ladders actually returns their sprite to previous states
{
	CSprite @sprite = this.getSprite();

	if (sprite !is null)
	{
		Animation @destruction_anim = sprite.getAnimation("destruction");

		if (destruction_anim !is null)
		{
			if (this.getHealth() < this.getInitialHealth())
			{
				sprite.SetAnimation(destruction_anim);
				f32 ratio = this.getHealth() / this.getInitialHealth();

				if (ratio <= 0.0f)
				{
					sprite.animation.frame = sprite.animation.getFramesCount() - 1;
				}
				else
				{
					sprite.animation.frame = (1.0f - ratio) * (sprite.animation.getFramesCount());
				}
			}
			else if (sprite.animation.name == "destruction")
			{
				Animation @default_anim = sprite.getAnimation("default");
				if (default_anim !is null)
				{
					sprite.SetAnimation("default");
				}
			}
		}
	}
}

void onDie(CBlob@ this)
{
	// Gib if health below 0.0f
	if (this.getSprite() !is null && this.getHealth() <= 0.0f)
	{
		this.getSprite().Gib();
	}
}