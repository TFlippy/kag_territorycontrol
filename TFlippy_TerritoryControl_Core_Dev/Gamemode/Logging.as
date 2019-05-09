
void print_log(string text)
{
	print("[LOG] " + text, SColor(255, 255, 0, 255));
}

void print_log(CBlob@ blob, string text)
{
	if (blob !is null)
	{
		CPlayer@ player = blob.getPlayer();
		if (player !is null)
		{
			print_log("<" + player.getUsername() + "; " + blob.getConfig() + "; team " + blob.getTeamNum() + "> " + text);
		}
		else
		{
			print_log("<" + blob.getConfig() + "; team " + blob.getTeamNum() + "> " + text);
		}
	}
}

void print_log(CPlayer@ player, string text)
{
	if (player !is null)
	{
		CBlob@ blob = player.getBlob();
		if (blob !is null)
		{
			print_log("<" + player.getUsername() + "; " + blob.getConfig() + "; team " + player.getTeamNum() + "> " + text);
		}
		else
		{
			print_log("<" + player.getUsername() + "; team " + player.getTeamNum() + "> " + text);
		}
	}
}