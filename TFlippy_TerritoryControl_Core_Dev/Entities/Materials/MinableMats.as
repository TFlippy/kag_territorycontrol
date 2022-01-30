#include "Hitters.as";
#include "MinableMatsCommon.as";
/*
NOTE: This must be put before Generic Hit as generic hit sets the damage to 0 and AFTER all damage resistance effects such as WoodHit.as
										 MinableMats.as;
*/

void onInit(CBlob@ this)
{
	HarvestBlobMat[] mats = {}; //These numbers are the TOTAL amount of mats you get from mining the blob fully

	//Documents without seperate .as files in tc2
	if (this.getName() == "ladder") 
	{
		mats.push_back(HarvestBlobMat(5.0f, "mat_wood")); //NO FILE
		this.set("minableMats", mats);
	}
	else if (this.getName() == "wooden_platform") 
	{
		mats.push_back(HarvestBlobMat(10.0f, "mat_wood")); //NO FILE
		this.set("minableMats", mats);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{	
	if (isServer())
	{
		if (customData == Hitters::drill || customData == Hitters::builder || hitterBlob.getName() == "dynamite")
		{
			if (damage > 0.0f && !this.hasTag("MaterialLess")) //Tag which makes blobs stop giving materials on hit
			{
				HarvestBlobMat[]@ mats;
				this.get("minableMats", @mats);
				//print(" "+ mats[0].matname);
				//print(damage + "");

				//Amount of mats is dependant on how many intervalls are crossed with that damage
				if (customData == Hitters::explosion) //Explosions convert ingots into ore
				{
					for (uint i = 0; i < mats.length; i++)
					{
						double intervalls = this.getInitialHealth() / (mats[i].amount);
						double newHealth = calcHealth(this, damage);
						
						int amount = Maths::Ceil(this.getHealth() / intervalls) - Maths::Ceil(newHealth / intervalls);

						string mat = mats[i].matname;
						if (mat.substr(mat.length - 5,mat.length - 1) == "ingot") //Convert ingots into ores (if possible and nessecary)
						{
							server_CreateBlob(mat.substr(0, mat.length - 5), -1, hitterBlob.getPosition()).server_SetQuantity(5 * amount);	//drop 5 ores instead of 1 ingot
						}
						else
						{
							server_CreateBlob(mat, -1, hitterBlob.getPosition()).server_SetQuantity(amount);
						}
						
					}
				}
				else
				{
					for (uint i = 0; i < mats.length; i++)
					{
						double intervalls = this.getInitialHealth() / (mats[i].amount);
						double newHealth = calcHealth(this, damage);

						int amount = Maths::Ceil(this.getHealth() / intervalls) - Maths::Ceil(newHealth / intervalls);

						server_CreateBlob(mats[i].matname, -1, hitterBlob.getPosition()).server_SetQuantity(amount);
					}
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
