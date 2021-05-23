//implements 2 default vote types (kick and next map) and menus for them

#include "VoteCommon.as"

bool g_haveStartedVote = false;
s32 g_lastVoteCounter = 0;
const float required_minutes = 10; //time you have to wait after joining w/o skip_votewait.

s32 g_lastNextmapCounter = 0;
const float required_minutes_nextmap = 5; //global nextmap vote cooldown

const s32 VoteKickTime = 30 * 60 * 30; //ticks (30min default)
const s32 VoteTeamKickNoTeamTime = 10 * 60 * 30; // 10 minutes

//kicking related globals and enums
enum kick_reason
{
	kick_reason_griefer = 0,
	kick_reason_hacker,
	kick_reason_teamkiller,
	kick_reason_spammer,
	kick_reason_afk,
	kick_reason_count,
};
string[] kick_reason_string = { "Griefer", "Hacker", "Teamkiller", "Spammer", "AFK" };

string g_kick_reason = kick_reason_string[kick_reason_griefer]; //default


const string[] TypeToString = {
	"Random",
	"Official",
	"Meme",
	"Old"
};


//next map related globals and enums
enum nextmap_reason
{
	nextmap_reason_ruined = 0,
	nextmap_reason_bugged,
	nextmap_reason_lag,
	nextmap_reason_count,
};

string[] nextmap_reason_string = { "Map Ruined", "Game Bugged", "Server lagging"};

//votekick and vote nextmap

const string votekick_id = "vote: kick";
const string votenextmap_id = "vote: nextmap";
const string voteteamkick_id = "vote: teamkick";


enum teamkick_reason
{
	teamkick_reason_betrayal = 0,
	teamkick_reason_disobedience,
	teamkick_reason_stealing,
	teamkick_reason_count,
};

string[] teamkick_reason_string = { "Traitor", "Disobedient", "Stealing" };

//set up the ids
void onInit(CRules@ this)
{
	this.addCommandID(votekick_id);
	this.addCommandID(votenextmap_id);
	this.addCommandID(voteteamkick_id);
}

void onRestart(CRules@ this)
{
	g_lastNextmapCounter = 60 * getTicksASecond() * required_minutes_nextmap;
}

void onTick(CRules@ this)
{
	if (g_lastVoteCounter < 60 * getTicksASecond()*required_minutes)
		g_lastVoteCounter++;
	if (g_lastNextmapCounter < 60 * getTicksASecond()*required_minutes_nextmap)
		g_lastNextmapCounter++;
}


//VOTE TEAM KICK --------------------------------------------------------------------
//voteteamkick functors


class VoteTeamKickFunctor : VoteFunctor
{
	VoteTeamKickFunctor() {} //dont use this
	VoteTeamKickFunctor(CPlayer@ _kickplayer)
	{
		@kickplayer = _kickplayer;
	}

	CPlayer@ kickplayer;

	void Pass(bool outcome)
	{
		if (kickplayer !is null && outcome)
		{
			client_AddToChat("Team Votekick passed! " + kickplayer.getUsername() + " will be kicked out of your team.", vote_message_colour());

			if (isServer())
			{
				kickplayer.server_setTeamNum(XORRandom(100)+100);
				kickplayer.set_u32("teamkick_time", getGameTime() + VoteTeamKickNoTeamTime);
				kickplayer.Sync("teamkick_time", true);
				
				CBlob@ b = kickplayer.getBlob();
				if(b !is null)
				{
					b.server_Die();
				}
			}
		}
	}
};

class VoteTeamKickCheckFunctor : VoteCheckFunctor
{
	VoteTeamKickCheckFunctor() {}//dont use this
	VoteTeamKickCheckFunctor(CPlayer@ _kickplayer, string _reason)
	{
		@kickplayer = _kickplayer;
		reason = _reason;
	}

	CPlayer@ kickplayer;
	string reason;

	bool PlayerCanVote(CPlayer@ player)
	{
		int team = kickplayer.getTeamNum();
		
		if (getSecurity().checkAccess_Feature(player, "mark_player") && team == player.getTeamNum() && team < 3) return true;
		else return false;
	}
};

//setting up a votekick object
VoteObject@ Create_VoteTeamKick(CPlayer@ player, CPlayer@ byplayer, string reason)
{
	VoteObject vote;

	@vote.onvotepassed = VoteTeamKickFunctor(player);
	@vote.canvote = VoteTeamKickCheckFunctor(player, reason);

	vote.title = "Team Kick " + player.getUsername() + "?";
	vote.reason = reason;
	vote.byuser = byplayer.getUsername();
	vote.forcePassFeature = "ban";

	CalculateVoteThresholds(vote);

	return vote;
}


//VOTE KICK --------------------------------------------------------------------
//votekick functors

class VoteKickFunctor : VoteFunctor
{
	VoteKickFunctor() {} //dont use this
	VoteKickFunctor(CPlayer@ _kickplayer)
	{
		@kickplayer = _kickplayer;
	}

	CPlayer@ kickplayer;

	void Pass(bool outcome)
	{
		if (kickplayer !is null && outcome)
		{
			client_AddToChat("Votekick passed! " + kickplayer.getUsername() + " will be kicked out.", vote_message_colour());

			if (isServer())
				BanPlayer(kickplayer, VoteKickTime); //30 minutes ban
		}
	}
};

class VoteKickCheckFunctor : VoteCheckFunctor
{
	VoteKickCheckFunctor() {}//dont use this
	VoteKickCheckFunctor(CPlayer@ _kickplayer, string _reason)
	{
		@kickplayer = _kickplayer;
		reason = _reason;
	}

	CPlayer@ kickplayer;
	string reason;

	bool PlayerCanVote(CPlayer@ player)
	{
		if (!getSecurity().checkAccess_Feature(player, "mark_player")) return false;

		if (reason.find(kick_reason_string[kick_reason_griefer]) != -1 || //reason contains "Griefer"
		        reason.find(kick_reason_string[kick_reason_teamkiller]) != -1 || //or TKer
		        reason.find(kick_reason_string[kick_reason_afk]) != -1) //or AFK
		{
			return (player.getTeamNum() == kickplayer.getTeamNum() || //must be same team
			        kickplayer.getTeamNum() == getRules().getSpectatorTeamNum() || //or they're spectator
			        getSecurity().checkAccess_Feature(player, "mark_any_team"));   //or has mark_any_team
		}

		return true; //spammer, hacker (custom?)
	}
};

class VoteKickLeaveFunctor : VotePlayerLeaveFunctor
{
	VoteKickLeaveFunctor() {} //dont use this
	VoteKickLeaveFunctor(CPlayer@ _kickplayer)
	{
		@kickplayer = _kickplayer;
	}

	CPlayer@ kickplayer;

	//avoid dangling reference to player
	void PlayerLeft(VoteObject@ vote, CPlayer@ player)
	{
		if (player is kickplayer)
		{
			client_AddToChat(player.getUsername() + " left early, acting as if they were kicked.", vote_message_colour());
			if (isServer())
			{
				BanPlayer(player, VoteKickTime);
			}

			CancelVote(vote);
		}
	}
};

//setting up a votekick object
VoteObject@ Create_Votekick(CPlayer@ player, CPlayer@ byplayer, string reason)
{
	VoteObject vote;

	@vote.onvotepassed = VoteKickFunctor(player);
	@vote.canvote = VoteKickCheckFunctor(player, reason);
	@vote.playerleave = VoteKickLeaveFunctor(player);

	vote.title = "Kick " + player.getUsername() + "?";
	vote.reason = reason;
	vote.byuser = byplayer.getUsername();
	vote.forcePassFeature = "ban";

	CalculateVoteThresholds(vote);

	return vote;
}

//VOTE NEXT MAP ----------------------------------------------------------------
//nextmap functors

class VoteNextmapFunctor : VoteFunctor
{
	string playername;
	u8 MapType = 0;

	VoteNextmapFunctor() {} //dont use this
	VoteNextmapFunctor(CPlayer@ player, u8 type)
	{
		string charname = player.getCharacterName();
		string username = player.getUsername();
		//name differs?
		if (charname != username &&
		        charname != player.getClantag() + username &&
		        charname != player.getClantag() + " " + username)
		{
			playername = charname + " (" + player.getUsername() + ")";
		}
		else
		{
			playername = charname;
		}

		MapType = type;
	}

	void Pass(bool outcome)
	{
		if (outcome)
		{
			if (isServer())
			{
				switch (MapType)
				{
					// Official maps
					case 1:
					{
						string[]@ OffiMaps;
						getRules().get("maptypes-offi", @OffiMaps);

						LoadMap(OffiMaps[XORRandom(OffiMaps.length)]);
					}
					break;

					// Meme maps
					case 2:
					{
						string[]@ MemeMaps;
						getRules().get("maptypes-meme", @MemeMaps);

						LoadMap(MemeMaps[XORRandom(MemeMaps.length)]);
					}
					break;

					// Old maps
					case 3:
					{
						string[]@ OldMaps;
						getRules().get("maptypes-old", @OldMaps);

						LoadMap(OldMaps[XORRandom(OldMaps.length)]);
					}
					break;

					// If the maptype is invalid or set to default, 
					// load next map like before
					default:
						LoadNextMap();
					break;
				}
			}
		}
		else
		{
			client_AddToChat(playername + " needs to take a spoonful of cement! Play on!", vote_message_colour());
		}
	}
};

class VoteNextmapCheckFunctor : VoteCheckFunctor
{
	VoteNextmapCheckFunctor() {}

	bool PlayerCanVote(CPlayer@ player)
	{
		return getSecurity().checkAccess_Feature(player, "map_vote");
	}
};

//setting up a vote next map object
VoteObject@ Create_VoteNextmap(CPlayer@ byplayer, string reason, u8 maptype)
{
	VoteObject vote;

	@vote.onvotepassed = VoteNextmapFunctor(byplayer, maptype);
	@vote.canvote = VoteNextmapCheckFunctor();

	vote.title = "Load new map";
	vote.maptype = TypeToString[maptype % 4];
	vote.reason = reason;
	vote.byuser = byplayer.getUsername();
	vote.forcePassFeature = "nextmap";
	vote.required_percent = 0.65f;

	CalculateVoteThresholds(vote);

	return vote;
}

//create menus for kick and nextmap

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	//print("menu");

	//get our player first - if there isn't one, move on
	CPlayer@ me = getLocalPlayer();
	if (me is null) return;

	CRules@ rules = getRules();

	if (Rules_AlreadyHasVote(rules))
	{
		Menu::addContextItem(menu, "(Vote already in progress)", "DefaultVotes.as", "void CloseMenu()");
		Menu::addSeparator(menu);

		return;
	}

	//and advance context menu when clicked
	CContextMenu@ votemenu = Menu::addContextMenu(menu, "Start a Vote");
	Menu::addSeparator(menu);

	//vote options menu

	CContextMenu@ kickmenu = Menu::addContextMenu(votemenu, "Kick");
	// CContextMenu@ teamkickmenu = Menu::addContextMenu(votemenu, "Team Kick");
	CContextMenu@ mapmenu = Menu::addContextMenu(votemenu, "Next Map");
	Menu::addSeparator(votemenu); //before the back button

	bool can_skip_wait = getSecurity().checkAccess_Feature(me, "skip_votewait");

	//kick menu
	if (getSecurity().checkAccess_Feature(me, "mark_player"))
	{
		if (g_lastVoteCounter < 60 * getTicksASecond()*required_minutes
		        && (!can_skip_wait || g_haveStartedVote))
		{
			Menu::addInfoBox(kickmenu, "Can't Start Vote", "Voting requires a " + required_minutes + " min wait\n" +
			                 "after each started vote to\n" +
			                 "prevent spamming/abuse.\n");
		}
		else
		{
			Menu::addInfoBox(kickmenu, "Vote Kick", "Vote to kick a player on your team\nout of the game.\n\n" +
			                 "- use responsibly\n" +
			                 "- report any abuse of this feature.\n" +
			                 "\nTo Use:\n\n" +
			                 "- select a reason from the\n     list (default is griefing).\n" +
			                 "- select a name from the list.\n" +
			                 "- everyone votes.\n");

			Menu::addSeparator(kickmenu);

			//reasons
			for (uint i = 0 ; i < kick_reason_count; ++i)
			{
				CBitStream params;
				params.write_u8(i);
				Menu::addContextItemWithParams(kickmenu, kick_reason_string[i], "DefaultVotes.as", "Callback_KickReason", params);
			}

			Menu::addSeparator(kickmenu);

			//write all players on our team
			bool added = false;
			for (int i = 0; i < getPlayersCount(); ++i)
			{
				CPlayer@ player = getPlayer(i);

				//if(player is me) continue; //don't display ourself for kicking
				//commented out for max lols

				int player_team = player.getTeamNum();
				if ((player_team == me.getTeamNum() || player_team == this.getSpectatorTeamNum()
				        || getSecurity().checkAccess_Feature(me, "mark_any_team"))
				        && (!getSecurity().checkAccess_Feature(player, "kick_immunity")))      //TODO: check seclevs properly (what's improper with this? ~~norill)
				{
					string descriptor = player.getCharacterName();

					if (player.getUsername() != player.getCharacterName())
						descriptor += " (" + player.getUsername() + ")";

					CContextMenu@ usermenu = Menu::addContextMenu(kickmenu, "Kick " + descriptor);
					Menu::addInfoBox(usermenu, "Kicking " + descriptor, "Make sure you're voting to kick\nthe person you meant.\n");
					Menu::addSeparator(usermenu);

					CBitStream params;
					params.write_u16(player.getNetworkID());

					Menu::addContextItemWithParams(usermenu, "Yes, I'm sure", "DefaultVotes.as", "Callback_Kick", params);
					added = true;

					Menu::addSeparator(usermenu);
				}
			}

			if (!added)
			{
				Menu::addContextItem(kickmenu, "(No-one available)", "DefaultVotes.as", "void CloseMenu()");
			}
		}
	}
	else
	{
		Menu::addInfoBox(kickmenu, "Can't vote", "You cannot vote to kick\n" +
		                 "players on this server\n");
	}
	Menu::addSeparator(kickmenu);

	// teamkick menu
	// if (getSecurity().checkAccess_Feature(me, "mark_player"))
	// {
		// if (g_lastVoteCounter < 60 * getTicksASecond()*0
		        // && (!can_skip_wait || g_haveStartedVote))
		// {
			// Menu::addInfoBox(teamkickmenu, "Can't Start Vote", "Voting requires a " + required_minutes + " min wait\n" +
			                 // "after each started vote to\n" +
			                 // "prevent spamming/abuse.\n");
		// }
		// else
		// {
			// Menu::addInfoBox(teamkickmenu, "Vote Team Kick", "Vote to kick a player out of your team.\n\n" +
			                 // "- use responsibly\n" +
			                 // "- report any abuse of this feature.\n" +
			                 // "\nTo Use:\n\n" +
			                 // "- select a reason from the\n     list (default is traitor).\n" +
			                 // "- select a name from the list.\n" +
			                 // "- everyone in your team votes.\n");

			// Menu::addSeparator(teamkickmenu);

			// //reasons
			// for (uint i = 0 ; i < teamkick_reason_count; ++i)
			// {
				// CBitStream params;
				// params.write_u8(i);
				// Menu::addContextItemWithParams(teamkickmenu, teamkick_reason_string[i], "DefaultVotes.as", "Callback_TeamKickReason", params);
			// }

			// Menu::addSeparator(teamkickmenu);

			// //write all players on our team
			// bool added = false;
			// for (int i = 0; i < getPlayersCount(); ++i)
			// {
				// CPlayer@ player = getPlayer(i);

				// //if(player is me) continue; //don't display ourself for kicking
				// //commented out for max lols

				// int player_team = player.getTeamNum();
				
				// // print("Ply: " + player_team + "; Me: " + me.getTeamNum());
				
				// if (player_team == me.getTeamNum() && player_team < 3)
				// {
					// string descriptor = player.getCharacterName();

					// if (player.getUsername() != player.getCharacterName())
						// descriptor += " (" + player.getUsername() + ")";

					// CContextMenu@ usermenu = Menu::addContextMenu(teamkickmenu, "Team Kick " + descriptor);
					// Menu::addInfoBox(usermenu, "Team Kicking " + descriptor, "Make sure you're voting to kick\nthe person you meant.\n");
					// Menu::addSeparator(usermenu);

					// CBitStream params;
					// params.write_u16(player.getNetworkID());

					// Menu::addContextItemWithParams(usermenu, "Yes, I'm sure", "DefaultVotes.as", "Callback_TeamKick", params);
					// added = true;

					// Menu::addSeparator(usermenu);
				// }
			// }

			// if (!added)
			// {
				// Menu::addContextItem(teamkickmenu, "(No-one available)", "DefaultVotes.as", "void CloseMenu()");
			// }
		// }
	// }
	// else
	// {
		// Menu::addInfoBox(teamkickmenu, "Can't vote", "You cannot vote to team kick\n" +
		                 // "players on this server\n");
	// }
	// Menu::addSeparator(teamkickmenu);
	
	//nextmap menu
	if (getSecurity().checkAccess_Feature(me, "map_vote"))
	{
		if (g_lastNextmapCounter < 60 * getTicksASecond() * required_minutes_nextmap
		        && (!can_skip_wait || g_haveStartedVote))
		{
			Menu::addInfoBox(mapmenu, "Can't Start Vote", "Voting for next map\n" +
			                 "requires a " + required_minutes_nextmap + " min wait\n" +
			                 "after each started vote\n" +
			                 "to prevent spamming.\n");
		}
		else
		{
			Menu::addInfoBox(mapmenu, "Vote Next Map Type", "Vote to change the map\nto the next in cycle.\n\n" +
			                 "- Currently requires 65% of players to vote yes\n" +
							 "- You can vote for 3 different types of maps");

			Menu::addSeparator(mapmenu);


			CContextMenu@ offi_map_menu = Menu::addContextMenu(mapmenu, "Official Map");
			CContextMenu@ meme_map_menu = Menu::addContextMenu(mapmenu, "Meme Map");
			CContextMenu@ old_map_menu = Menu::addContextMenu(mapmenu,  "Old Map");


			for (uint i = 0 ; i < nextmap_reason_count; ++i)
			{
				CBitStream params;
				params.write_u8(i);
				params.write_u8(1);
				Menu::addContextItemWithParams(offi_map_menu, nextmap_reason_string[i], "DefaultVotes.as", "Callback_NextMap", params);
			}

			for (uint i = 0 ; i < nextmap_reason_count; ++i)
			{
				CBitStream params;
				params.write_u8(i);
				params.write_u8(2);
				Menu::addContextItemWithParams(meme_map_menu, nextmap_reason_string[i], "DefaultVotes.as", "Callback_NextMap", params);
			}

			for (uint i = 0 ; i < nextmap_reason_count; ++i)
			{
				CBitStream params;
				params.write_u8(i);
				params.write_u8(3);
				Menu::addContextItemWithParams(old_map_menu, nextmap_reason_string[i], "DefaultVotes.as", "Callback_NextMap", params);
			}
		}
	}
	else
	{
		Menu::addInfoBox(mapmenu, "Can't vote", "You cannot vote to change\n" +
		                 "the map on this server\n");
	}
	Menu::addSeparator(mapmenu);
}

void CloseMenu()
{
	Menu::CloseAllMenus();
}

void onPlayerStartedVote()
{
	g_lastVoteCounter = 0;
	g_lastNextmapCounter = 0;
	g_haveStartedVote = true;
}

void Callback_KickReason(CBitStream@ params)
{
	u8 id; if (!params.saferead_u8(id)) return;

	if (id < kick_reason_count)
	{
		g_kick_reason = kick_reason_string[id];
	}
}

void Callback_TeamKickReason(CBitStream@ params)
{
	u8 id; if (!params.saferead_u8(id)) return;

	if (id < teamkick_reason_count)
	{
		g_kick_reason = teamkick_reason_string[id];
	}
}

void Callback_TeamKick(CBitStream@ params)
{
	CloseMenu(); //definitely close the menu

	CPlayer@ me = getLocalPlayer();
	if (me is null) return;

	u16 id;
	if (!params.saferead_u16(id)) return;

	CPlayer@ other_player = getPlayerByNetworkId(id);
	if (other_player is null) return;

	CBitStream params2;

	params2.write_u16(other_player.getNetworkID());
	params2.write_u16(me.getNetworkID());
	params2.write_string(g_kick_reason);

	getRules().SendCommand(getRules().getCommandID(voteteamkick_id), params2);
	onPlayerStartedVote();
}

void Callback_Kick(CBitStream@ params)
{
	CloseMenu(); //definitely close the menu

	CPlayer@ me = getLocalPlayer();
	if (me is null) return;

	u16 id;
	if (!params.saferead_u16(id)) return;

	CPlayer@ other_player = getPlayerByNetworkId(id);
	if (other_player is null) return;

	if (getSecurity().checkAccess_Feature(other_player, "kick_immunity"))
		return;

	CBitStream params2;

	params2.write_u16(other_player.getNetworkID());
	params2.write_u16(me.getNetworkID());
	params2.write_string(g_kick_reason);

	getRules().SendCommand(getRules().getCommandID(votekick_id), params2);
	onPlayerStartedVote();
}

void Callback_NextMap(CBitStream@ params)
{
	CloseMenu(); //definitely close the menu

	CPlayer@ me = getLocalPlayer();
	if (me is null) return;

	u8 id;
	if (!params.saferead_u8(id)) return;

	u8 type;
	if (!params.saferead_u8(type)) return;

	string reason = "";
	if (id < nextmap_reason_count)
	{
		reason = nextmap_reason_string[id];
	}

	CBitStream params2;

	params2.write_u16(me.getNetworkID());
	params2.write_string(reason);
	params2.write_u8(type);

	getRules().SendCommand(getRules().getCommandID(votenextmap_id), params2);
	onPlayerStartedVote();
}

//actually setting up the votes
void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (Rules_AlreadyHasVote(this))
		return;

	if (cmd == this.getCommandID(voteteamkick_id))
	{
		u16 playerid, byplayerid;
		string reason;

		if (!params.saferead_u16(playerid)) return;
		if (!params.saferead_u16(byplayerid)) return;
		if (!params.saferead_string(reason)) return;

		CPlayer@ player = getPlayerByNetworkId(playerid);
		CPlayer@ byplayer = getPlayerByNetworkId(byplayerid);

		if (player !is null && byplayer !is null)
			Rules_SetVote(this, Create_VoteTeamKick(player, byplayer, reason));
	}	
	else if (cmd == this.getCommandID(votekick_id))
	{
		u16 playerid, byplayerid;
		string reason;

		if (!params.saferead_u16(playerid)) return;
		if (!params.saferead_u16(byplayerid)) return;
		if (!params.saferead_string(reason)) return;

		CPlayer@ player = getPlayerByNetworkId(playerid);
		CPlayer@ byplayer = getPlayerByNetworkId(byplayerid);

		if (player !is null && byplayer !is null)
			Rules_SetVote(this, Create_Votekick(player, byplayer, reason));
	}
	else if (cmd == this.getCommandID(votenextmap_id))
	{
		u16 byplayerid;
		string reason;
		u8 maptype;

		if (!params.saferead_u16(byplayerid)) return;
		if (!params.saferead_string(reason)) return;
		if (!params.saferead_u8(maptype)) return;

		CPlayer@ byplayer = getPlayerByNetworkId(byplayerid);

		if (byplayer !is null)
			Rules_SetVote(this, Create_VoteNextmap(byplayer, reason, maptype));

		g_lastNextmapCounter = 0;
	}
}
