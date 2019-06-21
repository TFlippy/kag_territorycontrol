void onInit(CBlob@ this)
{	
	this.maxQuantity = 50;	
	this.set_u8("fuel_energy", 20);
	
	this.getCurrentScript().tickFrequency = 1;
}

const f32 dust_quantity = 20;

void onTick(CBlob@ this)
{
	Vec2f vel = this.getOldVelocity();
	f32 vellen = vel.getLength();
	
	if (vellen > 5.00f)
	{
		if (isServer())
		{
			this.server_SetQuantity(Maths::Clamp(this.getQuantity() - dust_quantity, 0, this.maxQuantity));
			CBlob@ dust = server_CreateBlob("coal", -1, this.getPosition());
			
			dust.setVelocity((vel * 0.33f) + getRandomVelocity(0, XORRandom(vellen * 25) * 0.01f, 360));
		}
		
		if (isClient())
		{
			this.getSprite().PlaySound("sand_fall.ogg", 1.00f, 0.60f);
		}
	}
}