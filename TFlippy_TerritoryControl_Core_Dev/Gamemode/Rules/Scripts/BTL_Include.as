/// To be included with everything that requires it, this just helps reduce on copy pasted code 

const u8 MAX_BOMBS_PER_TICK = 10; 

bool shouldExplode(CBlob@ this, CRules@ rules)
{
    uint lastGameTime = rules.get_u32("last_exp_tick"); // doesnt matter if it doesnt exist, it'll default to 0 ;)
	u16 explosionCount = rules.add_u16("explosion_count", 1); // u16 because people will always go overkill

	if (lastGameTime != getGameTime())
	{
		explosionCount = 1;

		rules.set_u32("last_exp_tick", getGameTime());
		rules.set_u16("explosion_count", explosionCount); // default to 1 if new tick (since this bomb counts as an explosion)
	}

	if (explosionCount > MAX_BOMBS_PER_TICK) // is this explosion over the limit?
	{
		// OI MATE, YOU GOT A LICENSE FOR THAT BOMB?
		// GO WAIT IN LINE WITH THE REST
		return false;
	}

    return true;
}

void addToNextTick(CBlob@ this, f32 radius, f32 damage, CRules@ rules, explosionHook@ toCall)
{
	BTL[] @bombList;
	if (!rules.get("BTL_DELAY", @bombList))
	{
		@bombList = array<BTL>();
	}

	BTL exp = BTL( this.getDamageOwnerPlayer(), this, radius, damage, toCall);
	bombList.push_back(exp);


	rules.set("BTL_DELAY", bombList);
}

void addToNextTick(CBlob@ this, CRules@ rules, onDieHook@ toCall)
{
	BTL[] @bombList;
	if (!rules.get("BTL_DELAY", @bombList))
	{
		@bombList = array<BTL>();
	}

	BTL exp = BTL( this.getDamageOwnerPlayer(), this, toCall);
	bombList.push_back(exp);


	rules.set("BTL_DELAY", bombList);
}


void addToNextTick(CBlob@ this, CRules@ rules, Vec2f velocity, onDieVelocityHook@ toCall)
{
	BTL[] @bombList;
	if (!rules.get("BTL_DELAY", @bombList))
	{
		@bombList = array<BTL>();
	}
	BTL exp = BTL( this.getDamageOwnerPlayer(), this, velocity, toCall);
	bombList.push_back(exp);

	rules.set("BTL_DELAY", bombList);
}



/// BTL data
funcdef void onDieHook(CBlob@); // sorry, this is the hacky way around without an engine change :)
funcdef void explosionHook(CBlob@, f32, f32); 
funcdef void onDieVelocityHook(CBlob@, Vec2f); 

class BTL
{
	/// Call back hooks are used if original blobs are still alive
	onDieVelocityHook@ VelCallback;
	explosionHook@ ExpCallback; 
	onDieHook@ DieCallback;

	CPlayer@ damage_owner;
	CBlob@ original_blob;

	string blob_name; 
	Vec2f velocity;
	Vec2f position;
	f32 radius;
	f32 damage;
	u32 time; 
	int team;

	BTL () {}

	BTL (CPlayer@ damageOwner, CBlob@ blob, f32 exp_radius, f32 exp_damage, explosionHook@ toCall)
	{
		@damage_owner = damageOwner;
		@original_blob = blob;
		@ExpCallback = toCall;

		SetDeadBlobSettings(blob);

		radius = exp_radius;
		damage = exp_damage;
	}


	BTL (CPlayer@ damageOwner, CBlob@ blob, onDieHook@ toCall)
	{
		@damage_owner = damageOwner;
		@original_blob = blob;
		@DieCallback = toCall;

		SetDeadBlobSettings(blob);
	}

	BTL (CPlayer@ damageOwner, CBlob@ blob, Vec2f bomb_vel, onDieVelocityHook@ toCall)
	{
		@damage_owner = damageOwner;
		@original_blob = blob;
		@VelCallback = toCall;
		velocity = bomb_vel;

		SetDeadBlobSettings(blob);
	}


	void SetDeadBlobSettings(CBlob@ this)
	{
		blob_name = this.getName();
		position = this.getPosition();
		team = this.getTeamNum();
		time = getGameTime();
	}

	bool CallHookPls()
	{
		if (original_blob is null) 
		{
			return false;
		}

		if (DieCallback !is null)
		{
			DieCallback(original_blob);
			return true;
		}
		else if (ExpCallback !is null)
		{
			ExpCallback(original_blob, radius, damage);
			return true;
		}
		else if (VelCallback !is null)
		{
			VelCallback(original_blob, velocity);
			return true;
		}


		return false;
	}
}