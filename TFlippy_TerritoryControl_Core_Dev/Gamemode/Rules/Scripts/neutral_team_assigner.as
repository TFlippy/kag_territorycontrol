#ifndef __neutral_team_assigner
#define __neutral_team_assigner

const uint min_team = 100; //neutrals //getRules().getTeamsNum();
const uint max_team = 250; //chickens

//ok let's be real
//TC is not getting more than 20 players
//entire KAG doesn't have more than 100 players playing at the same time
//which means there's no real reason to implement dynamic team binding/unbinding
//also no reason to respect max team num

uint reserve_team(string playername) {
	if (!isServer()) return min_team;
	if (playername == "jammer312") {
		return max_team - 1; //why not?
	}
	dictionary @bindings;
	CRules @rules = getRules();
	if (!rules.get("_neutral_team_bindings", @bindings)) @bindings = @dictionary();
	uint team = min_team;
	uint tmp; //dictionary::get corrupts handle even if it fails to retrieve data
	if (bindings.get("min", tmp)) team = tmp;
	if (bindings.get("_" + playername, tmp)) team = tmp;
	else {
		bindings.set("_" + playername, team);
		bindings.set("min", team + 1);
		// print("reserving team "+team);
	}
	rules.set("_neutral_team_bindings", @bindings);
	// print("returning team "+team);
	return team;
}

#endif