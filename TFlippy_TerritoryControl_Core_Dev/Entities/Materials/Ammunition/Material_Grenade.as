void onInit(CBlob@ this)
{	
	this.Tag("ammo");

	this.maxQuantity = 4;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}