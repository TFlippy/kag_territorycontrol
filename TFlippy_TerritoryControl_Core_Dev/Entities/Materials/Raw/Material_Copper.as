void onInit(CBlob@ this)
{	
	this.maxQuantity = 1000;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}