// API for TFlippy's Discord Bot

#include "MakeCrate.as";

void onInit(CRules@ this)
{
	this.addCommandID("discord_playsound_g");
	// this.addCommandID("discord_playsound_l");
	this.addCommandID("discord_airdrop");
	this.addCommandID("discord_chat");
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	const bool server = isServer();
	const bool client = isClient();
	
	bool success = false;
	u32 id;

	if (params.saferead_u32(id))
	{
		if (cmd == this.getCommandID("discord_playsound_g")) 
		{
			string soundname;
			success = params.saferead_string(soundname) && CFileMatcher(soundname).hasMatch();			
			
			if (success)
			{
				if (server)
				{
					print("Discord: Played a Discord sound (" + soundname + ")");
				}
				
				if (client)
				{
					Sound::Play(soundname);
				}
			}
			
			SendCallback(id, "discord_playsound_g", success, "");
		}
		else if (cmd == this.getCommandID("discord_airdrop")) 
		{
			string blobname;
			string playername;
			
			success = params.saferead_string(blobname) && params.saferead_string(playername);
			
			CPlayer@ player = getPlayerByUsername(playername);
			Vec2f pos;
			u8 team = 250;
			
			if (player !is null)
			{
				CBlob@ playerBlob = player.getBlob();
				if (playerBlob !is null)
				{
					pos = playerBlob.getPosition();
				}
				else success = false;
			}
			else success = false;
			
			if (success)
			{
				if (server)
				{
					CBlob@ blob = server_MakeCrateOnParachute(blobname, "SpaceStar Ordering Discord Shipment", 0, team, Vec2f(pos.x + (64 - XORRandom(128)), XORRandom(32)));
					blob.Tag("unpack on land");
					blob.Tag("destroy on touch");
				}
				
				if (client)
				{
					client_AddToChat(playername + " has ordered a Discord Shipment! (" + blobname + ")", 0xffff0000);
				}
			}
			
			SendCallback(id, "discord_airdrop", success, "");
		}
		else if (cmd == this.getCommandID("discord_chat")) 
		{
			string text;
			u32 color;
			
			success = params.saferead_string(text) && params.saferead_u32(color);

			if (server)
			{
				print(text + "(" + color + ")");
			}
			
			if (client)
			{
				client_AddToChat(text, color);
			}
			
			SendCallback(id, "discord_chat", success, "");
		}
	}
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	SendCallback(0, "discord_out_chat", true, player.getCharacterName() + "&" + text_out);

	return true;
}

void SendCallback(u32 id, string cmd, bool success, string content)
{
	//tcpr("{\"id\":"+id+",\"cmd\":\""+cmd+"\",\"success\":"+success+", \"content\":\""+content+"\"}}");
}