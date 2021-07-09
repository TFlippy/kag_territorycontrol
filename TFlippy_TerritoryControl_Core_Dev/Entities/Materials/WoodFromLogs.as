#define SERVER_ONLY

#include "MakeMat.as";
#include "Hitters.as";

class HarvestBlobPair
{
	string blobname;
	f32 amount;
	string matname;
	HarvestBlobPair(string pblobname, f32 pamount, string pmatname)
	{
		blobname = pblobname;
		amount = pamount;
		matname = pmatname;
	}
};

HarvestBlobPair[] pairs =
{
	HarvestBlobPair("log", 90.0f, "mat_wood"),
	HarvestBlobPair("wooden_door", 5.0f, "mat_wood"),
	HarvestBlobPair("stone_door", 5.0f, "mat_stone"),
	HarvestBlobPair("trap_block", 2.5f, "mat_stone"),
};

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{	
	if (customData == Hitters::drill || customData == Hitters::builder)
	{
		if (damage > 0.0f && !hitBlob.hasTag("MaterialLess")) //Tag which makes blobs stop giving materials on hit
		{
			string name = hitBlob.getName();

			f32 multiplier = this.exists("mining_multiplier") ? this.get_f32("mining_multiplier") : 1.00f;
			
			for (uint i = 0; i < pairs.length; i++)
			{
				//print("test" + name);
				if (pairs[i].blobname == name)
				{
					MakeMat(this, worldPoint, pairs[i].matname, pairs[i].amount * multiplier);
					break;
				}
			}
		}
	}
}
