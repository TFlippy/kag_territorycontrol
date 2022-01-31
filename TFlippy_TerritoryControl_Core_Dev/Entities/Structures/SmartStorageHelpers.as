//returns amount of this resource in inventory
u32 smartStorageCheck(CBlob@ this, string iname)
{
	int64 ret;
	dictionary@ inventory;
	if(!this.get("smart_inventory", @inventory) || !inventory.get(iname,ret))
		return 0;
	return ret;
}


//removes up to amount of this resource from inventory, returns how much it removed
u32 smartStorageTake(CBlob@ this, string iname, u32 amount)
{
	int64 am, mq;
	dictionary@ mqd;
	dictionary@ inventory;
	if(!this.get("smart_inventory", @inventory) || !this.get("smart_inventory_max_quantities",@mqd) || !mqd.get(iname,mq) || !inventory.get(iname,am) || am == 0)
		return 0;
	u16 cur_quantity = this.get_u16("smart_storage_quantity");
	u16 prevstacks = (am-1)/mq+1; //round up
	if(amount >= am)
	{
		cur_quantity -= prevstacks;
		amount -= am;
		am = 0;
		inventory.set(iname, am);
	}
	else
	{
		am -= amount;
		amount = 0;
		inventory.set(iname, am);
		cur_quantity-=(prevstacks-((am-1)/mq+1));
	}
	this.set_u16("smart_storage_quantity",cur_quantity);
	server_Sync(this, iname, am, mq, cur_quantity);
	return amount;
}

// KAG's CBlob.Sync() is nonfunctional shit <- ???
void server_Sync(CBlob@ this, string iname, u32 new_amount, u16 max_quantity, u16 new_quantity)
{
	if (getNet().isServer())
	{
		CBitStream stream;
		stream.write_string(iname);
		stream.write_u32(new_amount);
		stream.write_u16(max_quantity);
		stream.write_u16(new_quantity);		
		this.SendCommand(this.getCommandID("smart_storage_sync"), stream);
	}
}