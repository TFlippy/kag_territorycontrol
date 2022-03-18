// Script by DarkSlayer
#include "SmartStorageHelpers.as";
// custom list of items that can be stored in smart storage
const string[] armoryMats =
{
	"mat_smallrocket",
	"mat_tankshell",
	"mat_howitzershell",
	"ammo_lowcal",
	"ammo_highcal",
	"ammo_shotgun",
	"ammo_gatling",
	"ammo_bandit"
};

void onInit(CBlob@ this)
{
	// this.Tag("smart_storage"); // Tag if you want this to be used for team storage
	this.set_u16("smart_storage_quantity", 0); // amount of blobs/stacks NOT blob quantity
	this.addCommandID("compactor_withdraw");
	this.addCommandID("sv_store");
	this.addCommandID("smart_add");
	this.set_u16("capacity", 50);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		if (blob.hasTag("weapon") || blob.hasTag("ammo"))
		{
			if (canStoreBlob(this, blob)) smartStorageAdd(this, blob);
		}
	}
}

bool canStoreBlob(CBlob@ this, CBlob@ blob)
{
	string blobName = blob.getName();
	for (u8 i = 0; i < armoryMats.length; i++)
	{
		if (armoryMats[i] == blobName) return true;
	}
	return false;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("compactor_withdraw"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		const string blobName = armoryMats[params.read_u8()];
		if (caller !is null && this.get_u16("smart_storage_quantity") > 0)
		{
			if (isServer()) 
			{
				u32 cur_quantity = this.get_u32("Storage_"+blobName);
				if (cur_quantity > 0)
				{
					CBlob@ blob = server_CreateBlob(blobName, -1, this.getPosition());
					if (blob !is null)
					{
						const u32 quantity = Maths::Min(cur_quantity, blob.getMaxQuantity());

						blob.server_SetQuantity(quantity);
						caller.server_PutInInventory(blob);
						smartStorageTake(this, blobName, quantity);
						this.sub_u16("smart_storage_quantity", 1);
						this.Sync("smart_storage_quantity", true);
					}
				}
			}
		}
	}
	else if (cmd == this.getCommandID("sv_store"))
	{
		if (isServer())
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{
				CInventory @inv = caller.getInventory();
				string bname = caller.getName();
				if (bname == "builder" || bname == "engineer" || bname == "peasant")
				{
					CBlob@ carried = caller.getCarriedBlob();
					if (carried !is null)
					{
						if (carried.hasTag("temp blob"))
						{
							carried.server_Die();
						}
					}
				}
				
				if (inv !is null)
				{
					for (u8 i = 0; i < inv.getItemsCount(); i++)
					{
						CBlob@ blob = inv.getItem(i);
						if (blob.hasTag("ammo"))
						{
							if (canStoreBlob(this, blob))
							{
								smartStorageAdd(this, blob);
								continue;
							}
						}
						else if (blob.hasTag("weapon"))
						{
							caller.server_PutOutInventory(blob);
							this.server_PutInInventory(blob);
							i--;
						}
					}
				}
			}
		}
	}
	else if (cmd == this.getCommandID("smart_add"))
	{
		if (isServer())
		{
			CBlob@ blob = getBlobByNetworkID(params.read_u16());
			if (blob !is null)
			{
				smartStorageAdd(this, blob);
			}
		}
	}
}

void smartStorageAdd(CBlob@ this, CBlob@ blob)
{
	if (isServer())
	{
		string blobName = blob.getName();
		u16 storage_quantity = this.get_u16("smart_storage_quantity");
		u16 blobQuantity = blob.getQuantity();
		u16 blobMaxQuantity = blob.getMaxQuantity();

		if (!this.exists("Storage_"+blobName)) this.set_u32("Storage_"+blobName, 0);
		u32 cur_quantity = this.get_u32("Storage_"+blobName);

		if (storage_quantity < this.get_u16("capacity"))
		{
			if (cur_quantity > 0)
			{
				u16 amount = cur_quantity % blobMaxQuantity;
				if (blobQuantity > amount) this.add_u16("smart_storage_quantity", 1);

				this.add_u32("Storage_"+blobName, blobQuantity);
			}
			else
			{
				this.set_u32("Storage_"+blobName, blobQuantity);
				this.add_u16("smart_storage_quantity", 1);
			}
			this.Sync("Storage_"+blobName, true);
			this.Sync("smart_storage_quantity", true);

			blob.Tag("dead");
			blob.server_Die();
		}
		else if (cur_quantity > 0)
		{
			u16 amount = cur_quantity % blobMaxQuantity;
			if (amount > 0)
			{
				amount = Maths::Min(blobMaxQuantity - amount, blobQuantity);
				this.add_u32("Storage_"+blobName, amount);
				this.Sync("Storage_"+blobName, true);
				
				if (amount < blobQuantity) blob.server_SetQuantity(blobQuantity - amount);
				else
				{
					blob.Tag("dead");
					blob.server_Die();
				}
			}
		}
	}
	if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if (forBlob !is null)
	{
		u8 listLength = armoryMats.length;
		u8 tempListLength = 0;
		for (u8 i = 0; i < listLength; i++) if (this.get_u32("Storage_"+armoryMats[i]) > 0) tempListLength++;
		const u8 inv_posx = this.getInventory().getInventorySlots().x;
		const u8 scale = tempListLength/inv_posx;
		Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),// - 156.0f,
              gridmenu.getUpperLeftPosition().y - 72 - (24 * scale));
		CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(inv_posx, 1 + scale), "\n(Ammunition)\nCapacity: ("+this.get_u16("smart_storage_quantity")+" / "+this.get_u16("capacity")+")");
		if (menu !is null)
		{
			menu.deleteAfterClick = false;
			u32 cur_quantity;
			for (u8 i = 0; i < listLength; i++)
			{
				string blobName = armoryMats[i];
				cur_quantity = this.get_u32("Storage_"+blobName);
				if (cur_quantity <= 0) continue;
				CBitStream params;
				params.write_u16(forBlob.getNetworkID());
				params.write_u8(i);
				CGridButton @but = menu.AddButton("$"+blobName+"$", "\nResource Total:\n("+cur_quantity+")", this.getCommandID("compactor_withdraw"), params);
			}
		}
	}
}

void onDie(CBlob@ this)
{
	u16 overall_quantity = this.get_u16("smart_storage_quantity");
	if (isServer() && overall_quantity > 0)
	{
		u32 cur_quantity;
		for (u8 i = 0; i < armoryMats.length; i++)
		{
			cur_quantity = this.get_u32("Storage_"+armoryMats[i]);
			if (cur_quantity > 0)
			{
				CBlob@ blob = server_CreateBlob(armoryMats[i], -1, this.getPosition());
				if (blob !is null)
				{
					u32 quantity = Maths::Min(cur_quantity, blob.getMaxQuantity()*4);
					blob.server_SetQuantity(quantity);
				}
			}
		}
	}
}