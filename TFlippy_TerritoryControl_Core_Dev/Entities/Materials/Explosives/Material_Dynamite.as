void onInit(CBlob@ this)
{
	this.Tag("explosive");
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

            if(holder !is null && this !is null)
            {
                CBlob@ blob = server_CreateBlob("dynamite", this.getTeamNum(), this.getPosition());
                holder.server_Pickup(blob);
                this.server_Die();
				
				CPlayer@ activator = holder.getPlayer();
				string activatorName = activator !is null ? (activator.getUsername() + " (team " + activator.getTeamNum() + ")") : "<unknown>";
				printf(activatorName + " has activated " + this.getName());
            }
        }
    }
}
