//beep boop bap

void onInit(CBlob@ this)
{
	//this.addCommandID("awootismStart");
	//this.addCommandID("awootismInfected");
	if(this.hasTag("infectOver"))
	{
		this.Untag("infectOver");
		this.Sync("infectOver",false);
	}
	this.Tag("awootism");
	this.Sync("awootism",false);
}

//TODO change to CMD and cblob + CRules for perma

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if(this !is null && blob !is null)
	{
		if(this.hasTag("infectOver"))
		{
			return;
		}

		CPlayer@ player = this.getPlayer();
		CPlayer@ oPlayer = blob.getPlayer();
		if(player is null || oPlayer is null){
			return;
		}
		if(!blob.hasTag("awootism"))
		{
			blob.Tag("awootism");
			blob.Sync("awootism",false);
		}
		if(!this.hasTag("awootism"))
		{
			this.Tag("awootism");
			this.Sync("awootism",false);
			if(blob.hasTag("infectOver"))
			{
				blob.Untag("infectOver");
				blob.Sync("infectOver",false);
			}
			else
			{
				blob.AddScript("AwooootismSpread.as");
			}
			
			string message = player.getCharacterName();
			string infectGiver = oPlayer.getCharacterName();
			client_AddToChat(message +" has been infected by "+infectGiver, SColor(255, 255, 0, 0));
			
		}
	}
}

/*
void onCommand(CBlob@ this,u8 cmd,CBitStream @params)
{
	if(cmd==this.getCommandID("awootismStart")) 
	{
		if(isClient())
		{
			string message;

			if(!params.saferead_string(message)) {
				warn("could not start the infection, safe read fail");
				return;
			}
			
		}
	}
	else if(cmd==this.getCommandID("awootismInfected"))
	{
		if(isClient())
		{
			string infected,infectGiver;

			if(!params.saferead_string(infected)) {
					warn("could not spread the infection, safe read fail");
					return;
			}
			if(!params.saferead_string(infectGiver)) {
					warn("could not spread the infection, safe read fail");
					return;
			}

			client_AddToChat(infected+" has been infected by "+infectGiver, SColor(255, 255, 0, 0));
		}
	}
}*/


// /rcon CBlob@ b = gebloblayerByUsername('Vamist').getBlob(); b.AddScript('AwooootismSpread.as');