#include "MakeMat.as";
#include "Requirements.as";

const u16 MAX_LOOP = 10; // what you get for breaking it
const u16 LOOP_RNG = 40; // variation on what will spawn if broken 

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
	this.addCommandID("compactor_sync");
}

// void onTick(CBlob@ this)
// {
	// client_UpdateName(this);
// }

void client_UpdateName(CBlob@ this)
{
	if (isClient())
	{
		this.setInventoryName("Compactor\n(" + this.get_u32("compactor_quantity") + " " + this.get_string("compactor_resource_name") + ")");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	
	if (!blob.isAttached() && !blob.hasTag("dead") && (blob.hasTag("material") || blob.hasTag("hopperable")))
	{
		string compactor_resource = this.get_string("compactor_resource");
		
		if (isServer() && compactor_resource == "")
		{
			this.set_string("compactor_resource", blob.getName());
			this.set_string("compactor_resource_name", blob.getInventoryName());
			// this.Sync("compactor_resource", false);
			// this.Sync("compactor_resource_name", false);
			
			compactor_resource = blob.getName();
		}
		
		if (blob.getName() == compactor_resource)
		{
			if (isServer()) 
			{
				this.add_u32("compactor_quantity", blob.getQuantity());
				// this.Sync("compactor_quantity", false);
				
				blob.Tag("dead");
				blob.server_Die();
				server_Sync(this);
			}
			
			if (isClient())
			{
				this.getSprite().PlaySound("bridge_open.ogg");
			}
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (caller !is null && (caller.getPosition() - this.getPosition()).Length() <= 64)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());

		CButton@ button_withdraw = caller.CreateGenericButton(20, Vec2f(0, 0), this, this.getCommandID("compactor_withdraw"), "Take a stack", params);
		if (button_withdraw !is null)
		{
			button_withdraw.SetEnabled(this.get_u32("compactor_quantity") > 0);
		}
	}
}

// KAG's CBlob.Sync() is nonfunctional shit
void server_Sync(CBlob@ this)
{
	if (isServer())
	{
		CBitStream stream;
		stream.write_string(this.get_string("compactor_resource_name"));
		stream.write_string(this.get_string("compactor_resource"));
		stream.write_u32(this.get_u32("compactor_quantity"));
		
		this.SendCommand(this.getCommandID("compactor_sync"), stream);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("compactor_withdraw"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null && this.get_string("compactor_resource") != "")
		{
			u32 current_quantity = this.get_u32("compactor_quantity");
		
			if (isServer() && current_quantity > 0) 
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
					}
					server_Sync(this);
				}
			}
		}
	}
	else if (cmd == this.getCommandID("compactor_sync"))
	{
		if (isClient())
		{
			string name = params.read_string();
			string config = params.read_string();
			u32 quantity = params.read_u32();
			
			this.set_string("compactor_resource_name", name);
			this.set_string("compactor_resource", config);
			this.set_u32("compactor_quantity", quantity);
			
			client_UpdateName(this);
		}
	}
}

void onDie(CBlob@ this)
{
	s32 current_quantity = this.get_u32("compactor_quantity");
	if (isServer() && current_quantity > 0) 
	{
		const string resource_name = this.get_string("compactor_resource");
		const u8 team = this.getTeamNum();
		const Vec2f pos = this.getPosition();
		const int rng_amount = MAX_LOOP + XORRandom(LOOP_RNG);

		for (int a = 0; a < current_quantity && a < rng_amount; a++)
		{
			CBlob@ blob = server_CreateBlob(resource_name, team, pos);
			if (blob is null) { continue; }

			u32 quantity = Maths::Min(current_quantity, blob.getMaxQuantity());
			current_quantity = Maths::Max(current_quantity - quantity, 0);
									
			blob.server_SetQuantity(quantity);
			blob.setVelocity(getRandomVelocity(0, XORRandom(400) * 0.01f, 360));
		}

		server_Sync(this);
	}
}