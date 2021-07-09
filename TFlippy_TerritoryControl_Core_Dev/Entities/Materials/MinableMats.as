#define SERVER_ONLY

#include "MakeMat.as";
#include "Hitters.as";

//NOTE: This must be put before Generic Hit as generic hit sets the damage to 0 and AFTER all damage resistance effects such as WoodHit.as
//											 MinableMats.as;

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
	HarvestBlobMat[] mats = {}; //These numbers are the TOTAL amount of mats you get from mining the target fully

	if (name == "log")	mats.push_back(HarvestBlobMat(120.0f, "mat_wood"));
	//Blocks
	else if (name == "wooden_door" || name == "neutral_door") mats.push_back(HarvestBlobMat(10.0f, "mat_wood"));
	else if (name == "stone_door") mats.push_back(HarvestBlobMat(25.0f, "mat_stone"));
	else if (name == "iron_door") mats.push_back(HarvestBlobMat(2.0f, "mat_ironingot"));
	else if (name == "plasteel_door") mats.push_back(HarvestBlobMat(4.0f, "mat_plasteel"));
	//Buildings
	else if (this.hasTag("altar")) mats.push_back(HarvestBlobMat(500.0f, "mat_stone"));
	//Wrecks
	else if (name == "armoredbomberwreck") { mats.push_back(HarvestBlobMat(3.0f, "mat_ironingot")); mats.push_back(HarvestBlobMat(100.0f, "mat_wood")); }
	else if (name == "armoredcarwreck") { mats.push_back(HarvestBlobMat(10.0f, "mat_ironingot")); mats.push_back(HarvestBlobMat(5.0f, "mat_steelingot")); }
	else if (name == "bomberwreck") mats.push_back(HarvestBlobMat(100.0f, "mat_wood"));
	else if (name == "carwreck") mats.push_back(HarvestBlobMat(8.0f, "mat_ironingot"));
	else if (name == "helichopperwreck") { mats.push_back(HarvestBlobMat(15.0f, "mat_ironingot")); mats.push_back(HarvestBlobMat(30.0f, "mat_steelingot")); mats.push_back(HarvestBlobMat(10.0f, "mat_copperwire"));}
	else if (name == "minicopterwreck") { mats.push_back(HarvestBlobMat(3.0f, "mat_ironingot")); mats.push_back(HarvestBlobMat(5.0f, "mat_copperwire"));}
	else if (name == "steamtankwreck") mats.push_back(HarvestBlobMat(5.0f, "mat_ironingot"));
	else if (name == "triplanewreck") mats.push_back(HarvestBlobMat(100.0f, "mat_wood"));
	//print(name);
	this.set("minableMats", mats);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{	
	if (customData == Hitters::drill || customData == Hitters::builder || hitterBlob.getName() == "dynamite")
	{
		//print("test" + damage);
		if (damage > 0.0f && !this.hasTag("MaterialLess")) //Tag which makes blobs stop giving materials on hit
		{
			
			f32 multiplier = this.exists("mining_multiplier") ? this.get_f32("mining_multiplier") : 1.00f;
			HarvestBlobMat[] mats;
			this.get("minableMats", mats);
			//print(" "+ mats[0].matname);
			//print(damage + "");

			//Amount of mats is dependant on how many intervalls are crossed with that damage
			if (customData == Hitters::explosion) //Explosions convert ingots into ore
			{
				for (uint i = 0; i < mats.length; i++)
				{
					string mat = mats[i].matname;
					double intervalls = mats[i].amount * multiplier;
					int mod = Maths::Ceil(this.getHealth() / intervalls) - Maths::Max(0, Maths::Ceil((this.getHealth() - damage * getRules().attackdamage_modifier) / intervalls));
		
					if (mat.substr(mat.length - 5,mat.length - 1) == "ingot")
					{
						MakeMat(hitterBlob, hitterBlob.getPosition(), mat.substr(0, mat.length - 5), 5 * mod);
					}
					else
					{
						MakeMat(hitterBlob, hitterBlob.getPosition(), mat, mod);
					}
					
				}
			}
			else
			{
				for (uint i = 0; i < mats.length; i++)
				{
					string mat = mats[i].matname;
					double intervalls = this.getInitialHealth() / (mats[i].amount * multiplier);
					int mod = Maths::Ceil(this.getHealth() / intervalls) - Maths::Max(0, Maths::Ceil((this.getHealth() - damage * getRules().attackdamage_modifier) / intervalls));
					//print(mod + "");
					MakeMat(hitterBlob, hitterBlob.getPosition(), mats[i].matname, mod);
				}
			}
		}
	}
	return damage;
}
