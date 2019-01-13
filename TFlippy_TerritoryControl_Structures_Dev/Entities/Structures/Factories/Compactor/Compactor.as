#include "MakeMat.as";
#include "Requirements.as";

void onInit(CSprite@ this)
{
	this.SetZ(-50);
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 5;

	this.Tag("builder always hit");
	this.Tag("ignore extractor");
	
	this.set_u32("compactor_quantity", 0);
	this.set_string("compactor_resource", "");
	this.set_string("compactor_resource_name", "");
	
	this.addCommandID("compactor_withdraw");
}

void onTick(CBlob@ this)
{
	client_UpdateName(this);
}

void client_UpdateName(CBlob@ this)
{
	if (getNet().isClient())
	{
		this.setInventoryName("Compactor\n(" + this.get_u32("compactor_quantity") + " " + this.get_string("compactor_resource_name") + ")");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	
	if (!blob.isAttached() && (blob.hasTag("material") || blob.hasTag("hopperable")))
	{
		string compactor_resource = this.get_string("compactor_resource");
		
		if (getNet().isServer() && compactor_resource == "")
		{
			this.set_string("compactor_resource", blob.getConfig());
			this.set_string("compactor_resource_name", blob.getInventoryName());
			this.Sync("compactor_resource", false);
			this.Sync("compactor_resource_name", false);
			
			compactor_resource = blob.getConfig();
		}
		
		if (blob.getConfig() == compactor_resource)
		{
			if (getNet().isServer()) 
			{
				this.add_u32("compactor_quantity", blob.getQuantity());
				this.Sync("compactor_quantity", false);
				
				blob.server_Die();
				
				// this.server_PutInInventory(blob);
			}
			
			if (getNet().isClient())
			{
				this.getSprite().PlaySound("bridge_open.ogg");
			}
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	CButton@ button_withdraw = caller.CreateGenericButton(20, Vec2f(0, 0), this, this.getCommandID("compactor_withdraw"), "Take a stack", params);
	if (button_withdraw !is null)
	{
		button_withdraw.SetEnabled(this.get_u32("compactor_quantity") > 0);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("compactor_withdraw"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null && this.get_string("compactor_resource") != "")
		{
			u32 current_quantity = this.get_u32("compactor_quantity");
		
			if (getNet().isServer() && current_quantity > 0) 
			{
				CBlob@ blob = server_CreateBlob(this.get_string("compactor_resource"), this.getTeamNum(), this.getPosition());
				if (blob !is null)
				{
					u32 quantity = Maths::Min(current_quantity, blob.getMaxQuantity());
					u32 new_quantity = Maths::Max(current_quantity - quantity, 0);
										
					blob.server_SetQuantity(quantity);
					caller.server_Pickup(blob);
					
					this.set_u32("compactor_quantity", new_quantity);
					if (new_quantity == 0)
					{
						this.set_string("compactor_resource", "");
						this.set_string("compactor_resource_name", "");
						this.Sync("compactor_resource", false);
						this.Sync("compactor_resource_name", false);
					}
				}
			}
			
			if (getNet().isClient())
			{
				
			}
		}
		else
		{
			if (getNet().isServer()) 
			{
			
			}
			
			if (getNet().isClient())
			{
			
			}
		}
	}
}

void onDie(CBlob@ this)
{
	s32 current_quantity = this.get_u32("compactor_quantity");
	if (getNet().isServer() && current_quantity > 0) 
	{
		const string resource_name = this.get_string("compactor_resource");
		const u8 team = this.getTeamNum();
		const Vec2f pos = this.getPosition();
		
		while (current_quantity > 0)
		{
			CBlob@ blob = server_CreateBlob(resource_name, team, pos);
			if (blob !is null)
			{
				u32 quantity = Maths::Min(current_quantity, blob.getMaxQuantity());
				current_quantity = Maths::Max(current_quantity - quantity, 0);
									
				blob.server_SetQuantity(quantity);
				blob.setVelocity(getRandomVelocity(0, XORRandom(400) * 0.01f, 360));
			}
		}
	}
	
	if (getNet().isClient())
	{
		
	}
}