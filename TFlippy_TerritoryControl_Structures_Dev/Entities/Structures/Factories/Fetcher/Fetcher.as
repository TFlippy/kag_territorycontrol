#include "MakeMat.as";
#include "Requirements.as";

const u16 max_loop = 150; // what you get for breaking it

void onInit(CSprite@ this){
	this.SetZ(-50);
	
	this.RemoveSpriteLayer("gear");
	CSpriteLayer@ gear = this.addSpriteLayer("gear", "Extractor.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (gear !is null){
		Animation@ anim = gear.addAnimation("default", 0, false);
		anim.AddFrame(3);
		gear.SetOffset(Vec2f(-0.5f, -11.0f));
		gear.SetAnimation("default");
		gear.SetRelativeZ(-5);
	}
}

void onTick(CSprite@ this){
	CSpriteLayer@gear = this.getSpriteLayer("gear");
	if(gear !is null){
		gear.RotateBy(5.0f*(this.getBlob().exists("gyromat_acceleration") ? this.getBlob().get_f32("gyromat_acceleration") : 1), Vec2f(0.5f,-0.5f));
	}
}

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 90;

	this.inventoryButtonPos = Vec2f(0, 0);

	this.Tag("builder always hit");

	this.set_string("fetcher_resource", "");
	this.set_string("fetcher_resource_name", "None");

	this.addCommandID("fetcher_set");

	client_UpdateName(this);
}

void client_UpdateName(CBlob@ this)
{
	if (isClient())
	{
		this.setInventoryName("Fetcher:\n - " + this.get_string("fetcher_resource_name"));
	}
}

void onTick(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 90.0f / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
	
	string resource_name = this.get_string("fetcher_resource");
	
	if (resource_name != "")
	{
		u8 my_team = this.getTeamNum();

		CBlob@[] blobs;
		if (getBlobsByTag("remote_storage", @blobs))
		{
			for (uint i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];

				if(this.getDistanceTo(b) <= 250){
					u8 team = b.getTeamNum();
					
					if(team == my_team || team >= 100){
						if (b.isInventoryAccessible(this) && b.hasTag("extractable")){
							CBlob@ item = b.getInventory().getItem(resource_name);
							
							if (item !is null){
								if (isServer()){
									b.server_PutOutInventory(item);
									item.setPosition(this.getPosition());
								}
								if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");

								return;
							}
						}
					}
				}
			}
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(!this.isOverlapping(caller))return;
	
	u16 carried_netid;

	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null) carried_netid = carried.getNetworkID();

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	params.write_u16(carried_netid);

	string res = "$"+this.get_string("fetcher_resource")+"$";

	if(carried is null){
		CButton@ button = caller.CreateGenericButton(res, Vec2f(0, -8), this, this.getCommandID("fetcher_set"), "Unset Resource", params);
		//if (button !is null)button.SetEnabled(false);
	} else {
		if(carried.getName() != "gyromat" && carried.getName() != "wrench")caller.CreateGenericButton(res, Vec2f(0, -8), this, this.getCommandID("fetcher_set"), "Set Resource", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("fetcher_set"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CBlob@ carried = getBlobByNetworkID(params.read_u16());

		if (caller !is null && carried !is null)
		{
			this.set_string("fetcher_resource", carried.getConfig());
			this.set_string("fetcher_resource_name", carried.getInventoryName());

			client_UpdateName(this);
		} else {
			this.set_string("fetcher_resource", "");
			this.set_string("fetcher_resource_name", "None");

			client_UpdateName(this);
		}
	}
}
