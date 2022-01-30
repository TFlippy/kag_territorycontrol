void onInit(CBlob@ this)
{	
	this.maxQuantity = 2000;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}