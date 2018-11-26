//beep boop bap

void onInit(CBlob@ this)
{
	//this.addCommandID("awootismStart");
	//this.addCommandID("awootismInfected");
	if(this is null)
	{
		warn("awootism blob is null");
		
	}
	else if(this.getPlayer() is null)
	{
		warn("awoootism player is null");
	}
	else
	{
		if(this.hasTag("infectOver"))
		{
			this.Untag("infectOver");
			this.Sync("infectOver",false);
		}
		this.getPlayer().Tag("awootism");
		this.getPlayer().Sync("awootism",false);
	}
}


void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if(this !is null && blob !is null)
	{
		if(this.hasTag("infectOver"))
		{
			return;
		}
		CPlayer@ p = blob.getPlayer();
		CPlayer@ tp = this.getPlayer();
		if(p !is null && tp !is null)
		{
			if(!tp.hasTag("awootism"))
			{
				tp.Tag("awootism");
				tp.Sync("awootism",false);
			}
			if(!p.hasTag("awootism"))
			{
				p.Tag("awootism");
				p.Sync("awootism",false);
				if(blob.hasTag("infectOver"))
				{
					blob.Untag("infectOver");
					blob.Sync("infectOver",false);
				}
				else
				{
					blob.AddScript("AwooootismSpread.as");
				}

				string message = p.getCharacterName();
				string infectGiver = tp.getCharacterName();
				client_AddToChat(message +" has been infected by "+infectGiver, SColor(255, 255, 0, 0));
				
			}
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


// /rcon CBlob@ b = getPlayerByUsername('Vamist').getBlob(); b.AddScript('AwooootismSpread.as');