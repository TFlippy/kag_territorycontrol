
//the respawn system interface, provides some sane default functions
//  but doesn't spawn players on its own (so you can plug your own implementation)

// designed to work in tandem with a rulescore
//  to get playerinfos and whatnot from usernames reliably and to hold team info
//  can be designed to work without one of course.

#include "PlayerInfo"

shared class RespawnSystem
{

	private RulesCore@ core;

	RespawnSystem() { @core = null; }

	void Update() { /* OVERRIDE ME */ }

	void AddPlayerToSpawn(CPlayer@ player)  { /* OVERRIDE ME */ }

	void RemovePlayerFromSpawn(CPlayer@ player) { /* OVERRIDE ME */ }

	void SetCore(RulesCore@ _core) { @core = _core; }

	//the actual spawn functions
	CBlob@ SpawnPlayerIntoWorld(Vec2f at, PlayerInfo@ p_info)
	{
		CPlayer@ player = getPlayerByUsername(p_info.username);
		string blobType = p_info.blob_name;
		
		if (blobType == "builder" || blobType == "engineer" || blobType == "hazmat" || blobType == "slave" || blobType == "peasant") blobType = "builder";
		else if (blobType == "archer") blobType = "archer";
		else blobType = "knight";

		if (player !is null)
		{
			CBlob @newBlob = server_CreateBlob(blobType, p_info.team, at);
			newBlob.server_SetPlayer(player);
			player.server_setTeamNum(p_info.team);
			return newBlob;
		}

		return null;
	}

	//suggested implementation, doesn't have to be used of course
	void DoSpawnPlayer(PlayerInfo@ p_info)
	{
		if (canSpawnPlayer(p_info))
		{
			CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

			if (player is null)
			{
				return;
			}

			SpawnPlayerIntoWorld(getSpawnLocation(p_info), p_info);
			RemovePlayerFromSpawn(player);
		}
	}

	bool canSpawnPlayer(PlayerInfo@ p_info)
	{
		/* OVERRIDE ME */
		return true;
	}

	Vec2f getSpawnLocation(PlayerInfo@ p_info)
	{
		/* OVERRIDE ME */
		return Vec2f();
	}

	/*
	 * Override so rulescore can re-add when appropriate
	 */
	bool isSpawning(CPlayer@ player)
	{
		return false;
	}


};
