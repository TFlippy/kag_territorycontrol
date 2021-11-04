#include "Survival_Structs.as";

void onInit(CRules@ this)
{
	this.addCommandID("survival_team_sync");

	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	TeamData[] team_list = {TeamData(0), TeamData(1), TeamData(2), TeamData(3), TeamData(4), TeamData(5), TeamData(6)};
	this.set("team_list", @team_list);
	
	// CBitStream stream;
	// this.set_CBitStream("Survival_serialized_team_data", stream);
}

// Too many people complained
// void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
// {
	// if (victim !is null)
	// {
		// u8 team = victim.getTeamNum();
	
		// TeamData@ team_data;
		// GetTeamData(team, @team_data);
		
		// if (team_data !is null)
		// {
			// if (team_data.upkeep > team_data.upkeep_cap)
			// {
				// victim.server_setTeamNum(100 + XORRandom(100));
				// client_AddToChat("Due to " + getRules().getTeam(team).getName() + "'s upkeep being too high, " + victim.getCharacterName() + " had to leave the faction.");
			// }
		// }
	// }
// }

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	//print("new ply");

	if (isServer())
	{
		server_SynchronizeTeams(this);
	}
	
	// if (isClient())
	// {
		// Synchronize(this);
	// }
}

// void Synchronize(CRules@ this)
// {
	// CBitStream stream;
	// this.get_CBitStream("Survival_serialized_team_data", stream);
	
	// // print("stream len: " + stream.getBytesUsed());
	
	// if (stream.getBytesUsed() == 0)
	// {
		// print("team sync stream is empty");
		// return;
	// }
	
	// TeamData[]@ team_list;

	// this.get("team_list", @team_list);
	// u8 maxTeams = team_list.length;
	
	// if (team_list !is null)
	// {	
		// for (u32 i = 0; i < team_list.length; i++) 
		// {
			// team_list[i].Deserialize(stream);
		// }
	// }
// }

// bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
// {
	// if (player.getTeamNum() < 7)
	// {
		// TeamData@ team_data;
		// GetTeamData(player.getTeamNum(), @team_data);
	
		// bool isLeader = player.getUsername() == team_data.leader_name;
		// if (isLeader)
		// {
			// text_out = "[Leader] " + text_in;
		// }
	// }
	
	// return true;
// }

void onCommand(CRules@ this, u8 cmd, CBitStream@ stream)
{
	if (cmd == this.getCommandID("survival_team_sync"))
	{
		// print("team sync stream len: " + stream.getBytesUsed());
	
		if (stream.getBytesUsed() == 0)
		{
			// print("team sync stream is empty");
			return;
		}
		
		TeamData[]@ team_list;

		this.get("team_list", @team_list);
		u8 maxTeams = team_list.length;
		
		if (team_list !is null)
		{	
			for (u32 i = 0; i < team_list.length; i++) 
			{
				team_list[i].Deserialize(stream);
			}
		}
	}
}

void server_SynchronizeTeams(CRules@ this)
{
	if (isServer())
	{
		TeamData[]@ team_list;
		this.get("team_list", @team_list);
		
		if (team_list !is null)
		{
			u8 maxTeams = team_list.length;
			CBitStream stream;
				
			for (u32 i = 0; i < team_list.length; i++) 
			{
				TeamData@ team = team_list[i];
				
				string leaderName = team.leader_name;
				CPlayer@ leader = getPlayerByUsername(leaderName);
				
				if (team.player_count == 0) team_list[i].recruitment_enabled = true; // If the leader disconnects
				if (!(leader !is null && leader.getTeamNum() == i)) team.leader_name = ""; // If the leader disconnects
				
				team.Serialize(stream);
			}
			
			this.SendCommand(this.getCommandID("survival_team_sync"), stream);
		}
	}
}

void onTick(CRules@ this)
{
	// if (isClient() && !isServer())
	// {
		// Synchronize(this);
	// }

	if (getGameTime() % 15 == 0)
	{
		TeamData[]@ team_list;

		this.get("team_list", @team_list);
		u8 maxTeams = team_list.length;
		
		if (team_list !is null)
		{	
			for (u32 i = 0; i < team_list.length; i++) 
			{
				TeamData@ team = team_list[i];

				team.upkeep = 0;
				team.upkeep_cap = 1;
				team.player_count = 0;
				team.wealth = 0;
				team.controlled_count = 0;
			}
				
			for (u32 i = 0; i < getPlayersCount(); i++)
			{
				CPlayer@ p = getPlayer(i);
				
				if (p !is null)
				{
					u8 team = p.getTeamNum();
					if (team >= maxTeams) continue;
					
					team_list[team].upkeep += 0; //+ (team_list[team].player_count * 5);
					team_list[team].player_count++;
					team_list[team].wealth += p.getCoins();
				}
			}
		
			CBlob@[] buildings;
			if (getBlobsByTag("upkeep building", @buildings))
			{
				for (u32 i = 0; i < buildings.length; i++)
				{
					CBlob@ blob = buildings[i];
					u8 team = blob.getTeamNum();
					
					if (team > maxTeams) continue;
										
					team_list[team].upkeep += blob.get_u8("upkeep cost");
					team_list[team].upkeep_cap += blob.get_u8("upkeep cap increase");
				}
			}
				
			CBlob@[] capturables;
			if (getBlobsByTag("capturable", @capturables))
			{
				this.set_u16("total_capturables", capturables.length);
			
				for (u32 i = 0; i < capturables.length; i++)
				{
					CBlob@ blob = capturables[i];
					u8 team = blob.getTeamNum();
					
					if (team > maxTeams) continue;
										
					team_list[team].controlled_count++;
				}
			}
			
			CBlob@[] slaves;
			if (getBlobsByName("slave", @slaves))
			{
				for (u32 i = 0; i < slaves.length; i++)
				{
					CBlob@ blob = slaves[i];
					u8 slaver_team = blob.get_u8("slaver_team");
	
					if (slaver_team > maxTeams) continue;
					if (!blob.hasTag("dead")) team_list[slaver_team].upkeep += 1;
				}
			}
				
			if (isServer())
			{
				server_SynchronizeTeams(this);
			
				// CBitStream stream;
					
				// for (u32 i = 0; i < team_list.length; i++) 
				// {
					// TeamData@ team = team_list[i];
					
					// string leaderName = team.leader_name;
					// CPlayer@ leader = getPlayerByUsername(leaderName);
					
					// if (team.player_count == 0) team_list[i].recruitment_enabled = true; // If the leader disconnects
					// if (!(leader !is null && leader.getTeamNum() == i)) team.leader_name = ""; // If the leader disconnects
					
					// team.Serialize(stream);
				// }
				
				// this.SendCommand(this.getCommandID("survival_team_sync"), stream);
				
				// // this.set_CBitStream("Survival_serialized_team_data", stream);
			}
		}
	}
}

