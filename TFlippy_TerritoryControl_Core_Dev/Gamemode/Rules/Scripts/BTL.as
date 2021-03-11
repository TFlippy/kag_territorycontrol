/////////////////
// BTL - Bomb Tick Limit
//
// Oi mate, wtf is this i see you asking
// It's a limit for how many bomb's are allowed to explode at once
// and if that limit is reached, execute them the next tick instead
// this should help prevent crashes, and lower lag spikes
//


////// NOTE - DISABLED UNTIL WE USE ASU'S BUILD, CRASHES DUE TO BUG IN OlDER ANGELSCRIPT VERSIONS

#include "BTL_Include.as";



void onInit(CRules@ this)
{
    Holder holder;
    this.set("BTL_DELAY", holder);
}

void onTick(CRules@ this)
{
    /*int expCount = 0;
    Holder@ holder;

    this.get("BTL_DELAY", @holder);

    expCount = this.get_u16("explosion_count");
    this.set_u16("explosion_count", 0); // each new tick, set explosion_count to 0

    if (holder.bombList.size() == 0 || expCount == MAX_BOMBS_PER_TICK) { return; }

    print("Size: " + holder.bombList.size() + " | Current count:" + expCount);

    for (int a = 0; a < holder.bombList.size(); a++)
    {
        BTL@ explosion = holder.bombList[a];

        // Note when a bomb explodes, it re-calls shouldExplode, thus updating the counter
        if (this.get_u16("explosion_count") > MAX_BOMBS_PER_TICK) { break; } // exit out if we have done too much

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

        holder.bombList.erase(a);
        a -= 1;
    }*/

    //this.set("BTL_DELAY", holder);
    //this.set_u16("explosion_count", 0);
}
