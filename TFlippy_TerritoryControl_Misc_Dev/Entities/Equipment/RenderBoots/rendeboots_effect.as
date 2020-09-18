#include "hitters.as";
#include "Knocked.as";
#include "RunnerCommon.as";

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if (customData == Hitters::fall) 
    {
        damage *= 1.5f;
        SetKnocked(this, (damage + 1) * 30);
    }

    CPlayer@ p = hitterBlob.getDamageOwnerPlayer();
    if (p is null) { return damage; }

    CBlob@ blob = p.getBlob();
    if (blob is null || this !is blob) { return damage; }
    
    switch (customData)
    {
        case Hitters::bomb:
        case Hitters::bomb_arrow:
        case Hitters::explosion:
        case Hitters::keg:
        case Hitters::mine:
        case Hitters::mine_special:
        {
            damage *= 0.4f;
        }
    }

    return damage;
}