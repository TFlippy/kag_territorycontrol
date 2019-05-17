#define CLIENT_ONLY

//#include "TDM_Structs.as";
#include "ScoreboardCommon.as";
#include "Survival_Structs.as";
#include "UI.as";

//skin
// #include "MainButtonRender.as"
// #include "MainTextInputRender.as"
// #include "MainToggleRender.as"
// #include "MainOptionRender.as"
// #include "MainSliderRender.as"
//controls
// #include "UIButton.as"
// #include "UITextInput.as"
// #include "UIToggle.as"
// #include "UIOption.as"
// #include "UISlider.as"

// #include "UILabel.as"

const string kagdevs = "geti;mm;flieslikeabrick;furai;jrgp;";
const string tcdevs = "tflippy;pirate-rob;merser433;goldenguy;koi_;";
const string contributors = "cesar0;sylw;sjd360;mr_hobo;";

void onRenderScoreboard(CRules@ this)
{
	//sort players
	CPlayer@[] sortedplayers;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		int team = p.getTeamNum();
		bool inserted = false;
		for (u32 j = 0; j < sortedplayers.length; j++)
		{
			if (sortedplayers[j].getTeamNum() < team)
			{
				sortedplayers.insert(j, p);
				inserted = true;
				break;
			}
		}
		if (!inserted)
			sortedplayers.push_back(p);
	}

	f32 y_offset = 0;
	
	// Server Info
	{
		float width = 200;
		float height = 120;
		
		f32 y = 40;
		GUI::SetFont("menu");

		CNet@ net = getNet();
		CRules@ rules = getRules();

		string title = net.joined_servername;
		string mapname = getMap().getMapName();
		
		Vec2f dim;
		GUI::GetTextDimensions(title, dim);
		if (dim.x + 15 > width) width = dim.x + 25;

		GUI::GetTextDimensions(mapname, dim);
		if (dim.x + 15 > width) width = dim.x + 25;
	
		Vec2f tl = Vec2f(100, 60);
		Vec2f br = tl + Vec2f(width, height);
		Vec2f mid = tl + Vec2f(width * 0.50f, 0);

		y_offset = tl.x + width;
		
		GUI::DrawPane(tl, br, SColor(0xffcccccc));

		SColor white(0xffffffff);

		mid.y += 20;
		GUI::DrawTextCentered(title, mid, white);
		mid.y += 40;
		GUI::DrawTextCentered("IP: " + net.joined_ip, mid, white);
		mid.y += 20;
		GUI::DrawTextCentered(mapname, mid, white);
		mid.y += 20;
		GUI::DrawTextCentered(getTranslatedString("Match time: {TIME}").replace("{TIME}", "" + timestamp((getRules().exists("match_time") ? getRules().get_u32("match_time") : getGameTime())/getTicksASecond())), mid, white);
	}
	
	f32 stepheight = 20;
	f32 playerList_yOffset = (sortedplayers.length + 3.5) * stepheight;
	
	// MOTD
	{
		float width = getScreenWidth() - 100 - y_offset - 10;
		float height = 120;
	
		f32 y = 40;
		GUI::SetFont("menu");

		// Vec2f pos = Vec2f(250, y);
		


		CNet@ net = getNet();
		CRules@ rules = getRules();

		string info = getTranslatedString(rules.gamemode_name) + ": " + getTranslatedString(rules.gamemode_info);
		Vec2f dim;

		Vec2f tl = Vec2f(y_offset + 10, 60);
		Vec2f br = tl + Vec2f(width, height);
			
		// pos.x -= width/2;
		// Vec2f bot = pos;
		// bot.x += width;
		// bot.y += 95;

		Vec2f mid = tl + Vec2f(width * 0.50f, 0);


		GUI::DrawWindow(tl, br);

		SColor white(0xffffffff);
		SColor black(0xff000000);

		GUI::SetFont("menu");
		GUI::DrawText("General Rules and Notes", Vec2f(10 + tl.x, 10 + tl.y), black);
		GUI::DrawText("- Do not grief or sabotage your team, such as by wasting resources or stealing the leadership and kicking everyone out.", Vec2f(10 + tl.x, 30 + tl.y), black);
		GUI::DrawText("- Intentionally crashing the server will result in a lengthy ban.", Vec2f(10 + tl.x, 45 + tl.y), black);
		GUI::DrawText("- Do not encase neutral spawns in iron or plasteel.", Vec2f(10 + tl.x, 60 + tl.y), black);
		GUI::DrawText("- Spawnkilling and killing neutrals is allowed - just remember that you won't be a likeable person.", Vec2f(10 + tl.x, 75 + tl.y), black);
		GUI::DrawText("- Do not hoard slaves. Slaving everyone ruins the fun for the rest of the server.", Vec2f(10 + tl.x, 90 + tl.y), black);
		// GUI::DrawText("- If you see an admin abusing, report it in the #report channel of our Discord server.", Vec2f(10 + tl.x, 90 + tl.y), black);
	}
	
	// player scoreboard
	{
		
		Vec2f topleft(100, 190);
		Vec2f bottomright(getScreenWidth() - 100, topleft.y + playerList_yOffset);
		GUI::DrawPane(topleft, bottomright, SColor(0xffc0c0c0));
			
		y_offset = bottomright.y;
			
		//offset border

		topleft.x += stepheight;
		bottomright.x -= stepheight;
		topleft.y += stepheight;

		GUI::SetFont("menu");

		//draw player table header

		if(getScreenWidth() < 1461)
		{

			GUI::DrawText("Character Name", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
			GUI::DrawText("User Name", Vec2f(topleft.x + 200, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Clan", Vec2f(bottomright.x - 620, topleft.y), SColor(0xffffffff));
			// GUI::DrawText("Coins", Vec2f(bottomright.x - 600, topleft.y), SColor(0xffffffff));
			// GUI::DrawText("Team Status", Vec2f(bottomright.x - 550, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Wealth", Vec2f(bottomright.x - 420, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Ping", Vec2f(bottomright.x - 330, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Kills", Vec2f(bottomright.x - 270, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Deaths", Vec2f(bottomright.x - 220, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Title", Vec2f(bottomright.x - 150, topleft.y), SColor(0xffffffff));
			// GUI::DrawText("Flag Caps", Vec2f(bottomright.x - 100, topleft.y), SColor(0xffffffff));
		}
		else
		{

			GUI::DrawText("Character Name", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
			GUI::DrawText("User Name", Vec2f(topleft.x + 250, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Clan", Vec2f(bottomright.x - 750, topleft.y), SColor(0xffffffff));
			// GUI::DrawText("Coins", Vec2f(bottomright.x - 600, topleft.y), SColor(0xffffffff));
			// GUI::DrawText("Team Status", Vec2f(bottomright.x - 550, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Wealth", Vec2f(bottomright.x - 550, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Ping", Vec2f(bottomright.x - 450, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Kills", Vec2f(bottomright.x - 350, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Deaths", Vec2f(bottomright.x - 250, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Title", Vec2f(bottomright.x - 150, topleft.y), SColor(0xffffffff));
			// GUI::DrawText("Flag Caps", Vec2f(bottomright.x - 100, topleft.y), SColor(0xffffffff));
		}

		topleft.y += stepheight * 0.5f;

		CControls@ controls = getControls();
		Vec2f mousePos = controls.getMouseScreenPos();

		CSecurity@ security = getSecurity();
		
		//draw players
		for (u32 i = 0; i < sortedplayers.length; i++)
		{
			CPlayer@ p = sortedplayers[i];

			bool playerHover = mousePos.y > topleft.y + 20 && mousePos.y < topleft.y + 40;
			
			if (p is null) continue;

			topleft.y += stepheight;
			bottomright.y = topleft.y + stepheight;

			Vec2f lineoffset = Vec2f(0, -2);

			u32[] teamcolours = {0xff6666ff, 0xffff6666, 0xff33660d, 0xff621a83, 0xff844715, 0xff2b5353, 0xff2a3084, 0xff647160};
			u32 playercolour = teamcolours[p.getTeamNum() % teamcolours.length];
			u32 color_gray = 0xffbfbfbf;
			
			if (p.getTeamNum() >= 100)
			{
				playercolour = 0xffbfbfbf;
			}
			
			if (playerHover)
			{
				playercolour = 0xffffffff;
				color_gray = 0xffffffff;
			}
			
			GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(0xff404040));
			GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, SColor(playercolour));

			string tex = "";
			u16 frame = 0;
			Vec2f framesize;
			if (p.isMyPlayer())
			{
				tex = "ScoreboardIcons.png";
				frame = 4;
				framesize.Set(16, 16);
			}
			else
			{
				tex = p.getScoreboardTexture();
				frame = p.getScoreboardFrame();
				framesize = p.getScoreboardFrameSize();
			}
			if (tex != "") GUI::DrawIcon(tex, frame, framesize, topleft, 0.5f, p.getTeamNum());

			// string playername = (p.getClantag().length > 0 ? p.getClantag() + " " : "") + p.getCharacterName();
			// string username = p.getUsername();
			
			bool dev = false;
			string rank = getRank(p, dev);
			s32 ping_in_ms = s32(p.getPing() * 1000.0f / 30.0f);
			u16 coins = p.getCoins();
			string clan = this.exists("clanData"+p.getUsername().toLower()) ? this.get_string("clanData"+p.getUsername().toLower()) : "";

			

			if(getScreenWidth() < 1461)
			{
				GUI::DrawText((p.getClantag().length > 0 ? p.getClantag() + " " : "") + p.getCharacterName(), topleft + Vec2f(20, 0), playercolour);
				GUI::DrawText(p.getUsername(), topleft + Vec2f(200, 0), color_gray);
				
				GUI::DrawText("" + clan, Vec2f(bottomright.x - 620, topleft.y), color_gray);
				GUI::DrawText("" + coins + " coins", Vec2f(bottomright.x - 420, topleft.y), color_gray);
				// GUI::DrawText(team_status, Vec2f(bottomright.x - 550, topleft.y), color_gray);
				GUI::DrawText("" + ping_in_ms + " ms", Vec2f(bottomright.x - 330, topleft.y), color_gray);
				GUI::DrawText("" + p.getKills(), Vec2f(bottomright.x - 270, topleft.y), color_gray);
				GUI::DrawText("" + p.getDeaths(), Vec2f(bottomright.x - 220, topleft.y), color_gray);
				GUI::DrawText(rank, Vec2f(bottomright.x - 150, topleft.y), color_gray);
			}
			else
			{
				GUI::DrawText((p.getClantag().length > 0 ? p.getClantag() + " " : "") + p.getCharacterName(), topleft + Vec2f(20, 0), playercolour);
				GUI::DrawText(p.getUsername(), topleft + Vec2f(250, 0), color_gray);
				
				GUI::DrawText("" + clan, Vec2f(bottomright.x - 750, topleft.y), color_gray);
				GUI::DrawText("" + coins + " coins", Vec2f(bottomright.x - 550, topleft.y), color_gray);
				// GUI::DrawText(team_status, Vec2f(bottomright.x - 550, topleft.y), color_gray);
				GUI::DrawText("" + ping_in_ms + " ms", Vec2f(bottomright.x - 450, topleft.y), color_gray);
				GUI::DrawText("" + p.getKills(), Vec2f(bottomright.x - 350, topleft.y), color_gray);
				GUI::DrawText("" + p.getDeaths(), Vec2f(bottomright.x - 250, topleft.y), color_gray);
				GUI::DrawText(rank, Vec2f(bottomright.x - 150, topleft.y), color_gray);
			}



			// string team_status = "";
			
			// if (p.getTeamNum() < 7)
			// {
				// TeamData@ team_data;
				// GetTeamData(p.getTeamNum(), @team_data);
			
				// bool isLeader = p.getUsername() == team_data.leader_name;
				// if (isLeader)
				// {
					// team_status = "Leader";
				// }
				// else
				// {
					// team_status = "Member";
				// }
			// }
			
			// p.drawAvatar(Vec2f(bottomright.x, topleft.y), 1.00f / 4.00f);
		}
	}

	/*{	
		if(playerClicked == true)
		{
			f32 width = 100;
			f32 height = 40;
			
			const string text = "hahayes";
			
			Vec2f dim;
			GUI::GetTextDimensions(text, dim);
		
			width = dim.x + 20;
		
			Vec2f tl = Vec2f(getScreenWidth() - 200 - width,  offset+60);
			Vec2f br = Vec2f(getScreenWidth() - 200, tl.y + height);
			GUI::DrawPane(tl, br, 0xffcfcfcf);
		} 
			
	}*/
		
	// team scoreboard
	{
		TeamData[]@ team_list;

		this.get("team_list", @team_list);
		u8 maxTeams = team_list.length;
		
		if (team_list !is null)
		{
			u32 team_len = 0;
			for (u32 i = 0; i < team_list.length; i++)
			{
				if (team_list[i].player_count > 0) team_len++;
			}
		
			if (team_len > 0)
			{
				f32 stepheight = 20;
				f32 base_offset = 850;
				
				Vec2f topleft(100, 200 + playerList_yOffset);
				Vec2f bottomright(getScreenWidth() - 100, topleft.y + ((team_len + 3.5) * stepheight));
				GUI::DrawPane(topleft, bottomright, SColor(0xffc0c0c0));
					
				y_offset = bottomright.y;
					
				//offset border
				topleft.x += stepheight;
				bottomright.x -= stepheight;
				topleft.y += stepheight;

				GUI::SetFont("menu");

				//draw player table header
				if(getScreenWidth() < 1461)
				{
					GUI::DrawText("Team Name", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Leader", Vec2f(topleft.x + 100, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Members", Vec2f(bottomright.x - 650, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Upkeep", Vec2f(bottomright.x - 560, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Wealth", Vec2f(bottomright.x - 490, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Recruiting", Vec2f(bottomright.x - 400, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Murder Tax", Vec2f(bottomright.x - 320, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Lockdown", Vec2f(bottomright.x - 230, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Land Owned", Vec2f(bottomright.x - 150, topleft.y), SColor(0xffffffff));

				}
				else
				{
					GUI::DrawText("Team Name", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Leader", Vec2f(topleft.x + 250, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Members", Vec2f(bottomright.x 		- base_offset + 000, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Upkeep", Vec2f(bottomright.x  		- base_offset + 100, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Wealth", Vec2f(bottomright.x  		- base_offset + 200, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Recruitment", Vec2f(bottomright.x	- base_offset + 300, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Murder Tax", Vec2f(bottomright.x 	- base_offset + 450, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Slavery", Vec2f(bottomright.x 		- base_offset + 550, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Lockdown", Vec2f(bottomright.x 		- base_offset + 650, topleft.y), SColor(0xffffffff));
					GUI::DrawText("Land Owned", Vec2f(bottomright.x 	- base_offset + 750, topleft.y), SColor(0xffffffff));
				}

				topleft.y += stepheight * 0.5f;

				CControls@ controls = getControls();
				Vec2f mousePos = controls.getMouseScreenPos();

				CSecurity@ security = getSecurity();
				
				u16 total_capturables = this.get_u16("total_capturables");
				
				for (u32 i = 0; i < team_list.length; i++)
				{
					TeamData@ team = team_list[i];
					if (team.player_count == 0) continue;
					
					CTeam@ cTeam = this.getTeam(i);
					
					bool hover = mousePos.y > topleft.y + 20 && mousePos.y < topleft.y + 40;
					
					if (team is null) continue;

					topleft.y += stepheight;
					bottomright.y = topleft.y + stepheight;

					Vec2f lineoffset = Vec2f(0, -2);

					u32[] teamcolours = {0xff6666ff, 0xffff6666, 0xff33660d, 0xff621a83, 0xff844715, 0xff2b5353, 0xff2a3084, 0xff647160};

					u32 color_gray = 0xffbfbfbf;
					u32 color = teamcolours[i];
					
					if (hover)
					{
						color_gray = 0xffffffff;
						color = 0xffffffff;
					}
					
					GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(0xff404040));
					GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, color);
					if(getScreenWidth() < 1461)
					{
						GUI::DrawText(cTeam.getName(), topleft + Vec2f(0, 0), color);
						GUI::DrawText(team.leader_name == "" ? "N/A" : team.leader_name, topleft + Vec2f(100, 0), color_gray);
						GUI::DrawText("" + team.player_count, Vec2f(bottomright.x - 650, topleft.y), color_gray);
						GUI::DrawText("" + team.upkeep + " / " + team.upkeep_cap, Vec2f(bottomright.x - 560, topleft.y), color_gray);
						GUI::DrawText("" + team.wealth + " coins", Vec2f(bottomright.x - 490, topleft.y), color_gray);
						GUI::DrawText(team.recruitment_enabled ? "Yes" : "No", Vec2f(bottomright.x - 400, topleft.y), color_gray);
						GUI::DrawText(team.tax_enabled ? "Yes" : "No", Vec2f(bottomright.x - 320, topleft.y), color_gray);
						GUI::DrawText(team.lockdown_enabled ? "Yes" : "No", Vec2f(bottomright.x - 230, topleft.y), color_gray);
						GUI::DrawText("" + Maths::Round((f32(team.controlled_count) / f32(total_capturables)) * 100.00f) + "%", Vec2f(bottomright.x - 150, topleft.y), color_gray);
					}
					else
					{
						GUI::DrawText(cTeam.getName(), topleft + 																Vec2f(0, 0), color);
						GUI::DrawText(team.leader_name == "" ? "N/A" : team.leader_name, topleft + 								Vec2f(250, 0), color_gray);
						GUI::DrawText("" + team.player_count, 																	Vec2f(bottomright.x - base_offset + 000, topleft.y), color_gray);
						GUI::DrawText("" + team.upkeep + " / " + team.upkeep_cap, 												Vec2f(bottomright.x - base_offset + 100, topleft.y), color_gray);
						GUI::DrawText("" + team.wealth + " coins", 																Vec2f(bottomright.x - base_offset + 200, topleft.y), color_gray);
						GUI::DrawText(team.recruitment_enabled ? (team.f2p_enabled ? "Premium + F2P" : "Premium") : "None",		Vec2f(bottomright.x - base_offset + 300, topleft.y), color_gray);
						GUI::DrawText(team.tax_enabled ? "Yes" : "No", 															Vec2f(bottomright.x - base_offset + 450, topleft.y), color_gray);
						GUI::DrawText(team.slavery_enabled ? "Yes" : "No", 														Vec2f(bottomright.x - base_offset + 550, topleft.y), color_gray);
						GUI::DrawText(team.lockdown_enabled ? "Yes" : "No", 													Vec2f(bottomright.x - base_offset + 650, topleft.y), color_gray);
						GUI::DrawText("" + Maths::Round((f32(team.controlled_count) / f32(total_capturables)) * 100.00f) + "%", Vec2f(bottomright.x - base_offset + 750, topleft.y), color_gray);
					}

				}
			}
		}
	}
	
	// Discord Button
	{
		f32 width = 100;
		f32 height = 40;
		
		const string text = "Go to Vamist's Discord Server";
		
		Vec2f dim;
		GUI::GetTextDimensions(text, dim);
	
		width = dim.x + 20;
	
		Vec2f tl = Vec2f(getScreenWidth() - 100 - width, y_offset + 10);
		Vec2f br = Vec2f(getScreenWidth() - 100, tl.y + height);
		
		CControls@ controls = getControls();
		Vec2f mousePos = controls.getMouseScreenPos();
		
		bool hover = mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y;
		
		if (hover)
		{
			GUI::DrawButton(tl, br);
			
			if (controls.isKeyJustPressed(KEY_LBUTTON))
			{
				Sound::Play("option");
			
				OpenWebsite("https://discord.gg/PAERqSb");
				// Engine::AcceptWebsiteOpen(true);
				// Menu::CloseAllMenus();
			}
		}
		else
		{
			GUI::DrawPane(tl, br, 0xffcfcfcf);
		}
		
		GUI::DrawTextCentered(text, Vec2f(tl.x + (width * 0.50f), tl.y + (height * 0.50f)), 0xffffffff);
	}
	
	// Blog Button
	{
		f32 width = 100;
		f32 height = 40;
		
		const string text = "TFlippy's Devblog and Territory Control Patch Notes";
		
		Vec2f dim;
		GUI::GetTextDimensions(text, dim);
	
		width = dim.x + 20;
	
		Vec2f tl = Vec2f(getScreenWidth() - 340 - width, y_offset + 10);
		Vec2f br = Vec2f(getScreenWidth() - 340, tl.y + height);
		
		CControls@ controls = getControls();
		Vec2f mousePos = controls.getMouseScreenPos();
		
		bool hover = mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y;
		
		if (hover)
		{
			GUI::DrawButton(tl, br);
			
			if (controls.isKeyJustPressed(KEY_LBUTTON))
			{
				Sound::Play("option");
			
				OpenWebsite("www.tflippy.com");
				// Engine::AcceptWebsiteOpen(true);
				// Menu::CloseAllMenus();
			}
		}
		else
		{
			GUI::DrawPane(tl, br, 0xffcfcfcf);
		}
		
		GUI::DrawTextCentered(text, Vec2f(tl.x + (width * 0.50f), tl.y + (height * 0.50f)), 0xffffffff);
	}
	
	// GitHub Button
	{
		f32 width = 100;
		f32 height = 40;
		
		const string text = "GitHub Repository";
		
		Vec2f dim;
		GUI::GetTextDimensions(text, dim);
	
		width = dim.x + 20;
	
		Vec2f tl = Vec2f(getScreenWidth() - 735 - width, y_offset + 10);
		Vec2f br = Vec2f(getScreenWidth() - 735, tl.y + height);
		
		CControls@ controls = getControls();
		Vec2f mousePos = controls.getMouseScreenPos();
		
		bool hover = mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y;
		
		if (hover)
		{
			GUI::DrawButton(tl, br);
			
			if (controls.isKeyJustPressed(KEY_LBUTTON))
			{
				Sound::Play("option");
			
				OpenWebsite("www.tflippy.com");
				// Engine::AcceptWebsiteOpen(true);
				// Menu::CloseAllMenus();
			}
		}
		else
		{
			GUI::DrawPane(tl, br, 0xffcfcfcf);
		}
		
		GUI::DrawTextCentered(text, Vec2f(tl.x + (width * 0.50f), tl.y + (height * 0.50f)), 0xffffffff);
	}
}

string getRank(CPlayer@ p, bool &out dev)
{
	string username = p.getUsername().toLower() + ";";
	string seclev = getSecurity().getPlayerSeclev(p).getName();
	dev = false;
	
	if (kagdevs.find(username) != -1) return "KAG Developer";
	else if (tcdevs.find(username) != -1)
	{	
		dev = true;
		return (username == "tflippy;" ? "Lead " : "") + "TC Developer";
	}
	else if (contributors.find(username) != -1) return "Contributor";
	else if (username == "vamist;") return "Glorious Server Host";
	else if (seclev != "Normal") seclev;
	
	return "";
}