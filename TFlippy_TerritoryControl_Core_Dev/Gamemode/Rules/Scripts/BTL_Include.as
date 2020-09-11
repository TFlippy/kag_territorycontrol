/// To be included with everything that requires it, this just helps reduce on copy pasted code 

const u8 MAX_BOMBS_PER_TICK = 10; 

bool shouldExplode(CBlob@ this, f32 radius, f32 damage, CRules@ rules)
{
    uint lastGameTime = rules.get_u32("last_exp_tick"); // doesnt matter if it doesnt exist, it'll default to 0 ;)
	u16 explosionCount = rules.add_u16("explosion_count", 1); // u16 because people will always go overkill

	if (lastGameTime != getGameTime())
	{
		explosionCount = 1;

		rules.set_u32("last_exp_tick", getGameTime());
		rules.set_u16("explosion_count", explosionCount); // default to 1 if new tick (since this bomb counts as an explosion)
	}

	BTL[] @bombList;
	if (!rules.get("BTL_DELAY", @bombList))
	{
		@bombList = array<BTL>();
	}

	if (explosionCount > MAX_BOMBS_PER_TICK) // is this explosion over the limit?
	{
		// OI MATE, YOU GOT A LICENSE FOR THAT BOMB?
		// GO WAIT IN LINE WITH THE REST
		bombList.push_back( BTL( this.getDamageOwnerPlayer(), this, radius, damage) );

		rules.set("BTL_DELAY", @bombList);

		return false;
	}

    return true;
}


/// BTL data

class BTL
{
	CPlayer@ explosion_owner;
	CBlob@ explosion_host;
	string blob_name; // used if explosion_host is dead
	Vec2f position;
	f32 radius;
	f32 damage;
	u32 time; 
	int team;

	BTL(){}

	BTL(CPlayer@ explosion_owner, CBlob@ this, f32 explosion_radius, f32 explosion_damage)
	{
		if (this.getTicksToDie() == -1) // is this item going to die this tick
		{
			blob_name = this.getName(); // lets clone it when we are going to re-explode it, i'll optimize this later (engine side or script side)
		}
		else
		{
			@explosion_host = this;
		}

		@explosion_owner = this.getDamageOwnerPlayer();
		position = this.getPosition();
		radius = explosion_radius;
		damage = explosion_damage;
		time = getGameTime();
		team = this.getTeamNum();
	}
}