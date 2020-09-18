#include "hitters.as";
#include "Knocked.as";
#include "RunnerCommon.as";

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    return damage;
}