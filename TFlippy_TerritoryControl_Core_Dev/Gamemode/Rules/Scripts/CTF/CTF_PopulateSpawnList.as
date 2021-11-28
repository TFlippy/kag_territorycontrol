// get spawn points for CTF

#include "HallCommon.as"

shared void PopulateSpawnList(CBlob@[]@ respawns, const int teamNum)
{
	CBlob@[] posts;
	getBlobsByTag("respawn", @posts);

	for (uint i = 0; i < posts.length; i++)
	{
		CBlob@ blob = posts[i];

		if (teamNum >= 100 ? (blob.getTeamNum() >= 100) : (blob.getTeamNum() == teamNum))
		{
			respawns.push_back(blob);
		}
	}
}
