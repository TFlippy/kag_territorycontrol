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
    BTL[] @bombList;
    int exp_count = this.get_u16("explosion_count");

	this.get("BTL_DELAY", @bombList);
	
    if (bombList is null || bombList.size() == 0) { return; } 

    for (int a = 0; a < bombList.size(); a++)
    {
        BTL boom = bombList[a];
        
        if (boom.time == getGameTime()) { continue; }
        
        exp_count += 1;

        if (exp_count > MAX_BOMBS_PER_TICK) { break; } // exit out if we have done more then 5 this tick

        if (boom.explosion_host is null) 
        {;
            if (!isServer()) { continue;} 

            CBlob@ blob = server_CreateBlob( boom.blob_name, boom.team, boom.position ); // optimize this, lets see if we can stop a blob from dying?
            blob.server_Die(); // sorry little one, such a short life
        }
        else 
        {
            //Explode(boom.explosion_host, boom.radius, boom.damage); // just explode if the blob is still alive
        }

        toErase.push_back(a);
    }

    if (toErase.size() != 0) 
    {
        toErase.reverse(); // crashes here if size is 0 :dagger:

        for (int a = 0; a < toErase.size(); a++) // erase all
        {
            bombList.erase(toErase[a]);
        }
    }


    this.set("BTL_DELAY", @bombList);
    this.set_u16("explosion_count", 0); 
}