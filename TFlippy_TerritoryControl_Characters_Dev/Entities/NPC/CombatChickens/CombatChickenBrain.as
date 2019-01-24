#include "BrainCommon.as"
#include "Hitters.as";
#include "RunnerCommon.as";

void onInit( CBrain@ this )
{
	if (getNet().isServer())
	{
		InitBrain( this );
		this.server_SetActive( true ); // always running
		this.getBlob().set_u32("next_repath", getGameTime() + XORRandom(30));
		this.getBlob().set_u32("next_search", getGameTime() + XORRandom(30));
		
		// this.failtime_end = 15;
		this.plannerSearchSteps = 25;
		this.lowLevelSteps = 25;
	}
}

void onTick(CBrain@ this)
{
	if (!getNet().isServer()) return;
	
	CBlob@ blob = this.getBlob();
	
	if (blob.getPlayer() !is null) return;
	
	// SearchTarget(this, false, true);
	
	CBlob@ target = this.getTarget();
	
	const f32 chaseDistance = blob.get_f32("chaseDistance");
	
	const u32 next_repath = blob.get_u32("next_repath");
	const u32 next_search = blob.get_u32("next_search");
	
	const bool can_repath = getGameTime() >= next_repath;
	const bool can_search = getGameTime() >= next_search && target is null;
	const f32 maxDistance = blob.get_f32("maxDistance");

	bool stuck = false;
	
	if (this.getState() == 4)
	{
		blob.set_bool("stuck", true);
		stuck = true;
	}
	else
	{
		stuck = blob.get_bool("stuck");
	}
	
	// print("" + stuck);
	
	// print("" + this.getCurrentScript().tickFrequency);
	
	// this.failtime_end = 15;
	// this.plannerSearchSteps = 25;
	// this.lowLevelSteps = 25;
	
	
	
	// CBlob@ t = getLocalPlayerBlob();
	// CBlob@ t = getBlobByName("camp");
	// if (t !is null && getGameTime() % 30 == 0) 
	// {	
		// this.SetHighLevelPath(blob.getPosition(), t.getPosition());
		// // this.SetLowLevelPath(blob.getPosition(), t.getPosition());
		// // this.SetPathTo(t.getPosition(), false);
	// }
	
	// print("" + this.plannerSearchSteps);
	
	if (target is null)
	{	
		const bool raider = blob.get_bool("raider");
		const Vec2f pos = blob.getPosition();
	
		if (can_search)
		{
			this.getCurrentScript().tickFrequency = 30;
			
			// print("search");
			
			CBlob@[] blobs;
			getMap().getBlobsInRadius(blob.getPosition(), chaseDistance, @blobs);
			f32 chaseDistanceSqr = chaseDistance * chaseDistance;
			
			// getBlobsByTag("human", @blobs);
			const u8 myTeam = blob.getTeamNum();
			
			for (int i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];
				Vec2f bp = b.getPosition() - pos;
				f32 d = bp.LengthSquared();
				
				// print("" + d);
				
				if (b.getTeamNum() != myTeam && d <= chaseDistanceSqr && !b.hasTag("dead") && b.hasTag("flesh") && !b.hasTag("invincible") && (isVisible(blob, b) || d < (48 * 48)))
				{
					this.SetTarget(b);
					blob.set_u32("nextAttack", getGameTime() + blob.get_u8("reactionTime"));
					
					this.getCurrentScript().tickFrequency = 1;
					
					// print("found");
					return;
				}
			}
		}

		
		// print(blob.getConfig() + stuck);
		
		if (raider)
		{
			CBlob@ raid_target = getBlobByNetworkID(blob.get_u16("raid target"));
			if (raid_target !is null)
			{
				const f32 distance = (raid_target.getPosition() - blob.getPosition()).Length();
			
				if (can_repath && distance > 16) 
				{
					this.SetPathTo(raid_target.getPosition(), false);
					blob.set_u32("next_repath", getGameTime() + 45 + XORRandom(45));
				}
				
				Vec2f dir = this.getNextPathPosition() - blob.getPosition();
				dir.Normalize();
				
				Move(this, blob, blob.getPosition() + dir * 24);
			
				if (stuck)
				{
					const f32 minDistance = blob.get_f32("minDistance");
					const f32 maxDistance = blob.get_f32("maxDistance");
				
					if (distance > minDistance && distance < maxDistance)
					{
						Attack(this, raid_target, false);
					}
				}
				
				this.getCurrentScript().tickFrequency = 1;
			}
			else
			{
				CBlob@[] bases;
				getBlobsByTag("faction_base", @bases);
			
				if (bases.length > 0) 
				{
					blob.set_u16("raid target", bases[XORRandom(bases.length)].getNetworkID());
					this.getCurrentScript().tickFrequency = 1;
				}
			}
		}
		else this.getCurrentScript().tickFrequency = 15;
	}
	
	if (target !is null && target !is blob)
	{			
		// print("" + target.getConfig());
	
		this.getCurrentScript().tickFrequency = 1;
		
		// print("" + this.lowLevelMaxSteps);
		
		const f32 distance = (target.getPosition() - blob.getPosition()).Length();
		const f32 minDistance = blob.get_f32("minDistance");
		

		const bool visibleTarget = isVisible(blob, target);
		
		const bool target_attackable = !(target.getTeamNum() == blob.getTeamNum() || target.hasTag("material"));
		const bool lose = distance > maxDistance;
		const bool chase = target_attackable && (distance > chaseDistance || !visibleTarget);
		const bool retreat = !target_attackable || ((distance < minDistance) && visibleTarget);
		
		if (lose)
		{
			ResetTarget(this);
			this.getCurrentScript().tickFrequency = 15;
			return;
		}
		
		if (target_attackable)
		{
			if (visibleTarget) 
			{
				Attack(this, target, true);
			}
			else if (stuck || distance < 64)
			{
				Attack(this, target, false);
			}
		}
		
		if (target_attackable && chase)
		{
			if (can_repath) 
			{	
				this.SetPathTo(target.getPosition(), false);
				blob.set_u32("next_repath", getGameTime() + 15 + XORRandom(15));
			}
			// if (getGameTime() % 45 == 0) this.SetHighLevelPath(blob.getPosition(), target.getPosition());
			// Move(this, blob, this.getNextPathPosition());
			// print("chase")
			
			Vec2f dir = this.getNextPathPosition() - blob.getPosition();
			dir.Normalize();
			
			if (!visibleTarget)
			{
				Move(this, blob, blob.getPosition() + dir * 24);
			}
			else 
			{
				Move(this, blob, target.getPosition());
			}
			
			// Move(this, blob, blob.getPosition() + dir * 16);
		}
		else if (retreat)
		{
			DefaultRetreatBlob(blob, target);
			// print("retreat");
		}

		if (target.hasTag("dead")) 
		{
			CPlayer@ targetPlayer = target.getPlayer();
			
			if (targetPlayer !is null && target.hasTag("dead"))
			{
				blob.set_u16("stolen coins", blob.get_u16("stolen coins") + (targetPlayer.getCoins() * 0.9f));
			}
		
			ResetTarget(this);
			this.getCurrentScript().tickFrequency = 30;
			return;
		}
	}
	else
	{
		if (XORRandom(2) == 0) RandomTurn(blob);		
	}

	FloatInWater(blob); 
} 

void ResetTarget(CBrain@ this)
{
	CBlob@ blob = this.getBlob();

	this.SetTarget(null);
	blob.set_bool("stuck", false);
}

void Attack(CBrain@ this, CBlob@ target, bool useBombs)
{
	CBlob@ blob = this.getBlob();

	blob.setAimPos(target.getPosition());
	// const f32 reactionTime = blob.get_f32("reactionTime");

	if (blob.get_u32("nextAttack") < getGameTime())
	{
		AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
		
		if (point !is null) 
		{
			CBlob@ gun = point.getOccupied();
			if (gun !is null) 
			{
				if (blob.get_u32("nextAttack") < getGameTime())
				{							
					f32 dist = (target.getPosition() - blob.getPosition()).Length();
					f32 jitter = blob.get_f32("inaccuracy") * Maths::Sqrt(dist);
					
					// print("jitter " + Maths::Sqrt(dist));
					
					Vec2f randomness = Vec2f((100 - XORRandom(200)) * jitter, (100 - XORRandom(200)) * jitter);
				
					blob.setAimPos(target.getPosition() + randomness);
					blob.setKeyPressed(key_action1, true);
					blob.set_u32("nextAttack", getGameTime() + blob.get_u8("attackDelay"));
				}
				else
				{
					blob.setKeyPressed(key_action1, false);
				}
			}
		}
	}
	else if (useBombs && blob.get_bool("bomber") && blob.get_u32("nextBomb") < getGameTime())
	{
		if (XORRandom(100) < 2)
		{
			CBlob@ bomb = server_CreateBlob("bomb", blob.getTeamNum(), blob.getPosition());
			if (bomb !is null)
			{
				Vec2f dir = blob.getAimPos() - blob.getPosition();
				f32 dist = dir.Length();
				
				dir.Normalize();
				
				bomb.setVelocity((dir * (dist * 0.4f)) + Vec2f(0, -5));
				blob.set_u32("nextBomb", getGameTime() + 600);
			}
		}
	}
}


void Move(CBrain@ this, CBlob@ blob, Vec2f pos)
{
	Vec2f dir = blob.getPosition() - pos;
	// f32 dist = dir.getLength();
	
	// dir.Normalize();

	// print("DIR: x: " + dir.x + "; y: " + dir.y);

	// if (dist > 16) blob.SetFacingLeft(dir.x > 0);
	
	blob.setKeyPressed(key_left, dir.x > 0);
	blob.setKeyPressed(key_right, dir.x < 0);
	blob.setKeyPressed(key_up, dir.y > 0);
	blob.setKeyPressed(key_down, dir.y < 0);
}