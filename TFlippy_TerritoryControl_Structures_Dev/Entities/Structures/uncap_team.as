#include "neutral_team_assigner.as"

#ifndef __uncap_team
#define __uncap_team
const uint pure_neutral_team = 255;

void uncap_team(uint teamnum, uint target_team = pure_neutral_team) {
	if (!isServer()) return;

	TeamData[]@ team_list;
	getRules().get("team_list", @team_list);
	if (team_list !is null)
	{
		if (team_list.size() > teamnum && team_list[teamnum].player_count < 3)
		{
			peasant_team(teamnum, target_team);
			return;
		}
	}
		

	//non-players get converted to chicken faction
	CBlob@[] blobs;
	getBlobsByTag("capturable", @blobs);
	getBlobsByTag("noncapturable", @blobs);
	getBlobsByTag("change team on fort capture", @blobs); //is it even needed? doors n stuff, maybe something else (but also collides with capturable)
	for (int i = 0; i < blobs.length; ++i) {
		if (blobs[i].getTeamNum() != teamnum) continue;
		blobs[i].server_setTeamNum(target_team);
	}

	//players get neutralized
	CBlob@[] players;
	getBlobsByTag("player", @players);
	for (int i = 0; i < players.length; ++i) {
		if (players[i].getTeamNum() != teamnum) continue;
		uint team = target_team;
		CPlayer @player = players[i].getPlayer();
		if (player !is null)
			team = reserve_team(player.getUsername().split('~')[0]);
		else if (players[i].hasTag("sleeper") && players[i].get_string("sleeper_name") != "")
			team = reserve_team(players[i].get_string("sleeper_name"));
		players[i].server_setTeamNum(team);
		if (player !is null) player.server_setTeamNum(team);
	}
}


void peasant_team(uint teamnum, uint target_team = pure_neutral_team) {
	if (!isServer()) return;

	//non-players get converted to chicken faction
	CBlob@[] blobs;
	getBlobsByTag("capturable", @blobs);
	getBlobsByTag("noncapturable", @blobs);
	getBlobsByTag("change team on fort capture", @blobs); //is it even needed? doors n stuff, maybe something else (but also collides with capturable)
	for (int i = 0; i < blobs.length; ++i) {
		if (blobs[i].getTeamNum() != teamnum) continue;
		blobs[i].server_setTeamNum(target_team);
	}

	//players get neutralized
	CBlob@[] players;
	getBlobsByTag("player", @players);
	for (int i = 0; i < players.length; ++i) {
		if (players[i].getTeamNum() != teamnum) continue;
		uint team = target_team;
		CPlayer @player = players[i].getPlayer();
		if (player !is null)
			team = reserve_team(player.getUsername().split('~')[0]);
		else if (players[i].hasTag("sleeper") && players[i].get_string("sleeper_name") != "")
			team = reserve_team(players[i].get_string("sleeper_name"));
		players[i].server_setTeamNum(team); 

		if (player !is null) { 

			player.server_setTeamNum(team);
			CBlob@ blob = player.getBlob();

			if (blob !is null) 
			{
				if (blob.getName() != "builder") { return; }
				CBlob@ tempo = server_CreateBlob("peasant", team, blob.getPosition());
				if (tempo is null) { return; } // we tried :(
				
				tempo.server_SetPlayer(player);
				blob.server_Die();
			}
		}
	}
}


#endif