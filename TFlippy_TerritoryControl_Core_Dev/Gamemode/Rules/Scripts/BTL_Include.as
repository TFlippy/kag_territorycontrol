/// To be included with everything that requires it, this just helps reduce on copy pasted code


// DISABLED, MESSY DUE TO DEBUGGING NIGHTMARE CAUSED BY ANGELSCRIPT

const u8 MAX_BOMBS_PER_TICK = 10;

bool shouldExplode(CBlob@ this, CRules@ rules)
{
	u16 explosionCount = rules.get_u16("explosion_count");
	if (explosionCount > MAX_BOMBS_PER_TICK) // is this explosion over the limit?
	{
		// OI MATE, YOU GOT A LICENSE FOR THAT BOMB?
		// GO WAIT IN LINE WITH THE REST
		return false;
	}

	rules.add_u16("explosion_count", 1);

	return true;
}

void addToNextTick(CBlob@ this, f32 radius, f32 damage, CRules@ rules, explosionHook@ toCall)
{
 BTL[]@ bombList;

 rules.get("BTL_DELAY", @bombList);

	bombList.push_back(BTL(this.getDamageOwnerPlayer(), this, radius, damage, toCall));

	rules.push("BTL_DELAY", bombList);
}

void addToNextTick(CBlob@ this, CRules@ rules, onDieHook@ toCall)
{
	BTL[]@ bombList;
 rules.get("BTL_DELAY", @bombList);

	bombList.push_back(BTL( this.getDamageOwnerPlayer(), this, toCall));


	rules.push("BTL_DELAY", bombList);
}


void addToNextTick(CBlob@ this, CRules@ rules, Vec2f velocity, onDieVelocityHook@ toCall)
{
	BTL[]@ bombList;
	rules.get("BTL_DELAY", @bombList);

	bombList.push_back(BTL( this.getDamageOwnerPlayer(), this, velocity, toCall));

	rules.push("BTL_DELAY", bombList);
}



/// BTL data
funcdef void onDieHook(CBlob@);
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
