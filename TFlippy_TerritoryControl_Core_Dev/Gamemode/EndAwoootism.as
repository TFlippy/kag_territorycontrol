//beep boop bap

void onTick(CBlob@ this)
{
	if(this.hasTag("endAwoo"))
	{
		return;
	}
	string infectList = "";
	for(int a = 0; a < getPlayerCount(); ++a)
	{
		CPlayer@ p = getPlayer(a);
		CBlob@ b = p.getBlob();
		if(b !is null)
		{
			if(b.hasScript("AwooootismSpread.as"))
			{
				//b.RemoveScript("AwooootismSpread.as");
				b.Tag("infectOver");
				b.Sync("infectOver",false);
			}
		}
		if(this.hasTag("awootism"))
		{
			infectList += '\n'+ p.getUsername();
			this.Untag("awootism");
			this.Sync("awootism",false);
		}
	}
	client_AddToChat("The infection is over, here is the list of people who were infected when awootism ended!"+infectList, SColor(255, 255, 0, 0));
	this.Tag("endAwoo");
	this.Sync("endAwoo",false);
}
/*
void onCommand(CBlob@ this,u8 cmd,CBitStream @params)
{
	if(cmd==this.getCommandID("outputInfected")) 
	{

		if(isClient())
		{
			string message;

			if(!params.saferead_string(message)) {
				warn("could not read the infection list, safe read fail");
				return;
			}
			client_AddToChat("The infection is over, here is the list of people who got infected!\n"+message, SColor(255, 255, 0, 0));
		}
		if(this.hasScript("EndAwoootism.as"))
		{
			this.RemoveScript("EndAwoootism.as");
		}
	}
}*/


// /rcon CBlob@ b = getPlayerByUsername('Vamist').getBlob(); b.AddScript('AwooootismSpread.as');