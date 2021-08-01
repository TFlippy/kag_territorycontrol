#include "CustomBlocks.as"
#include "Hitters.as"
#include "HittersTC.as"
#include "FireCommon.as"
#include "KudzuCommon.as"

void onInit(CBlob @ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getShape().SetRotationsAllowed(false);

	this.Tag("builder always hit");
	this.Tag(spread_fire_tag);

	Vec2f[] sprouts = {};
	this.set("sprouts", sprouts);

	this.getCurrentScript().tickFrequency = 15;

	this.SetLight(true);
	this.SetLightRadius(30.0f);
	this.SetLightColor(SColor(255, 155, 255, 0));

	//Base stats
	this.set_u8("MaxSprouts", 10);
	this.set_f32("UpgradeSpeed", 1);
	this.set_u8("DamageMod", 1); //Base multiplier on 0.125

	this.addCommandID("mutate");

	this.getSprite().SetRelativeZ(500);

	//this.Tag("Mut_Peacefull"); //Mutation Testing

	//Starts offline
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (isStatic)
	{
		this.set_u32("Duplication Time", getGameTime() + RECHARGETIME);

		if (XORRandom(3) == 0)
		{
			Mutate(this);
		}
	}
}

const u32 RECHARGETIME = 18000; // 30 = 1 second, 1800 = 1 minute, this is 10 minutes

void GetButtonsFor(CBlob@ this, CBlob@ caller) //Mutate button
{
	CBlob@ carried = caller.getCarriedBlob();

	if (carried != null && carried.getName() == "mat_mithrilingot")
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(23, Vec2f(0, 0), this, this.getCommandID("mutate"), "Mutate", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) //Mutate command
{
	if (cmd == this.getCommandID("mutate"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			CBlob@ carried = caller.getCarriedBlob();
			if (carried !is null && carried.getName() == "mat_mithrilingot")
			{
				if (carried.getQuantity() >= 10)
				{
					
					int remain = carried.getQuantity() - 10;
					if (remain > 0)
					{
						carried.server_SetQuantity(remain);
					}
					else
					{
						carried.Tag("dead");
						carried.server_Die();
					}
					Mutate(this);
				}
			}
		}
	}
}	

void onTick(CBlob@ this)
{
	//this.getCurrentScript().tickFrequency = 1; //Testing
	Vec2f[]@ sprouts;
	if (this.getShape().isStatic() && this.get("sprouts", @sprouts))
	{
		Random@ rand = Random(getGameTime());
		CMap@ map = getMap();
		bool newSprout = false;

		MutateTick(this); //Tick all mutations this might have

		//New sprouts
		if (sprouts.length < 1) //First sprout is instant
		{
			sprouts.push_back(Vec2f(this.getPosition().x, this.getPosition().y));
			newSprout = true;
		}
		else if (sprouts.length < this.get_u8("MaxSprouts")) //Hardcap
		{
			if (rand.NextRanged(sprouts.length*10) == 0) //Chance decreases the more sprouts it already has
			{
				sprouts.push_back(Vec2f(this.getPosition().x, this.getPosition().y));
				newSprout = true;
			}
		}
		
		

		//Grow at the sprouts
		for (int i = 0; i < sprouts.length; i++)
		{
			Vec2f sprout = sprouts[i];


			if (!(i == sprouts.length -1 && newSprout) && isDead(sprout, map)) //Sprouts where the tile got destroyed should stop
			{
				sprouts.erase(i);
				i--;
			}
			else
			{
				int dirrandom = rand.NextRanged(4);
				Vec2f offset;
				switch (dirrandom) //Random direction
				{
					case 0: offset = Vec2f(8.0f,0.0f);
					break;
					case 1: offset = Vec2f(-8.0f,0.0f);
					break;
					case 2: offset = Vec2f(0.0f,8.0f);
					break;
					case 3: offset = Vec2f(0.0f,-8.0f);
					break;
				}

				if (this.hasTag("Mut_Teleporting") && XORRandom(50) == 0) //Skip past up to 3 tiles in a rectangular range, very low chance, cannot be a first mutation
				{
					offset = Vec2f((XORRandom(7) - 3) * 8.00f, (XORRandom(7) - 3) * 8.00f);
					//print("test");
				}
			
				u8 canGrow = canGrowTo(this, sprout + offset, map, offset);
				if (canGrow >= 1)
				{
					Tile backtile = map.getTile(sprout + offset);
					TileType type = backtile.type;
					if (isTileTypeKudzu(type) && type != CMap::tile_kudzu_d0) //Dont replace kudzu
					{
						if (canGrow >= 2)
						{
							//Try Upgrading the tile (chance based)
							UpgradeTile(this, sprout, map, rand);
						}
					}
					else
					{
						map.server_SetTile(sprout + offset, CMap::tile_kudzu); //Growing
					}
					sprouts[i] = Vec2f(sprout + offset); //Move in all cases
				}
				//Testing Particles
				/*
				CParticle@ particle = ParticleAnimated("SmallFire", sprout + offset, Vec2f(0, 0), 0, 1.0f, 2, 0.0f, false);
				if (particle != null)
				{
					particle.Z = 500;
				}
				*/
			}
		}
		
		//print(sprouts[0].x + " " + this.getPosition().x);
		this.set("sprouts", sprouts);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.getShape().isStatic();
}