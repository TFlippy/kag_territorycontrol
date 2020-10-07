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

void onTick(CRules@ this)
{
    int expCount = 0;
	BTL[] @bombList;

	if (!this.get("BTL_DELAY", @bombList))
	{
		@bombList = array<BTL>();
	}

    this.set_u16("explosion_count", 0); // each new tick, set explosion_count to 0
    
    if (bombList.size() == 0) { return; } 

    print("hi new tick");
    
    for (int a = 0; a < bombList.size(); a++)
    {
        BTL @explosion = bombList[a];
        
        if (explosion.time == getGameTime()) { continue; }
        if (expCount > MAX_BOMBS_PER_TICK) { break; } // exit out if we have done more then 5 this tick

        expCount += 1;

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
            print("hi " + a);
            explosion.CallHookPls(); // explode 
        }

        bombList.erase(a);
        a -= 1;
    }

    this.set("BTL_DELAY", @bombList);   
    this.set_u16("explosion_count", expCount);
}