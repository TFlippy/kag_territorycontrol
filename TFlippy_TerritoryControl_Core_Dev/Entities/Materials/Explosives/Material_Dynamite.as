#include "Hitters.as";
void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.set_bool("lite", true);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate") && this.get_bool("lite"))
	{
		this.set_bool("lite", false);
		if(isServer())
		{
    		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
			if(point is null){return;}
    		CBlob@ holder = point.getOccupied();

			if(holder !is null && this !is null)
			{
				CBlob@ blob = server_CreateBlob("dynamite", this.getTeamNum(), this.getPosition());
				holder.server_Pickup(blob);

				CPlayer@ activator = holder.getPlayer();
				string activatorName = activator !is null ? (activator.getUsername() + " (team " + activator.getTeamNum() + ")") : "<unknown>";
				printf(activatorName + " has activated " + this.getName());
			}
			else
			{
				CBlob@ blob = server_CreateBlob("dynamite", this.getTeamNum(), this.getPosition());
				blob.server_Die();
			}
			this.server_Die();
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::explosion) //chain reaction
	{
		this.SendCommand(this.getCommandID("activate"));
	}
	return damage;
}
