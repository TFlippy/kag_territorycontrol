void onInit(CBlob@ this)
{
	this.Tag("knight pickup");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}