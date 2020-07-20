#include "neutral_team_assigner.as"

#ifndef __uncap_team
#define __uncap_team

void uncap_team(uint teamnum) {
	if (!isServer()) return;

	//non-players get converted to chicken faction
	const uint chicken_team = 250;
	const uint pure_neutral_team = 255;
	CBlob@[] blobs;
	getBlobsByTag("capturable", @blobs);
	getBlobsByTag("noncapturable", @blobs);
	getBlobsByTag("change team on fort capture", @blobs); //is it even needed? doors n stuff, maybe something else (but also collides with capturable)
	for (int i = 0; i < blobs.length; ++i) {
		if (blobs[i].getTeamNum() != teamnum) continue;
		blobs[i].server_setTeamNum(blobs[i].hasTag("door") ? pure_neutral_team : chicken_team);
	}

	//players get neutralized
	CBlob@[] players;
	getBlobsByTag("player", @players);
	for (int i = 0; i < players.length; ++i) {
		if (players[i].getTeamNum() != teamnum) continue;
		uint team = chicken_team; //turn them into chickens if all else fails
		CPlayer @player = players[i].getPlayer();
		if (player !is null)
			team = reserve_team(player.getUsername().split('~')[0]);
		else if (players[i].hasTag("sleeper") && players[i].get_string("sleeper_name") != "")
			team = reserve_team(players[i].get_string("sleeper_name"));
		players[i].server_setTeamNum(team);
		if (player !is null) player.server_setTeamNum(team);
	}
}

#endif