// Peasant logic

void onInit(CBlob@ this)
{
	this.Tag("human");

	this.set_f32("mining_multiplier", 0.75f);
	this.set_u8("mining_hardness", 3);
	this.set_f32("max_build_length", 6.00f);
	this.set_u32("build delay", 3);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 11, Vec2f(16, 16));
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CPlayer@ player=this.getPlayer();
	if(this.hasTag("invincible") || (player !is null && player.freeze)) {
		return 0;
	}
	return damage;
}

void onDie(CBlob@ this)
{
	if (isServer()) server_CreateBlob("engineertools", this.getTeamNum(), this.getPosition());
}
