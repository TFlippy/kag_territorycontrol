
void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());
	f32 acceleration = 1.50f + (Maths::Pow(rand.NextFloat(), 5) * 3.00f);
	
	this.Tag("heavy weight");
	this.set_f32("gyromat_value", acceleration);
	
	this.setInventoryName("Accelerated Gyromat\n" + Maths::Round(acceleration * 100.00f) + "% acceleration");
}