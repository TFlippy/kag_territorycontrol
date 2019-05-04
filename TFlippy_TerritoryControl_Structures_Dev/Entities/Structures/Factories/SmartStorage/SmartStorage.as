#include "MakeMat.as";
#include "Requirements.as";

void onInit(CSprite@ this) {
	this.SetZ(-50);
}

const u16 capacity = 80; //"twice" the storage cache capacity

void onInit(CBlob@ this) {
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 5;

	this.Tag("builder always hit");
	this.Tag("ignore extractor");
	this.Tag("smart_storage");
	
	dictionary inventory;
	this.set("smart_inventory",inventory);
	this.set_u16("smart_storage_quantity", 0);
	this.addCommandID("smart_storage_sync");
	this.addCommandID("smart_storage_debug");
}

void client_UpdateName(CBlob@ this) {
	if (getNet().isClient()) {
		this.setInventoryName("Smart storage\n(" + this.get_u16("smart_storage_quantity")*100.00f/capacity + "% full)");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid) {
	if (blob is null) return;
	
	if (!blob.isAttached() && (blob.hasTag("material") || blob.hasTag("hopperable"))) {
		dictionary@ inventory;
		this.get("smart_inventory", @inventory);
		u16 amount = blob.getQuantity();
		u16 maxquantity = blob.getMaxQuantity();
		string iname = blob.getConfig();
		int64 held_resource_amount;
		u16 quantity = this.get_u16("smart_storage_quantity");
		if(quantity<capacity) {
			if(!inventory.get(iname,held_resource_amount)) {
				held_resource_amount = 0;
				quantity += 1;
			}
			u16 prevstacks = (held_resource_amount-1)/maxquantity+1; //round up
			held_resource_amount += amount;
			if(prevstacks<(held_resource_amount-1)/maxquantity+1) quantity += 1; //round up again
			print("Adding "+iname+":"+amount+", from "+prevstacks+" to "+((held_resource_amount-1)/maxquantity+1)+"->"+quantity);
			blob.server_Die();
			this.set_u16("smart_storage_quantity", quantity);
		} else if (quantity==capacity) {
			if(!inventory.get(iname,held_resource_amount)) held_resource_amount = 0;
			u16 to_add = (maxquantity-held_resource_amount)%maxquantity;
			if(amount<to_add) {
				held_resource_amount += amount;
				blob.server_Die();
			} else {
				held_resource_amount += to_add;
				blob.server_SetQuantity(amount-to_add);
			}
		} else {
			return;
		}
		inventory.set(iname,held_resource_amount);
		inventory.set(iname+"__max_quantity",maxquantity);
		server_Sync(this, iname, held_resource_amount, maxquantity, quantity);
		if (getNet().isClient()) {
			this.getSprite().PlaySound("bridge_open.ogg");
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller ) {
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	CButton@ button_debug = caller.CreateGenericButton(20, Vec2f(0, 0), this, this.getCommandID("smart_storage_debug"), "debug", params);
	if (button_debug !is null) {
		button_debug.SetEnabled(this.get_u16("smart_storage_quantity") > 0);
	}
}

// KAG's CBlob.Sync() is nonfunctional shit <- ???
void server_Sync(CBlob@ this, string iname, u32 new_amount, u16 max_quantity, u16 new_quantity) {
	if (getNet().isServer()) {
		CBitStream stream;
		stream.write_string(iname);
		stream.write_u32(new_amount);
		stream.write_u16(max_quantity);
		stream.write_u16(new_quantity);		
		this.SendCommand(this.getCommandID("smart_storage_sync"), stream);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params) {
	if (cmd == this.getCommandID("smart_storage_sync")) {
		if (getNet().isClient())
		{
			string iname = params.read_string();
			u32 new_amount = params.read_u32();
			u16 max_quantity = params.read_u16();
			u16 new_quantity = params.read_u16();
			dictionary@ inventory;
			this.get("smart_inventory", @inventory);
			inventory.set(iname,new_amount);
			inventory.set(iname+"__max_quantity",max_quantity);
			this.set_u16("smart_storage_quantity", new_quantity);
			
			client_UpdateName(this);
		}
	}
	else if (cmd == this.getCommandID("smart_storage_debug")) {
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		print("quantity: "+this.get_u16("smart_storage_quantity"));

		dictionary@ inventory;
		this.get("smart_inventory", @inventory);
		array<string>@ kkeys=inventory.getKeys();
		for(uint8 i=0; i<kkeys.length;i+=1) {
			string toprint = kkeys[i];
			int64 am;
			inventory.get(toprint,am);
			print(toprint+": "+am);
		}
	}
}

//returns amount of this resource in inventory
u32 smart_Storage_Check(CBlob@ this, string iname) {
	int64 ret;
	dictionary@ inventory;
	if(!this.get("smart_inventory", @inventory) || !inventory.get(iname,ret))
		return 0;
	return ret;
}


//!!!!! where to get maxquantity? create blob? <- for now just store in inventory
//removes up to amount of this resource from inventory, returns how much it removed
u32 smart_Storage_Take(CBlob@ this, string iname, u32 amount) {
	int64 am, mq;
	dictionary@ inventory;
	if(!this.get("smart_inventory", @inventory) || !inventory.get(iname,am) || am == 0) //last one should never happen
		return 0;
	inventory.get(iname+"__max_quantity",mq);
	u16 cur_quantity = this.get_u16("smart_storage_quantity");
	u16 prevstacks = (am-1)/mq+1; //round up
	if(amount >= am) {
		cur_quantity -= prevstacks;
		inventory.delete(iname);
		amount -= am;
	} else {
		am -= amount;
		amount = 0;
		inventory.set(iname, am);
		cur_quantity-=(prevstacks-((am-1)/mq+1));
	}
	this.set_u16("smart_storage_quantity",cur_quantity);
	server_Sync(this, iname, am, mq, cur_quantity);
	return amount;
}

void onDie(CBlob@ this) {
	u16 overall_quantity = this.get_u16("smart_storage_quantity");
	if (getNet().isServer() && overall_quantity > 0) {
		const u8 team = this.getTeamNum();
		const Vec2f pos = this.getPosition();
		dictionary@ inventory;
		this.get("smart_inventory", @inventory);
		array<string>@ inames = inventory.getKeys();
		int64 cur_quantity;
		for(uint8 i=0; i<inames.length;++i) {
			inventory.get(inames[i],cur_quantity);
			while (cur_quantity > 0) {
				CBlob@ blob = server_CreateBlob(inames[i], team, pos);
				if (blob !is null) {
					u32 quantity = Maths::Min(cur_quantity, blob.getMaxQuantity());
					cur_quantity = Maths::Max(cur_quantity - quantity, 0);
									
					blob.server_SetQuantity(quantity);
					blob.setVelocity(getRandomVelocity(0, XORRandom(400) * 0.01f, 360));
				}
			}
		}
	}
}
