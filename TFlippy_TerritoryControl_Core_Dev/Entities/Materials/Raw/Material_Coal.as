void onInit(CBlob@ this)
{	
	this.maxQuantity = 50;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
	
	this.set_u8("fuel_energy", 20);
}