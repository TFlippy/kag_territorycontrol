u32 smartStorageTake(CBlob@ this, string blobName, u32 quantity)
{
	u32 cur_quantity = this.get_u32("Storage_"+blobName);
	if (cur_quantity > 0)
	{
		u32 amount = Maths::Min(cur_quantity, quantity);
		if (isServer())
		{
			this.sub_u32("Storage_"+blobName, amount);
			this.Sync("Storage_"+blobName, true);
		}
		return cur_quantity;
	}
	return 0;
}

u32 smartStorageCheck(CBlob@ this, string blobName)
{
	if (this.exists("Storage_"+blobName)) return this.get_u32("Storage_"+blobName);
	return 0;
}