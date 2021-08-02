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
	this.Tag("nature");
	this.Tag(spread_fire_tag);

	Vec2f[] sprouts = {};
	this.set("sprouts", sprouts);

	this.getCurrentScript().tickFrequency = 15;

	this.SetLight(true);
	this.SetLightRadius(30.0f);
	this.SetLightColor(SColor(255, 155, 255, 0));

	//Base stats
	this.set_u8("MutationChance", 10);
	this.set_u8("MutateMax", 0); // overtime mutations
	this.set_f32("NextMutate", getGameTime() + (1800*3)); // time til next mutation
	this.set_f32("MutationTime", (1800*5));
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
	if (carried != null)
	{
		bool canMutate = false;
		const int hash = carried.getName().getHash();
		switch (hash)
		{
			case -661490310:	// mithrilingot
			case -1288560969:	// mithril
			case -989285105:	// mithrilenriched
			case 1074492747:	// dirt
			case -1326479778:	// oil
			case -123101143:	// meat
			case -1370030172:	// gold ore
			case -617913447:	// sulphur
			case 389592510:		// badger
			case 336243301:		// steak
				
				canMutate = true;
				break;
		}
		if (canMutate)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton(23, Vec2f(0, 0), this, this.getCommandID("mutate"), "Mutate", params);
		}
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
			int matReq = 0;
			const int hash = carried.getName().getHash();

			if (carried !is null)
			{
				switch(hash)
				{
					case -661490310:	matReq = 10;	break;	// mithrilingot
					case -989285105:	matReq = 10;	break;	// mithrilenriched
					case -1288560969:	matReq = 200; 	break;	// mithril
					case 1074492747:	matReq = 500; 	break;	// dirt
					case -1326479778:	matReq = 50; 	break;	// oil
					case -123101143: 	matReq = 100;	break;	// meat
					case -1370030172:	matReq = 250;	break;	// gold ore
					case -617913447:	matReq = 250;	break;	// sulphur
					case 389592510:		matReq = 1;	break;	// badger
					case 336243301:		matReq = 1;	break;	// steak
				}
			}

			if (carried.getQuantity() >= matReq)
			{
				int remain = carried.getQuantity() - matReq;
				if (remain > 0)
				{
					carried.server_SetQuantity(remain);
				}
				else
				{
					carried.Tag("dead");
					carried.server_Die();
				}
				if (hash == -661490310 || hash == -989285105)
				{
					Mutate(this);
				}
				Mutate(this, hash);
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
