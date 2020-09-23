/////////////////
// BTL - Bomb Tick Limit
//
// Oi mate, wtf is this i see you asking
// It's a limit for how many bomb's are allowed to explode at once
// and if that limit is reached, execute them the next tick instead
// this should help prevent crashes, and lower lag spikes
//

#include "BTL_Include.as";

void onTick(CRules@ this)
{
    u16[] toErase;
    BTL[] @expList;

	this.get("BTL_DELAY", @expList);
    if (expList is null || expList.size() == 0) { return; } 

    int expCount = this.get_u16("explosion_count");

    for (int a = 0; a < expList.size(); a++)
    {
        BTL@ explosion = expList[a];
        
        if (explosion.time == getGameTime()) { continue; }
        
        expCount += 1;

        if (expCount > MAX_BOMBS_PER_TICK) { break; } // exit out if we have done more then 5 this tick

        CBlob@ blob = explosion.original_blob;

        if (blob is null) // blob's have around '30 ticks' before they die
        {
            if (!isServer()) { continue;} 

            CBlob@ blob = server_CreateBlob( explosion.blob_name, explosion.team, explosion.position ); // optimize this later

            if (explosion.damage_owner !is null)
            {
                blob.SetDamageOwnerPlayer(explosion.damage_owner);
            }

            blob.server_Die(); // sorry little one, such a short life
        }
        else 
        {
            explosion.CallHookPls(); // explode 
        }

        toErase.push_back(a);
    }

    if (toErase.size() != 0) 
    {
        toErase.reverse(); // crashes here if size is 0 :dagger:

        for (int a = 0; a < toErase.size(); a++) // erase all
        {
            expList.erase(toErase[a]);
        }
    }

    this.set("BTL_DELAY", expList);
    this.set_u16("explosion_count", 0); 
}