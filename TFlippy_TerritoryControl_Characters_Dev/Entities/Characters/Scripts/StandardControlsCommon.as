
void server_Pickup(CBlob@ this, CBlob@ picker, CBlob@ pickBlob)
{
	if (pickBlob is null || picker is null || this is null || pickBlob.isAttached() || !pickBlob.canBePickedUp(picker))
		return;
	CBitStream params;
	params.write_netid(picker.getNetworkID());
	params.write_netid(pickBlob.getNetworkID());
	this.SendCommand(this.getCommandID("pickup"), params);
}

void server_PutIn(CBlob@ this, CBlob@ picker, CBlob@ pickBlob)
{
	/*if(isServer()){
		printf("[debug] server_PutIn called on server, blob is "+this.getName());
	}else if(isClient()){
		printf("[debug] server_PutIn called on client, blob is "+this.getName());
	}*/
	if(this is null){
		//print("server_PutIn: holy shit, this was null");
		return;
	}
	if(pickBlob is null || picker is null) {
		//printf("[debug] server_PutIn on blob "+this.getName()+": pickblob or picker is null");
		return;
	}
	CBitStream params;
	params.write_netid(picker.getNetworkID());
	params.write_netid(pickBlob.getNetworkID());
	this.SendCommand(this.getCommandID("putin"),params);
	//printf("[debug] server_PutIn successfully finished on blob "+this.getName());
}

void Tap(CBlob@ this)
{
	this.set_s32("tap_time", getGameTime());
}

bool isTap(CBlob@ this, int ticks = 15)
{
	return (getGameTime() - this.get_s32("tap_time") < ticks);
}
