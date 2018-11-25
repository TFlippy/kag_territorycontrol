void onInit(CBlob@ this)
{
	this.Tag("archer pickup");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}