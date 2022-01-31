#include "SmartStorageHelpers.as";
#include "MinableMatsCommon.as";

void onInit(CSprite@ this)
{
	this.SetZ(-60);
	CSpriteLayer@ indicator = this.addSpriteLayer("indicator","indicator.png", 5, 6);
	if(indicator !is null)
	{
		{
			indicator.addAnimation("default", 0, false);
			int[] frames = {0, 1, 2, 3, 4, 5, 6};
			indicator.animation.AddFrames(frames);
		}
		indicator.ScaleBy(Vec2f(0.95,0.95));
		indicator.SetOffset(Vec2f(-5.3f,-2.3f));
		indicator.SetRelativeZ(1);
		indicator.SetVisible(true);
		indicator.setRenderStyle(RenderStyle::normal);
	}
}

const u16 capacity = 200; //"five times" the storage cache capacity

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetOffset(Vec2f(-1.0,-3.0));
	this.getCurrentScript().tickFrequency = 5;

	this.Tag("builder always hit");
	this.Tag("ignore extractor");
	this.Tag("smart_storage");

	dictionary inventory;
	dictionary max_quantities;
	this.set("smart_inventory",inventory);
	this.set("smart_inventory_max_quantities",max_quantities);
	this.set_u16("smart_storage_quantity", 0);
	this.addCommandID("smart_storage_sync");
	this.addCommandID("compactor_withdraw");
	//this.addCommandID("smart_storage_debug");

	HarvestBlobMat[] mats = {};
	mats.push_back(HarvestBlobMat(8.0f, "mat_copperingot")); 
	mats.push_back(HarvestBlobMat(8.0f, "mat_ironingot"));
	mats.push_back(HarvestBlobMat(5.0f, "mat_steelingot")); 
	this.set("minableMats", mats);	
}

void client_UpdateName(CBlob@ this)
{
	if (isClient())
	{
		string listOfItems = "";
		dictionary@ inventory;
		this.get("smart_inventory", @inventory);
		array<string>@ inames = inventory.getKeys();
		int64 cur_quantity;
		for(uint8 i=0; i<inames.length;++i)
		{
			inventory.get(inames[i],cur_quantity);
			if (cur_quantity > 0) listOfItems += "\n"+inames[i]+"("+cur_quantity+")";
		}
		this.setInventoryName("Smart storage\n(" + this.get_u16("smart_storage_quantity")*100.00f/capacity + "% full)"+listOfItems);
	}
	CSpriteLayer@ indicator = this.getSprite().getSpriteLayer("indicator");
	if(indicator !is null)
	{
		indicator.SetFrameIndex(Maths::Ceil(this.get_u16("smart_storage_quantity")*6.0f/capacity));
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (caller !is null && caller.getTeamNum() == this.getTeamNum() && (caller.getPosition() - this.getPosition()).Length() <= 64)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());

		CButton@ button_withdraw = caller.CreateGenericButton(20, Vec2f(0, 0), this, this.getCommandID("compactor_withdraw"), "Take a stack", params);
		if (button_withdraw !is null)
		{
			button_withdraw.SetEnabled(this.get_u16("smart_storage_quantity") > 0);
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if (!blob.isAttached() && !blob.hasTag("dead") && (blob.hasTag("material") || blob.hasTag("hopperable")))
	{
		dictionary@ inventory;
		this.get("smart_inventory", @inventory);
		u16 amount = blob.getQuantity();
		u16 maxquantity = blob.getMaxQuantity();
		string iname = blob.getConfig();
		int64 held_resource_amount;
		u16 quantity = this.get_u16("smart_storage_quantity");
		if(quantity<capacity) {
			if(!inventory.get(iname,held_resource_amount) || held_resource_amount==0)
			{
				held_resource_amount = 0;
				if (maxquantity > 1) quantity += 1;
			}
			u16 prevstacks = (held_resource_amount-1)/maxquantity+1; //round up
			held_resource_amount += amount;
			if(prevstacks<(held_resource_amount-1)/maxquantity+1) quantity += 1; //round up again
			blob.server_Die();
			this.set_u16("smart_storage_quantity", quantity);
		}
		else if (quantity==capacity)
		{
			if(!inventory.get(iname,held_resource_amount)) held_resource_amount = 0;
			int64 to_add = (maxquantity-held_resource_amount)%maxquantity;
			if(to_add<0) to_add+=maxquantity;
			if(to_add==0) return;
			if(amount<to_add)
			{
				held_resource_amount += amount;
				blob.server_Die();
			}
			else
			{
				held_resource_amount += to_add;
				blob.server_SetQuantity(amount-to_add);
			}
		}
		else return;
		inventory.set(iname,held_resource_amount);
		dictionary@ mq;
		this.get("smart_inventory_max_quantities",@mq);
		mq.set(iname,maxquantity);
		server_Sync(this, iname, held_resource_amount, maxquantity, quantity);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("smart_storage_sync"))
	{
		if (isClient())
		{
			string iname = params.read_string();
			u32 new_amount = params.read_u32();
			u16 max_quantity = params.read_u16();
			u16 new_quantity = params.read_u16();
			dictionary@ inventory;
			this.get("smart_inventory", @inventory);
			inventory.set(iname,new_amount);

			dictionary@ mq;
			this.get("smart_inventory_max_quantities",@mq);
			mq.set(iname,max_quantity);

			this.set_u16("smart_storage_quantity", new_quantity);

			client_UpdateName(this);
		}
	}
	else if (cmd == this.getCommandID("compactor_withdraw"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		u32 current_quantity = this.get_u16("smart_storage_quantity");
		if (caller !is null && current_quantity > 0)
		{
			if (isServer() && current_quantity > 0) 
			{
				const u8 team = this.getTeamNum();
				const Vec2f pos = caller.getPosition();
				dictionary@ inventory;
				this.get("smart_inventory", @inventory);
				array<string>@ inames = inventory.getKeys();
				int64 cur_quantity;
				for (int i = 0;i < inames.length;i++)
				{
					inventory.get(inames[i],cur_quantity);
					if (cur_quantity <= 0)
					{
						continue;
					}
					CBlob@ blob = server_CreateBlob(inames[i], team, pos);
					if (blob !is null)
					{
						u32 quantity = Maths::Min(cur_quantity, blob.getMaxQuantity());
						cur_quantity = Maths::Max(cur_quantity - quantity, 0);

						blob.server_SetQuantity(quantity);
						smartStorageTake(this, inames[i], quantity);
						break;
					}
				}
			}
		}
	}
}

void onDie(CBlob@ this)
{
	u16 overall_quantity = this.get_u16("smart_storage_quantity");
	if (isServer() && overall_quantity > 0)
	{
		const u8 team = this.getTeamNum();
		const Vec2f pos = this.getPosition();
		dictionary@ inventory;
		this.get("smart_inventory", @inventory);
		array<string>@ inames = inventory.getKeys();
		int64 cur_quantity;
		for(uint8 i=0; i<inames.length;++i)
		{
			inventory.get(inames[i],cur_quantity);
			CBlob@ blob = server_CreateBlob(inames[i], team, pos);
			if (blob !is null)
			{
				u32 quantity = Maths::Min(cur_quantity, blob.getMaxQuantity()*4);
				cur_quantity = Maths::Max(cur_quantity - quantity, 0);

				blob.server_SetQuantity(quantity);
				blob.setVelocity(getRandomVelocity(0, XORRandom(5), 360));
			}
		}
	}
}