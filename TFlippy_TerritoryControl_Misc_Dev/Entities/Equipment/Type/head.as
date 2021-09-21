void onInit(CBlob@ this)
{
	this.Tag("head");

	if (this.getName() == "militaryhelmet")
		this.Tag("armor");
}