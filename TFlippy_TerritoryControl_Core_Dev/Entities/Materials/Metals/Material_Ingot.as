void onInit(CBlob@ this)
{
	if (this.getName() == "mat_ironingot")
	{
		if (isServer())
		{
			this.set_u8('decay step', 2);
		}
	}

	this.maxQuantity = 200;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}