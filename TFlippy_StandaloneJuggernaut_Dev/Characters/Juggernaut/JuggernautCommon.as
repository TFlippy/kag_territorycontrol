//common knight header
namespace JuggernautStates
{
	enum States
	{
		normal,
		stun,
		charging,
		chargedAttack,
		grabbing,
		grabbed,
		throwing,
		fatality
	}
}
namespace JuggernautVars
{
	const ::u8 attackDelay  = 9;
	const ::u8 chargeTime   = 20;
	const ::u8 attackTime   = 20;
	const ::u8 grabTime     = 12;
	const ::u8 throwTime    = 12;
	const ::u8 fatalityTime = 66; //88
}
shared class JuggernautInfo
{
	u8 stun;
	u8 actionTimer;
	u8 attackDelay;
	bool dontHitMore;
	bool wasFacingLeft;
	Vec2f attackDirection;
	Vec2f attackAimPos;
	f32 attackTrueRot;
	f32 attackRot;

	u8 state;
	u8 prevState;
};
