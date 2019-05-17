
void onInit(CBlob@ this)
{
	this.Tag("map_damage_dirt");
	this.set_f32("max_velocity", 17.50f);
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	if (getNet().isServer())
	{
		f32 quantity = 150;
		for (int i = 0; i < (quantity / 2) ; i++)
		{
			CBlob@ blob = server_CreateBlob("mustard", -1, this.getPosition());
			blob.setVelocity(Vec2f(30 - XORRandom(60), 10 - XORRandom(40)));
		}
	}

	this.getSprite().Gib();
}
