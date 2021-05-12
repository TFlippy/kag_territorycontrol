//Knight brain

#define SERVER_ONLY

#include "BrainCommon.as"
#include "Knocked.as"
#include "JuggernautCommon.as"

void onInit(CBrain@ this)
{
	InitBrain(this);
}

void onTick(CBrain@ this)
{
	SearchTarget(this,true,true);

	CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	JuggernautInfo@ juggernaut;
	if (!blob.get("JuggernautInfo",@juggernaut)) return;

	const float attackModeDistance=	30.0f;

	//if(sv_test) return;
	//logic for target

	this.getCurrentScript().tickFrequency = 1;
	blob.setKeyPressed(key_action1, false);
	blob.setKeyPressed(key_action2, false);

	u8 strategy = blob.get_u8("strategy");
	if (juggernaut.state == JuggernautStates::grabbed)
	{
		if (target is null || LoseTarget(this, target))
		{
			blob.setKeyPressed(key_action2, true);
			strategy = Strategy::idle;
		}
		else
		{
			blob.setAimPos(target.getPosition() + Vec2f(0.0f, -32.0f));
			blob.setKeyPressed(key_action1, true);
		}
	}
	else if (target !is null)
	{
		f32 distance;
		const bool visibleTarget = isVisible(blob, target, distance);
		if (distance < attackModeDistance) strategy = Strategy::attacking;
		else strategy = Strategy::chasing;

		if (strategy == Strategy::chasing) DefaultChaseBlob(blob, target);
		else if (strategy == Strategy::attacking) AttackBlob(blob, target);

		if (LoseTarget(this,target)) strategy = Strategy::idle;
	}
	blob.set_u8("strategy",strategy);

	FloatInWater(blob);
}


void AttackBlob(CBlob@ blob,CBlob @target)
{
	JuggernautInfo@ juggernaut;
	if (!blob.get("JuggernautInfo", @juggernaut)) return;

	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	Vec2f targetVector = targetPos - mypos;
	f32 targetDistance = targetVector.Length();
	const s32 difficulty = blob.get_s32("difficulty");

	if (targetDistance > blob.getRadius() + 25.0f) Chase(blob, target);

	JumpOverObstacles(blob);

	//aim always at enemy
	blob.setAimPos(targetPos);

	const u32 gametime=	getGameTime();

	if (target.isKeyPressed(key_action1)) //enemy is attacking me
	{
		
	}

	bool shouldGrab = targetDistance<30.0f;
	if (!target.isKeyPressed(key_action1))
	{
		shouldGrab = shouldGrab && (getKnocked(target) > 0 || target.getHealth()<=1.25f && XORRandom(3)!=0);
	}

	if (shouldGrab)
	{
		//Should try grabbing instead
		blob.setKeyPressed(key_action2, true);
		blob.setKeyPressed(key_action1, false);
	}
	else blob.setKeyPressed(key_action1, true); //Hammer smash!
}
