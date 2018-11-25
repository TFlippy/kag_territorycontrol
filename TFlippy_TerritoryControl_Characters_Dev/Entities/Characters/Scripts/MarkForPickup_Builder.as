void onInit(CBlob@ this)
{
	this.Tag("builder pickup");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}