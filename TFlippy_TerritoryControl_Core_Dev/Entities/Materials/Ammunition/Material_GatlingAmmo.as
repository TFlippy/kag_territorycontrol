void onInit(CBlob@ this)
{
	if (isServer())
	{
		this.set_u8('decay step', 7);
	}
	this.Tag("ammo");
	this.Tag("ribbon_icon");

	this.maxQuantity = 500;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}