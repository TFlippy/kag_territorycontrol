namespace Strategy
{
	enum strategy_type
	{
		idle = 0,       // will move and or choose to relocate to a new pos
		searching,      // will search for a new target every so often based on line of sight (?)
		relocating,     // will relocate to a new pos based on given info, tries to not fight or search while doing this
		attack,         // attacks, without being overly agressive
		hold_off,       // attacks if player gets too close, used when defending
		last_stand,     // attacks with no regret, used when chicken is about to die, does not care about cover
		retreat,        // some may retreat if no allies, hurt, or player is rushing in with bombs
		victory,        // chicken may celebrate with another nearby chicken after fighting (?)
	}
}

void InitBrain(CBrain@ this)
{
	CBlob@ blob = this.getBlob();

	blob.set_u8("strategy", Strategy::idle);
}


u8 getStrat(CBlob@ this)
{
	return this.get_u8("strategy");
}

bool inAttackStrat(CBlob@ this)
{
	switch (this.get_u8("stratergy"))
	{
		case Strategy::attack:
		case Strategy::hold_off:
		case Strategy::last_stand:
		case Strategy::retreat:
			return true;
	}

	return false;
}

bool inPassiveStrat(CBlob@ this)
{
	switch (this.get_u8("stratergy"))
	{
		case Strategy::idle:
		case Strategy::searching:
		case Strategy::relocating:
		case Strategy::victory:
			return true;
	}

	return false;
}

void SuggestedKeys(CBrain@ brain, CBlob@ blob)
{

	/*float val = (blob.getPosition() - brain.getPathPositionAtIndex(brain.path_index + 1)).Length();

	if (val < 8 && brain.path_index !=) {
		brain.path_index += 1;
	}

	print(brain.path_index + '');*/

	Vec2f pos = blob.getPosition();
	Vec2f pathPos = brain.getPathPosition();
	
	const Vec2f dir = pathPos - pos;

	if (pathPos.x == 0 && pathPos.y == 0)
		return;

	/*print("X: " + pathPos.x + " | " + dir.x + 
		"\nY: " + pathPos.y + " | " + dir.y);
	*/
	//print(blob.getPosition().x + " | " + blob.getPosition().y);
	//print(val + '');
	//print(brain.path_index + '');

	//print(brain.getPathPosition().x + " | " + brain.getPathPosition().y);

	// Do we need to move left and or right
	blob.setKeyPressed(key_left, dir.x < -0.0f);
	blob.setKeyPressed(key_right, dir.x > 0.0f);
	blob.setKeyPressed(key_up, dir.y < -4.0f);
	blob.setKeyPressed(key_down, dir.y > 0.0f);
}

/*
void OldMove(CBlob@ blob, Vec2f pos)
{
	Vec2f dir = blob.getPosition() - pos;
	print(dir.x + " | " + dir.y);

	blob.setKeyPressed(key_left, dir.x > 4.0f);
	blob.setKeyPressed(key_right, dir.x < -4.0f);
	blob.setKeyPressed(key_up, dir.y > 4.0f);
	blob.setKeyPressed(key_down, dir.y < -4.0f);
}
*/
