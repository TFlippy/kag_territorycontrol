// Script by DarkSlayer
#include "SmartStorageHelpers.as";

// custom list of items that can be stored in smart storage
const string[] factionStorageMats =
{
	"mat_copperingot",
	"mat_ironingot",
	"mat_steelingot",
	"mat_goldingot",
	"mat_mithrilingot",
	"mat_wood",
	"mat_stone",
	"mat_plasteel",
	"mat_concrete",
	"mat_dirt",
	"mat_sulphur",
	"mat_copperwire",
	"mat_iron",
	"mat_copper",
	"mat_gold",
	"mat_coal",
	"mat_mithril",
	"mat_mithrilenriched",
	"mat_meat",
	"foodcan",
	"pumpkin",
	"grain",
	"mat_acid",
	"mat_oil",
	"mat_methane",
	"mat_fuel",
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
	this.addCommandID("faction_upgrade");
	if (!this.exists("capacity")) this.set_u16("capacity", 50);
	this.set_bool("storage_cache", this.getName() == "storage"); 
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		if (canPickup(this, blob))
		{
			if (canStoreBlob(this, blob)) smartStorageAdd(this, blob);
		}
	}
}

bool canPickup(CBlob@ this, CBlob@ blob)
{
	if (this.get_u16("smart_storage_quantity") == this.get_u16("capacity")) return false;
	return !blob.isAttached() && (blob.hasTag("ammo") || (!blob.hasTag("dead") && (blob.hasTag("material") || blob.hasTag("hopperable")) && !blob.hasTag("weapon")));
}

bool canStoreBlob(CBlob@ this, CBlob@ blob)
{
	string blobName = blob.getName();
	for (u8 i = 0; i < factionStorageMats.length; i++)
	{
		if (factionStorageMats[i] == blobName) return true;
	}
	return false;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("compactor_withdraw"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		const string blobName = factionStorageMats[params.read_u8()];
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
						CBlob@ item = inv.getItem(i);
						if (canPickup(this, item))
						{
							if (canStoreBlob(this, item))
							{
								smartStorageAdd(this, item);
								continue;
							}
						}
						if (!this.server_PutInInventory(item))
						{
							caller.server_PutInInventory(item);
						}
						else i--;
					}
				}
			}
		}
	}
	else if (cmd == this.getCommandID("faction_upgrade"))
	{
		if (isServer())
		{
			CBlob@ blob = getBlobByNetworkID(params.read_u16());
			if (blob !is null)
			{
				if (this.get_u16("smart_storage_quantity") > 0)
				{
					for (u8 i = 0; i < factionStorageMats.length; i++)
					{
						blob.set_u32("Storage_"+factionStorageMats[i], this.get_u32("Storage_"+factionStorageMats[i]));
					}
					blob.set_u16("smart_storage_quantity", this.get_u16("smart_storage_quantity"));
				}
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
			if (this.get_bool("storage_cache"))
			{
				CBitStream params;
				params.write_u16(blob.getNetworkID());
				this.SendCommand(this.getCommandID("update_storagelayers"), params);
			}
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
		u8 listLength = factionStorageMats.length;
		u8 tempListLength = 0;
		for (u8 i = 0; i < listLength; i++) if (this.get_u32("Storage_"+factionStorageMats[i]) > 0) tempListLength++;
		const u8 inv_posx = this.getInventory().getInventorySlots().x;
		const u8 scale = tempListLength/inv_posx;
		Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),// - 156.0f,
              gridmenu.getUpperLeftPosition().y - 72 - (24 * scale));
		CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(inv_posx, 1 + scale), "\n(Secondary Storage)\nCapacity: ("+this.get_u16("smart_storage_quantity")+" / "+this.get_u16("capacity")+")");
		if (menu !is null)
		{
			menu.deleteAfterClick = false;
			u32 cur_quantity;
			for (u8 i = 0; i < listLength; i++)
			{
				string blobName = factionStorageMats[i];
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
	if (this.hasTag("upgrading")) return;
	u16 overall_quantity = this.get_u16("smart_storage_quantity");
	if (isServer() && overall_quantity > 0)
	{
		u32 cur_quantity;
		for (u8 i = 0; i < factionStorageMats.length; i++)
		{
			cur_quantity = this.get_u32("Storage_"+factionStorageMats[i]);
			if (cur_quantity > 0)
			{
				CBlob@ blob = server_CreateBlob(factionStorageMats[i], -1, this.getPosition());
				if (blob !is null)
				{
					u32 quantity = Maths::Min(cur_quantity, blob.getMaxQuantity()*4);
					blob.server_SetQuantity(quantity);
				}
			}
		}
	}
}