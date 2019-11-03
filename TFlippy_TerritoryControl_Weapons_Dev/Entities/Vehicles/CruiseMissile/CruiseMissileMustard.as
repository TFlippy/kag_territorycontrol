
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
	if (isServer())
	{
		Vec2f velocity = this.getVelocity();
		f32 angle = -velocity.getAngleDegrees() + 180.00f;
	
		f32 quantity = 150;
		for (int i = 0; i < (quantity / 2) ; i++)
		{
			CBlob@ blob = server_CreateBlob("mustard", -1, this.getPosition());
			blob.setVelocity(velocity + Vec2f(20 - XORRandom(40), 5 - XORRandom(10)).RotateByDegrees(angle));
		}
	}

	this.getSprite().Gib();
}
