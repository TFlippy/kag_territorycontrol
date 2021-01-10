void onInit(CBlob@ this)
{	
	this.SetLight(true);
	this.SetLightRadius(10.0f);
	this.SetLightColor(SColor(255, 255, 25, 100));
	
	this.maxQuantity = 250;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}