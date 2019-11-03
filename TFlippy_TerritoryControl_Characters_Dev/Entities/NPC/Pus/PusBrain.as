#include "BrainCommon.as"
#include "Hitters.as";
#include "RunnerCommon.as";

void onInit( CBrain@ this )
{
	if (isServer())
	{
		InitBrain( this );
		this.server_SetActive( true ); // always running
	}
}

CBlob@ FindTarget(CBrain@ this, f32 maxDistance)
{
	CBlob@ blob = this.getBlob();
	const Vec2f pos = blob.getPosition();
	
	CBlob@[] blobs;
	getMap().getBlobsInRadius(blob.getPosition(), maxDistance, @blobs);
	const u8 myTeam = blob.getTeamNum();
	
	for (int i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];
		Vec2f bp = b.getPosition() - pos;
		f32 d = bp.Length();

		if (b.getTeamNum() != myTeam && d <= maxDistance && !b.hasTag("dead") && b.hasTag("flesh") && !b.hasTag("invincible") && isVisible(blob, b))
		{
			return b;
		}
	}
	
	return null;
}

void onTick(CBrain@ this)
{
	if (!isServer()) return;
	
	CBlob@ blob = this.getBlob();
	
	if (blob.getPlayer() !is null) return;
	
	const f32 chaseDistance = blob.get_f32("chaseDistance");
	const f32 maxDistance = blob.get_f32("maxDistance");
	
	CBlob@ target = this.getTarget();

	// print("" + target.getName()
	
	if (target is null)
	{
		this.SetTarget(FindTarget(this, maxDistance));
		this.getCurrentScript().tickFrequency = 1;
	}
	
	if (target !is null && target !is blob)
	{			
		// print("" + target.getName()
	
		this.getCurrentScript().tickFrequency = 1;
		
		// print("" + this.lowLevelMaxSteps);
		
		const f32 distance = (target.getPosition() - blob.getPosition()).Length();
		const f32 minDistance = blob.get_f32("minDistance");
		
		const bool visibleTarget = isVisible(blob, target);
		const bool stuck = this.getState() == 4;
		const bool target_attackable = target !is null && !(target.getTeamNum() == blob.getTeamNum() || target.hasTag("material"));
		const bool lose = distance > maxDistance;
		const bool chase = target_attackable && distance > minDistance;
		const bool retreat = !target_attackable || ((distance < minDistance) && visibleTarget);
		
		// print("" + stuck);
		
		if (lose)
		{
			this.SetTarget(null);
			this.getCurrentScript().tickFrequency = 15;
			return;
		}
		
		blob.setAimPos(target.getPosition());
		
		if (blob.get_u32("nextAttack") < getGameTime() && (stuck || (visibleTarget ? distance <= 32 : true)))
		{
			blob.setKeyPressed(key_action1, true);
		}
		else
		{
			blob.setKeyPressed(key_action1, false);
		}
		
		if (target_attackable && chase)
		{
			if (blob.getTickSinceCreated() % 90 == 0) this.SetPathTo(target.getPosition(), true);
			// if (getGameTime() % 45 == 0) this.SetHighLevelPath(blob.getPosition(), target.getPosition());
			// Move(this, blob, this.getNextPathPosition());
			// print("chase")
			
			Vec2f dir = this.getNextPathPosition() - blob.getPosition();
			dir.Normalize();
			
			if (distance > 64 && !visibleTarget)
			{
				Move(this, blob, blob.getPosition() + dir * 24);
			}
			else 
			{
				Move(this, blob, target.getPosition());
			}
		}
		else if (retreat)
		{
			DefaultRetreatBlob( blob, target );
		}

		if (distance > chaseDistance && !visibleTarget)
		{
			this.SetTarget(FindTarget(this, maxDistance));
		}
		
		if (target.hasTag("dead") && !visibleTarget)
		{
			CPlayer@ targetPlayer = target.getPlayer();
					
			this.SetTarget(null);
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

void Move(CBrain@ this, CBlob@ blob, Vec2f pos)
{
	Vec2f dir = blob.getPosition() - pos;
	dir.Normalize();

	// print("DIR: x: " + dir.x + "; y: " + dir.y);

	blob.setKeyPressed(key_left, dir.x > 0);
	blob.setKeyPressed(key_right, dir.x < 0);
	blob.setKeyPressed(key_up, dir.y > 0);
	blob.setKeyPressed(key_down, dir.y < 0);
}