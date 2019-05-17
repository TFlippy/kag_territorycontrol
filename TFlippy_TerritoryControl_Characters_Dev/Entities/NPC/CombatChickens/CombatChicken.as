#include "HittersTC.as";
#include "RunnerCommon.as"

string[] firstnames = 
{ 
	"Jerry",
	"Bobby",
	"Harry",
	"Barry",
	"Garry",
	"Polly",
	"Fug",
	"Tweety",
	"Fleet",
};

string[] surnames = 
{ 
	"Eggbert",
	"Bobton",
	"Paxton",
	"Fughorn",
	"Egghorn",
	"Jaxton",
	"Barlington",
	"Bolton",
	"Bigglesworth",
	"Fugton"
};

void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());
	string name = firstnames[rand.NextRanged(firstnames.length)] + " " + surnames[rand.NextRanged(surnames.length)];
	
	this.set_f32("gib health", -1.5f);
	this.set_string("chicken name", name);
	this.setInventoryName(name);
	
	this.Tag("dangerous");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isServer())
	{
		if (customData == HittersTC::radiation)
		{
			if (!this.hasTag("transformed") && this.getHealth() <= 0.125f && XORRandom(3) == 0)
			{
				CBlob@ blob = server_CreateBlob("cuck", this.getTeamNum(), this.getPosition());
				if (this.getPlayer() !is null) blob.server_SetPlayer(this.getPlayer());
				this.Tag("transformed");
				this.server_Die();
			}
		}
	}
	
	return damage;
}