#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";

const int max = 4;

void onInit(CBlob@ this)
{
	this.set_u32("radpill start", getGameTime());
	this.set_u32("radpill end", getGameTime() + (30 * 108));
	
	// if (this.isMyPlayer()) Sound::Play("/clown.ogg");
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	u8 level = this.get_u8("radpilled");
}

void onDie(CBlob@ this)
{

}

// f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
// {
	// if (customData == Hitters::suddengib) 
	// {
		// this.server_Heal(damage * (1.00f + this.get_u8("radpilled") * 32.00f));
	// }
	// return damage;
// }