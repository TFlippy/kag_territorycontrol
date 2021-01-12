#define SERVER_ONLY

#include "MakeMat.as";
#include "Hitters.as";

class HarvestBlobPair
{
	string name;
	f32 amount_wood;
	f32 amount_stone;
	HarvestBlobPair(string blobname, f32 wood, f32 stone)
	{
		name = blobname;
		amount_wood = wood;
		amount_stone = stone;
	}
};

HarvestBlobPair[] pairs =
{
	HarvestBlobPair("log", 90.0f, 0.0f),
	HarvestBlobPair("wooden_door", 5.0f, 0.0f),
	HarvestBlobPair("stone_door", 0.0f, 5.0f),
	HarvestBlobPair("trap_block", 0.0f, 2.5f),
};

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{	
	if (customData == Hitters::drill || customData == Hitters::builder)
	{
		if (damage > 0.0f)
		{
			string name = hitBlob.getName();

			f32 multiplier = this.exists("mining_multiplier") ? this.get_f32("mining_multiplier") : 1.00f;
			
			int wood = 0;
			int stone = 0;
			for (uint i = 0; i < pairs.length; i++)
			{
				if (pairs[i].name == name)
				{
					stone = pairs[i].amount_stone * damage;
					wood = pairs[i].amount_wood * damage;
					break;
				}
			}

			if (wood > 0)
			{
				MakeMat(this, worldPoint, "mat_wood", wood * multiplier);
			}
			if (stone > 0)
			{
				MakeMat(this, worldPoint, "mat_stone", stone * multiplier);
			}
		}
	}
}
