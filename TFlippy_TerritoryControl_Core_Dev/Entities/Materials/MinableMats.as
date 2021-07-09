#define SERVER_ONLY

#include "MakeMat.as";
#include "Hitters.as";

class HarvestBlobMat
{
	f32 amount;
	string matname;
	HarvestBlobMat(f32 pamount, string pmatname)
	{
		amount = pamount;
		matname = pmatname;
	}
};

void onInit(CBlob@ this)
{
	string name = this.getName();
	HarvestBlobMat[] mats = {};
	if (name == "log")	mats.push_back(HarvestBlobMat(90.0f, "mat_wood"));
	else if (name == "wooden_door") mats.push_back(HarvestBlobMat(5.0f, "mat_wood"));
	else if (name == "stone_door") mats.push_back(HarvestBlobMat(5.0f, "mat_stone"));
	else if (name == "trap_block") mats.push_back(HarvestBlobMat(2.0f, "mat_stone"));
	else if (this.hasTag("altar")) mats.push_back(HarvestBlobMat(10.0f, "mat_stone"));
	else if (name == "steamtankwreck") mats.push_back(HarvestBlobMat(1.0f, "mat_ironingot"));

	this.set("minableMats", mats);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{	
	if (customData == Hitters::drill || customData == Hitters::builder || hitterBlob.getName() == "dynamite")
	{
		if (damage > 0.0f && !this.hasTag("MaterialLess")) //Tag which makes blobs stop giving materials on hit
		{
			f32 multiplier = this.exists("mining_multiplier") ? this.get_f32("mining_multiplier") : 1.00f;
			HarvestBlobMat[] mats;
			this.get("minableMats", mats);
			//print(" "+ mats[0].matname);

			//Amount of mats is dependant on how many intervalls are crossed with that damage
			double intervalls = this.getInitialHealth() * 0.2f; //5 Intervalls
			print(intervalls + " " + this.getHealth() + " "+this.getInitialHealth());
			int mod = Maths::Ceil(this.getHealth() / intervalls) - Maths::Ceil((this.getHealth() - damage) / intervalls);
			print(Maths::Ceil(this.getHealth() / intervalls) + " " + Maths::Ceil((this.getHealth() - damage) / intervalls));
			if (mod > 0)
			{
				if (customData == Hitters::explosion) //Explosions convert ingots into ore
				{
					for (uint i = 0; i < mats.length; i++)
					{
						string mat = mats[i].matname;
						if (mat.substr(mat.length - 5,mat.length - 1) == "ingot")
						{
							MakeMat(hitterBlob, hitterBlob.getPosition(), mat.substr(0, mat.length - 5), mats[i].amount * multiplier * 5);
						}
						else
						{
							MakeMat(hitterBlob, hitterBlob.getPosition(), mat, mats[i].amount * multiplier);
						}
						
					}
				}
				else
				{
					for (uint i = 0; i < mats.length; i++)
					{
						MakeMat(hitterBlob, hitterBlob.getPosition(), mats[i].matname, mats[i].amount * multiplier);
					}
				}
			}
		}
	}
	return damage;
}
