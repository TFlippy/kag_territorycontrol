//tree making logs on death script

#include "MakeSeed.as"

void onDie(CBlob@ this)
{
	if (!isServer()) return; //SERVER ONLY
	if (this.hasTag("no drop") || this.hasTag("burning")) return;
	
	Vec2f pos = this.getPosition();
	server_MakeSeed(pos, this.getName());
}
