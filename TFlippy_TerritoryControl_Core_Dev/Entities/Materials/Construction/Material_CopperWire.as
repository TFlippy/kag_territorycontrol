void onInit(CBlob@ this)
{	
	this.maxQuantity = 500;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}