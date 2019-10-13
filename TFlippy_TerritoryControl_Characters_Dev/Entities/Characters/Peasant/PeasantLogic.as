// Peasant logic

void onInit(CBlob@ this)
{
	this.Tag("neutral");
	this.Tag("human");
	
	this.set_u8("mining_hardness", 1);
	this.set_u32("build delay", 8);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CPlayer@ player=this.getPlayer();
	if (this.hasTag("invincible") || (player !is null && player.freeze)) 
	{
		return 0;
	}
	return damage;
}