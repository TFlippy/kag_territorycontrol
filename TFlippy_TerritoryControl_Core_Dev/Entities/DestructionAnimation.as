
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// this.getSprite().SetFrameIndex(Maths::Floor(this.get_f32("mh_health") / 4.00f));
	
	CSprite@ sprite = this.getSprite();
	Animation@ anim = sprite.getAnimation("destruction");
	if (anim !is null)
	{
		sprite.SetAnimation("destruction");
		sprite.SetFrameIndex(Maths::Floor(anim.getFramesCount() * (1.00f - (this.getHealth() / this.getInitialHealth()))));
	}
	
	return damage;
}