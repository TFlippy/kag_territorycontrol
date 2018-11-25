// TFlippy's Steam Power

#include "MakeDustParticle.as";
#include "Explosion.as";

const u16 capacityMax = 20000;

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;
	
	SetCharge(this, 0);
}

void onTick(CBlob@ this)
{
}

void SetCharge(CBlob@ this, u16 inValue)
{
	this.set_u16("charge", Maths::Round(Maths::Max(0, Maths::Min(capacityMax, this.get_u16("charge") + inValue))));
	this.setInventoryName("Capacitor (" + this.get_u16("charge") / capacityMax + "%)");
}

void onDie(CBlob@ this)
{
	ParticleZombieLightning(this.getPosition());
	Explode(this, 5.0f, 3.0f);
	// CMap@ map = getMap();
	
	// for (int i = 0; i < 8; i++)
	// {
		// map.server_setFireWorldspace(Vec2f(this.getPosition().x + (XORRandom(12) - 6) * 8, this.getPosition().y + (XORRandom(6) - 3) * 8), false);
	// }
}


