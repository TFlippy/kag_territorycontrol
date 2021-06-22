// shared class PersistentPlayerInfo
// {
	// string name;
	// u8 team;
	// u32 teamkick_time;
	// u32 coins;

	// PersistentPlayerInfo() { Setup("", 255); }
	// PersistentPlayerInfo(string _name, u8 _team) { Setup(_name, _team); }

	// void Setup(string _name, u8 _team)
	// {
		// name = _name;
		// team = _team;
		// coins = 0;
		// teamkick_time = 0;
	// }

	// // PersistentPlayerInfo() { Setup("", 0); }
	// // PersistentPlayerInfo(string _name, u8 _team) { Setup(_name, _team); }

	// // void PersistentPlayerInfo(string _name, u8 _team)
	// // {
		// // name = _name;
		// // team = _team;
	// // }
// };

const u16 UPKEEP_COST_PLAYER = 1;

const f32 UPKEEP_RATIO_BONUS_COIN_GAIN = 0.40f;
const f32 UPKEEP_RATIO_BONUS_MINING = 0.45f;
const f32 UPKEEP_RATIO_BONUS_SPEED = 0.50f;
const f32 UPKEEP_RATIO_BONUS_RESPAWN_TIME = 0.65f;

const f32 UPKEEP_RATIO_PENALTY_RECRUITMENT = 1.00f;
const f32 UPKEEP_RATIO_PENALTY_RESPAWN_TIME = 1.25f;
const f32 UPKEEP_RATIO_PENALTY_COIN_DROP = 1.50f;
const f32 UPKEEP_RATIO_PENALTY_STORAGE = 2.00f;
const f32 UPKEEP_RATIO_PENALTY_SPEED = 2.50f;

shared class TeamData
{
	TeamData(u8 inTeam) 
	{ 
		Setup(inTeam); 
	}

	u8 team;
	u16 upkeep;
	u16 upkeep_cap;
	u32 wealth;
	u16 controlled_count;

	string leader_name;
	string team_name;

	bool recruitment_enabled;
	bool lockdown_enabled;
	bool tax_enabled;
	bool storage_enabled;
	bool f2p_enabled;
	bool slavery_enabled;
	bool reserved_1_enabled;
	bool reserved_2_enabled;

	u16 player_count;

	void Setup(u8 inTeam)
	{
		team = inTeam;
		upkeep = 0;
		upkeep_cap = 10;
		wealth = 0;
		controlled_count = 0;

		leader_name = "";
		team_name = "";
		recruitment_enabled = true;
		lockdown_enabled = true;
		tax_enabled = false;
		bool f2p_enabled = true;
		storage_enabled = true;
		slavery_enabled = true;

		player_count = 0;
	}

	void Serialize(CBitStream@ stream)
	{
		if (stream is null)
		{
			print("Failed to serialize team " + team);
			return;
		}

		stream.write_u8(team);
		stream.write_string(leader_name);

		u8 flags = 0;
		if (recruitment_enabled) flags |= 1 << 0; 
		if (lockdown_enabled) flags |= 1 << 1; 
		if (tax_enabled) flags |= 1 << 2; 
		if (storage_enabled) flags |= 1 << 3; 
		if (f2p_enabled) flags |= 1 << 4; 
		if (slavery_enabled) flags |= 1 << 5; 
		if (reserved_1_enabled) flags |= 1 << 6; 
		if (reserved_2_enabled) flags |= 1 << 7; 

		stream.write_u8(flags);
	}

	void Deserialize(CBitStream@ stream)
	{
		if (stream is null)
		{
			print("Failed to deserialize a team");
			return;
		}

		team = stream.read_u8();
		leader_name = stream.read_string();
		u8 flags = stream.read_u8();

		recruitment_enabled = flags & (1 << 0) > 0;
		lockdown_enabled = flags & (1 << 1) > 0;
		tax_enabled = flags & (1 << 2) > 0;
		storage_enabled = flags & (1 << 3) > 0;

		// print("team: " + team);
		// print("leader: " + leader_name);
		// print("flags: " + flags);
		// print("recruitment: " + recruitment_enabled);
		// print("lockdown: " + lockdown_enabled);
		// print("tax: " + tax_enabled);
		// print("storage: " + storage_enabled);
		// print("");
	}
};

void GetTeamData(u8 team, TeamData@ &out data)
{
	TeamData[]@ team_list;
	getRules().get("team_list", @team_list);

	if (team_list !is null && team < team_list.length)
	{
		@data = team_list[team];
	}
}

const string GetTeamName(u8 team_num) //returns the given team's name
{
	TeamData@ team_data;
	GetTeamData(team_num, @team_data);
	if (team_data !is null)
	{
		if (team_data.team_name != "") return team_data.team_name; //Use custom name
	}
	return getRules().getTeam(team_num).getName(); //Standard name
}
