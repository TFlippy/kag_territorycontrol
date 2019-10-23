
void onInit(CBlob@ this)
{
	this.Tag("map_damage_dirt");
	this.set_f32("max_velocity", 14.5f);
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("thermobaricexplosion");
		boom.setPosition(this.getPosition());
		boom.set_u8("boom_frequency", 1);
		boom.set_f32("boom_size", 0);
		boom.set_f32("boom_end", 340);
		boom.set_f32("boom_increment", 4.00f);
		boom.Init();
	}

	this.getSprite().Gib();
}
