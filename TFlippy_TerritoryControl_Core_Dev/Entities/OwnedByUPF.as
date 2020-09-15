void onInit(CBlob@ this)
{
	tcpr("[LOG] " + this.getConfig() + " has set team to " + this.getTeamNum());

	if (this.getTeamNum() == 250)
	{
		this.Tag("upf property");
	}
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	tcpr("[LOG] " + this.getConfig() + " has changed team to " + this.getTeamNum());

	if (this.getTeamNum() == 250)
	{
		this.Tag("upf property");
	}
}