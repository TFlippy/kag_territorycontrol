#include "Hitters.as";
void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.set_bool("lite", true);
	this.maxQuantity = 4;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		if(isServer())
		{
			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
			if(point is null){return;}
			CBlob@ holder = point.getOccupied();

			if(holder !is null)
			{
				CBlob@ blob = server_CreateBlob("dynamite", this.getTeamNum(), this.getPosition());
				holder.server_Pickup(blob);
				int8 remain = this.getQuantity() - 1;
				if (remain > 0)
				{
					this.server_SetQuantity(remain);
					holder.server_PutInInventory(this);
					this.Untag("activated");
				}
				else
				{
					this.Tag("dead");
					this.server_Die();
				}
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::explosion && this.get_bool("lite")) //chain reaction
	{
		this.set_bool("lite", false);
		if (isServer())
		{
			CBlob@ blob = server_CreateBlob("dynamite", this.getTeamNum(), this.getPosition());
			blob.server_SetTimeToDie(0.2);
			this.server_Die();
		}
		return 0.1f;
	}
	return damage;
}
