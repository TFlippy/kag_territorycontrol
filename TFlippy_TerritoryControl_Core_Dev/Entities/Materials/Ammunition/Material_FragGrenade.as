void onInit(CBlob@ this)
{
	this.Tag("explosive");
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

            if(holder !is null && this !is null)
            {
                CBlob@ blob = server_CreateBlob("fraggrenade", this.getTeamNum(), this.getPosition());
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
