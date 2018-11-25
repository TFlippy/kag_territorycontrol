void onInit(CBlob@ this)
{
	this.Tag("furniture");
	this.Tag("heavy weight");
	
	this.set_f32("pickup_priority", 8.00f); // The lower, the higher priority
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}