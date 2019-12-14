void onInit(CBlob@ this)
{
	this.SetVisible(false);
	AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
	this.addCommandID("store inventory");
}

void onTick(CBlob@ this)
{
    CBlob@ holder = getBlobByNetworkID(this.get_u16("holder_id"));
	if (holder !is null)
		this.setPosition(holder.getPosition());
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getNetworkID() == this.get_u16("holder_id"))
	{
		CInventory @inv = caller.getInventory();
		if(inv is null) return;

		if(inv.getItemsCount() > 0)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$store_inventory$", Vec2f(-6, 0), this, this.getCommandID("store inventory"), "Store", params);
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob !is null && forBlob.getNetworkID() == this.get_u16("holder_id");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("store inventory"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{
				CInventory @inv = caller.getInventory();
				if (caller.getName() == "builder")
				{
					CBlob@ carried = caller.getCarriedBlob();
					if (carried !is null)
					{
						// TODO: find a better way to check and clear blocks + blob blocks || fix the fundamental problem, blob blocks not double checking requirement prior to placement.
						if (carried.hasTag("temp blob"))
						{
							carried.server_Die();
						}
					}
				}
				
				if (inv !is null)
				{
					while (inv.getItemsCount() > 0)
					{
						CBlob@ item = inv.getItem(0);
						if (!this.server_PutInInventory(item))
						{
							caller.server_PutInInventory(item);
							break;
						}
					}
				}
			}
		}
	}
}