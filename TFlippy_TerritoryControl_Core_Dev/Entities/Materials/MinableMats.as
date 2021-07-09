#define SERVER_ONLY

#include "MakeMat.as";
#include "Hitters.as";
#include "MinableMatsCommon.as";
/*
NOTE: This must be put before Generic Hit as generic hit sets the damage to 0 and AFTER all damage resistance effects such as WoodHit.as
										 MinableMats.as;
*/

void onInit(CBlob@ this)
{
	string name = this.getName();
	HarvestBlobMat[] mats = {}; //These numbers are the TOTAL amount of mats you get from mining the blob fully

	//print(name);

	if (name == "log")	mats.push_back(HarvestBlobMat(120.0f, "mat_wood"));
	//Blocks
	else if (name == "ladder") mats.push_back(HarvestBlobMat(5.0f, "mat_wood"));
	else if (name == "wooden_door" || name == "neutral_door") mats.push_back(HarvestBlobMat(10.0f, "mat_wood"));
	else if (name == "stone_door") mats.push_back(HarvestBlobMat(25.0f, "mat_stone"));
	else if (name == "iron_door") mats.push_back(HarvestBlobMat(2.0f, "mat_ironingot"));
	else if (name == "plasteel_door") mats.push_back(HarvestBlobMat(4.0f, "mat_plasteel"));
	else if (name == "wood_triangle") mats.push_back(HarvestBlobMat(1.0f, "mat_wood"));
	else if (name == "stone_triangle") mats.push_back(HarvestBlobMat(1.0f, "mat_stone"));
	else if (name == "concrete_triangle") mats.push_back(HarvestBlobMat(2.0f, "mat_concrete"));
	else if (name == "iron_triangle") mats.push_back(HarvestBlobMat(1.0f, "mat_ironingot"));
	else if (name == "stone_halfblock") mats.push_back(HarvestBlobMat(1.0f, "mat_stone"));
	else if (name == "iron_halfblock") mats.push_back(HarvestBlobMat(1.0f, "mat_ironingot"));
	else if (name == "wooden_platform") mats.push_back(HarvestBlobMat(10.0f, "mat_wood"));
	else if (name == "iron_platform") mats.push_back(HarvestBlobMat(2.0f, "mat_ironingot"));
	//Buildings
	else if (this.hasTag("altar")) mats.push_back(HarvestBlobMat(500.0f, "mat_stone"));
	else if (name == "tavern") { mats.push_back(HarvestBlobMat(100.0f, "mat_stone")); mats.push_back(HarvestBlobMat(150.0f, "mat_wood"));}
	else if (name == "banditshack") mats.push_back(HarvestBlobMat(150.0f, "mat_wood"));
	else if (name == "woodchest") mats.push_back(HarvestBlobMat(50.0f, "mat_wood"));
	else if (name == "ironlocker") mats.push_back(HarvestBlobMat(2.0f, "mat_ironingot"));
	else if (name == "lamppost") { mats.push_back(HarvestBlobMat(15.0f, "mat_stone")); mats.push_back(HarvestBlobMat(20.0f, "mat_wood")); mats.push_back(HarvestBlobMat(1.0f, "mat_copperwire"));}
	else if (name == "teamlamp") { mats.push_back(HarvestBlobMat(10.0f, "mat_wood")); mats.push_back(HarvestBlobMat(1.0f, "mat_copperwire"));}
	else if (name == "industriallamp") { mats.push_back(HarvestBlobMat(15.0f, "mat_stone")); mats.push_back(HarvestBlobMat(1.0f, "mat_copperwire"));}
	else if (name == "ceilinglamp") mats.push_back(HarvestBlobMat(1.0f, "mat_copperwire"));
	//Industry
	else if (name == "conveyor") { mats.push_back(HarvestBlobMat(3.0f, "mat_stone")); mats.push_back(HarvestBlobMat(4.0f, "mat_wood"));}
	else if (name == "seperator") { mats.push_back(HarvestBlobMat(10.0f, "mat_stone")); mats.push_back(HarvestBlobMat(5.0f, "mat_wood"));}
	else if (name == "launcher") { mats.push_back(HarvestBlobMat(5.0f, "mat_stone")); mats.push_back(HarvestBlobMat(10.0f, "mat_wood"));}
	else if (name == "filter") { mats.push_back(HarvestBlobMat(50.0f, "mat_stone")); mats.push_back(HarvestBlobMat(15.0f, "mat_wood"));}
	else if (name == "jumper") { mats.push_back(HarvestBlobMat(25.0f, "mat_stone")); mats.push_back(HarvestBlobMat(10.0f, "mat_wood"));}
	else if (name == "shifter") { mats.push_back(HarvestBlobMat(5.0f, "mat_stone")); mats.push_back(HarvestBlobMat(10.0f, "mat_wood")); mats.push_back(HarvestBlobMat(1.0f, "mat_copperwire"));}



	//Wrecks
	else if (name == "armoredbomberwreck") { mats.push_back(HarvestBlobMat(3.0f, "mat_ironingot")); mats.push_back(HarvestBlobMat(100.0f, "mat_wood")); }
	else if (name == "armoredcarwreck") { mats.push_back(HarvestBlobMat(10.0f, "mat_ironingot")); mats.push_back(HarvestBlobMat(5.0f, "mat_steelingot")); }
	else if (name == "bomberwreck") mats.push_back(HarvestBlobMat(100.0f, "mat_wood"));
	else if (name == "carwreck") mats.push_back(HarvestBlobMat(8.0f, "mat_ironingot"));
	else if (name == "helichopperwreck") { mats.push_back(HarvestBlobMat(15.0f, "mat_ironingot")); mats.push_back(HarvestBlobMat(30.0f, "mat_steelingot")); mats.push_back(HarvestBlobMat(10.0f, "mat_copperwire"));}
	else if (name == "minicopterwreck") { mats.push_back(HarvestBlobMat(3.0f, "mat_ironingot")); mats.push_back(HarvestBlobMat(5.0f, "mat_copperwire"));}
	else if (name == "steamtankwreck") mats.push_back(HarvestBlobMat(5.0f, "mat_ironingot"));
	else if (name == "triplanewreck") mats.push_back(HarvestBlobMat(100.0f, "mat_wood"));
	
	
	this.set("minableMats", mats);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{	
	if (customData == Hitters::drill || customData == Hitters::builder || hitterBlob.getName() == "dynamite")
	{
		if (damage > 0.0f && !this.hasTag("MaterialLess")) //Tag which makes blobs stop giving materials on hit
		{
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
					double intervalls = this.getInitialHealth() / (mats[i].amount);
					double newHealth = calcHealth(this, damage);
					
					int amount = Maths::Ceil(this.getHealth() / intervalls) - Maths::Ceil(newHealth / intervalls);
		
					if (mat.substr(mat.length - 5,mat.length - 1) == "ingot") //Convert
					{
						MakeMat(hitterBlob, hitterBlob.getPosition(), mat.substr(0, mat.length - 5), 5 * amount);
					}
					else
					{
						MakeMat(hitterBlob, hitterBlob.getPosition(), mat, amount);
					}
					
				}
			}
			else
			{
				for (uint i = 0; i < mats.length; i++)
				{
					string mat = mats[i].matname;
					double intervalls = this.getInitialHealth() / (mats[i].amount);
					double newHealth = calcHealth(this, damage);

					int amount = Maths::Ceil(this.getHealth() / intervalls) - Maths::Ceil(newHealth / intervalls);

					MakeMat(hitterBlob, hitterBlob.getPosition(), mats[i].matname, amount);
				}
			}
		}
	}
	return damage;
}

double calcHealth(CBlob@ this, double damage)
{
	return Maths::Max(0, (this.getHealth() - damage * getRules().attackdamage_modifier));
}
