#include "CustomBlocks.as"
#include "Hitters.as"
#include "HittersTC.as"
#include "FireCommon.as"

bool isDead(Vec2f pos, CMap@ map)
{
	Tile backtile = map.getTile(pos);
	if (!isTileKudzu(backtile.type))
	{
		return true;
	}
	return false;
}

u8 canGrowTo(CBlob@ this, Vec2f pos, CMap@ map, Vec2f dir) //0 = no good, 1 = good, 2 = good and no kudzu blob already here
{
	Tile backtile = map.getTile(pos);
	TileType type = backtile.type;

	//if (!map.hasSupportAtPos(pos)) 
	//	return false;

	if (map.isTileBedrock(type) || (isTileBGlass(type) && !this.hasTag("Mut_IgnoreBGlass")))
	{
		return 0;
	}

	if (isTileSolid(pos, map) && !isTileKudzu(type)) //Dont go past solid blocks unless they are kudzu
	{
		return 0;
	}

	if (pos.y < 2 * map.tilesize || //Check map edges
	        pos.x < 2 * map.tilesize ||
	        pos.x > (map.tilemapwidth - 2.0f)*map.tilesize)
	{
		return 0;
	}

	double halfsize = map.tilesize * 0.5f;
	Vec2f middle = pos; //+ Vec2f(halfsize, halfsize);
	u8 kudzublob = 1;

	CBlob@[] blobsInRadius;
	if (map.getBlobsInRadius(middle, map.tilesize, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (!b.isAttached())
			{	
				Vec2f bpos = b.getPosition();

				const string bname = b.getName();

				bool cantBuild = (b.isCollidable() || b.getShape().isStatic());
				//print(cantBuild + " "+ bname);

				// cant place on any other blob
				if (cantBuild &&
						!b.hasTag("dead") &&
						!b.hasTag("material") && //Will just push materials dead things or projectiles similar to the normal human build mode
						!b.hasTag("projectile") &&
						bname != "bush")
				{
					//print(pos + " " +bpos);

					f32 angle_decomp = Maths::FMod(Maths::Abs(b.getAngleDegrees()), 180.0f);
					bool rotated = angle_decomp > 45.0f && angle_decomp < 135.0f;
					f32 width = rotated ? b.getHeight() : b.getWidth();
					f32 height = rotated ? b.getWidth() : b.getHeight();
					if ((middle.x > bpos.x - width * 0.5f - halfsize) && (middle.x - halfsize < bpos.x + width * 0.5f)
							&& (middle.y > bpos.y - height * 0.5f - halfsize) && (middle.y - halfsize < bpos.y + height * 0.5f))
					{
						if (b.hasTag("kudzu"))	//Ignores kudzu blobs for obvious reasons (From KudzuHit.as))
						{
							kudzublob = 0; //This is not a place where you should upgrade
						}
						else 
						{
							if (!b.hasTag("invincible"))
							{
								int Type = HittersTC::poison;
								double Amount = 0.125f * this.get_u8("DamageMod");

								if(this.hasTag("Mut_StunningDamage")) Type = Hitters::spikes;

								this.server_Hit(b, bpos, bpos - pos, 0.125f, Type, false);
							}
							return 0;
						}
					}
				}	
			}
		}
	}

	//Check if it has support there
	if (map.isTileBackgroundNonEmpty(backtile) || isTileKudzu(type)) //Can grow on backgrounds (and pass through kudzu)
	{
		return 1 + kudzublob;
	}

	if ((this.getPosition() - pos).Length() < 15.0f) //Can be unsuported while near the core
	{
		return 1 + kudzublob;
	}
	
	for (u8 i = 0; i < 8; i++)
    {
		Tile test = map.getTile(pos + directions[i]);
		//print(directions[i].x + " " + directions[i].y);
        if (isTileSolid(pos + directions[i], map) && !isTileKudzu(test.type)) return 1 + kudzublob; //Can grow while at least 1 solid non kudzu tile in the 8 tiles around it
    }

	if (Vec2f(0.0f,-8.0f) == dir && this.hasTag("Mut_UpwardLines"))
	{
		if (CMap::tile_empty == map.getTile(pos + Vec2f(8.0f, 0.0f)).type && CMap::tile_empty == map.getTile(pos + Vec2f(-8.0f, 0.0f)).type)
		{
			return 1 + kudzublob;
		}
	}

	if (Vec2f(0.0f,8.0f) == dir && this.hasTag("Mut_DownLines"))
	{
		if (CMap::tile_empty == map.getTile(pos + Vec2f(8.0f, 0.0f)).type && CMap::tile_empty == map.getTile(pos + Vec2f(-8.0f, 0.0f)).type)
		{
			return 1 + kudzublob;
		}
	}

	return 0; //No support found
	
}

bool isTileSolid(Vec2f pos, CMap@ map)
{
	const u32 offset = map.getTileOffset(pos);
	if (map.hasTileFlag(offset, Tile::SOLID)) return true;
	return false;
}

void MutateTick(CBlob@ this)
{
	if (this.hasTag("Mut_Regeneration"))
	{
		//print(this.getHealth() + "");
		this.server_Heal(0.1f);
	}
	if (this.hasTag("Mut_Mutating"))
	{
		Random@ rand = Random(getGameTime());
		int r = rand.NextRanged(300);
		if (r == 0)
		{
			Mutate(this);
		}
	}
}

void UpgradeTile(CBlob@ this, Vec2f pos, CMap@ map, Random@ rand)
{
	//Create a new core if its time and its chance
	if (getGameTime() > this.get_u32("Duplication Time") && this.get_u32("Duplication Time") != 0 && rand.NextRanged(30) == 0)
	{
		CBlob@ core = server_CreateBlob("kudzucore", 0, pos);
		if (core != null)
		{
			core.getShape().SetStatic(true);
			Mutate(core); //Offspring start with 1 random mutation
		}
		this.set_u32("Duplication Time", 0); //No more duplicating after the first one
	}
	else if (getGameTime() > this.get_u32("Upgrade Time"))
	{
		double UpgradeSpeed = this.get_f32("UpgradeSpeed"); //Devides the time between upgrades

		if (this.hasTag("Mut_Badgers") && rand.NextRanged(100) == 0)
		{
			CBlob@ node = server_CreateBlob("kudzubadger", 0, pos);
			if (node != null)
			{
				node.getShape().SetStatic(true);
			}
			this.set_u32("Upgrade Time", getGameTime() + 900 / UpgradeSpeed);
		}
		else if (this.hasTag("Mut_Explosive") && rand.NextRanged(50) == 0)
		{
			CBlob@ node = server_CreateBlob("kudzuexplosive", 0, pos);
			if (node != null)
			{
				node.getShape().SetStatic(true);
			}
			this.set_u32("Upgrade Time", getGameTime() + 600 / UpgradeSpeed);
		}
		else if (this.hasTag("Mut_Gold") && rand.NextRanged(70) == 0)
		{
			CBlob@ node = server_CreateBlob("kudzugold", 0, pos);
			if (node != null)
			{
				node.getShape().SetStatic(true);
			}
			this.set_u32("Upgrade Time", getGameTime() + 900 / UpgradeSpeed);
		}
	}
}

void Mutate(CBlob@ this)
{
	CParticle@ particle = ParticleAnimated("SmallSmoke", this.getPosition(), Vec2f(0, 0), 0, 1.0f, 2, 0.0f, false);
	if (particle != null)
	{
		particle.Z = 500;
	}


	Random@ rand = Random(getGameTime() + this.getPosition().x); //Randomness is time and position dependent, 
	//technicly 2 of em in the same coloum mutated at the exact same time would get the same mutation
	int r = rand.NextRanged(20);
	if (r < 1 && !this.hasTag("Mut_Mutating")) //Possibly the most dangerous mutation, (At first slot to reduce the chance of getting it with other mutations)
	{
		this.Tag("Mut_Mutating");
	}
	else if (r < 5)
	{
		Mutate_SurvivabilityBahvior(this, rand);
	}
	else if (r < 10)
	{
		Mutate_DamageBehavior(this, rand);
	}
	else if (r < 15)
	{
		Mutate_ExpansionBehavior(this, rand);
	}
	else if (r < 20)
	{
		Mutate_UpgradeBehavior(this, rand);
	}
}

void Mutate_SurvivabilityBahvior(CBlob@ this, Random@ rand)
{
	int r = rand.NextRanged(3);
	if (r < 1 && !this.hasTag("Mut_NoLight"))
	{
		this.SetLight(false);
		this.Tag("Mut_NoLight");
	}
	else if (r < 2 && !this.hasTag("Mut_FireResistance")) //Does not make the tiles fire resistant but the core at least
	{
		this.Tag("Mut_FireResistance");
		this.Untag(spread_fire_tag);
		this.RemoveScript("IsFlammable.as");
	}
	else if (r < 3 && !this.hasTag("Mut_Regeneration"))
	{
		this.Tag("Mut_Regeneration");
	}
	else
	{
		//NOTHING, for now
	}
}

void Mutate_DamageBehavior(CBlob@ this, Random@ rand)
{
	int r = rand.NextRanged(2);
	if (r < 1 && !this.hasTag("Mut_StunningDamage"))
	{
		this.Tag("Mut_StunningDamage");
	}
	else //Repeatable Mutation (+0.125 damage)
	{
		this.set_u8("DamageMod", this.get_u8("DamageMod") + 1);
	}
}

void Mutate_ExpansionBehavior(CBlob@ this, Random@ rand)
{	
	int r = rand.NextRanged(4);
	if (r < 1 && !this.hasTag("Mut_IgnoreBGlass"))
	{
		this.Tag("Mut_IgnoreBGlass");
	}
	else if (r < 2 && !this.hasTag("Mut_UpwardLines"))
	{
		this.Tag("Mut_UpwardLines");
	}
	else if (r < 3 && !this.hasTag("Mut_DownLines"))
	{
		this.Tag("Mut_DownLines");
	}
	else //Repeatable Mutation (+1 Sprout, no cap but very slow)
	{
		this.set_u8("MaxSprouts", this.get_u8("MaxSprouts") + 1);
	}
}

void Mutate_UpgradeBehavior(CBlob@ this, Random@ rand)
{	
	int r = rand.NextRanged(4);
	if (r < 1 && !this.hasTag("Mut_Badgers"))
	{
		this.Tag("Mut_Badgers");
	}
	else if (r < 2 && !this.hasTag("Mut_Explosive")) //Honestly a negative mutation, since the explosion also damages the plant and causes chain reactions
	{
		this.Tag("Mut_Explosive");
	}
	else if (r < 3 && !this.hasTag("Mut_Gold"))
	{
		this.Tag("Mut_Gold");
	}
	else //Repeatable Mutation
	{
		this.set_f32("UpgradeSpeed", this.get_f32("UpgradeSpeed") + 0.2); //Devides time between upgrades
	}
}

const Vec2f[] directions =
{
	Vec2f(0, -8),
	Vec2f(0, 8),
	Vec2f(8, 0),
	Vec2f(-8, 0),
	Vec2f(-8, -8),
	Vec2f(-8, 8),
	Vec2f(8, -8),
	Vec2f(8, 8)
};