void onInit(CBlob@ this)
{
	this.Tag("furniture");
	this.Tag("usable by anyone");
	this.set_f32("pickup_priority", 1000.00f); // The lower, the higher priority
}