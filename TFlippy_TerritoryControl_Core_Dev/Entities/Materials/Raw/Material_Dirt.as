void onInit(CBlob@ this)
{
	if (isServer())
	{
		this.set_u8('decay step', 30);
	}

	this.maxQuantity = 1000;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}