

void print_log(string text)
{
	if(isServer())
	{
		tcpr("[LOG] " + text);
	}
}

void print_log(CBlob@ blob, string text)
{
	if(isServer())
	{
		if (blob !is null)
		{
			CPlayer@ player = blob.getPlayer();
			if (player !is null)
			{
				tcpr("[PPL] <" + player.getUsername() + "; " + blob.getName() + "; team " + blob.getTeamNum() + "> " + text);
			}
			else
			{
				print_log("[BPL] <" + blob.getName() + "; team " + blob.getTeamNum() + "> " + text);
			}
		}		
	}

}

void print_log(CPlayer@ player, string text)
{
	if(isServer())
	{
		if (player !is null)
		{
			CBlob@ blob = player.getBlob();
			if (blob !is null)
			{
				print_log("[PPL] <" + player.getUsername() + "; " + blob.getName() + "; team " + player.getTeamNum() + "> " + text);
			}
			else
			{
				print_log("[BPL] <" + player.getUsername() + "; team " + player.getTeamNum() + "> " + text);
			}
		}
	}
}