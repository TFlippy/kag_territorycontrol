// Peasant logic

void onInit(CBlob@ this)
{
	this.Tag("neutral");
	this.Tag("human");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CPlayer@ player=this.getPlayer();
	if(this.hasTag("invincible") || (player !is null && player.freeze)) {
		return 0;
	}
	return damage;
}