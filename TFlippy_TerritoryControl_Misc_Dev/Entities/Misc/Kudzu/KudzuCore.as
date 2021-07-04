#include "CustomBlocks.as"
#include "Hitters.as"
#include "HittersTC.as";
#include "FireCommon.as"

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

	//Starts offline
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (isStatic)
	{
		this.set_u32("Duplication Time", getGameTime() + RECHARGETIME);
	}
}

const u32 MAXSPROUTS = 10;
const u32 RECHARGETIME = 36000; // 60 = 1 second, 3600 = 1 minute, this is 10 minutes

void onTick(CBlob@ this)
{
	this.getSprite().SetRelativeZ(500);
	Vec2f[]@ sprouts;
	if (this.getShape().isStatic() && this.get("sprouts", @sprouts))
	{
		Random@ rand = Random(getGameTime());
		CMap@ map = getMap();
		bool newSprout = false;

		//New sprouts
		if (sprouts.length < 1) //First sprout is instant
		{
			sprouts.push_back(Vec2f(this.getPosition().x, this.getPosition().y));
			newSprout = true;
		}
		else if (sprouts.length < MAXSPROUTS) //Hardcap
		{
			if (rand.NextRanged(sprouts.length*7) == sprouts.length*7 - 1) //Chance decreases the more sprouts it already has
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
			

				if (canGrowTo(this, sprout + offset, map))
				{
					Tile backtile = map.getTile(sprout + offset);
					TileType type = backtile.type;
					if(isTileKudzu(type) && type != CMap::tile_kudzu_d0) //Dont replace kudzu
					{
						//Create a new core if its time and its chance
						if (getGameTime() > this.get_u32("Duplication Time") && this.get_u32("Duplication Time") != 0 && rand.NextRanged(30) == 0)
						{
							CBlob@ core = server_CreateBlob("kudzucore", 0, sprout);
							core.getShape().SetStatic(true);
							this.set_u32("Duplication Time", 0); //No more duplicating after the first one
						}
						//Going over already there kudzu tile
					}
					else
					{
						map.server_SetTile(sprout + offset, CMap::tile_kudzu); //Growing
					}
					
					sprouts[i] = Vec2f(sprout + offset);
				}
				//Testing Particles
				//CParticle@ particle = ParticleAnimated("SmallFire", sprout + offset, Vec2f(0, 0), 0, 1.0f, 2, 0.0f, false);
				//particle.Z = 500;
			}
		}
		
		//print(sprouts[0].x + " " + this.getPosition().x);
		this.set("sprouts", sprouts);
	}
}

bool isDead(Vec2f pos, CMap@ map)
{
	Tile backtile = map.getTile(pos);
	if (!isTileKudzu(backtile.type))
	{
		return true;
	}
	return false;
}

bool canGrowTo(CBlob@ this, Vec2f pos, CMap@ map)
{
	Tile backtile = map.getTile(pos);
	TileType type = backtile.type;

	//if (!map.hasSupportAtPos(pos)) 
	//	return false;

	if (map.isTileBedrock(type) || (map.isTileSolid(type)) || isTileBGlass(type))
	{
		return false;
	}

	double halfsize = map.tilesize * 0.5f;
	Vec2f middle = pos; //+ Vec2f(halfsize, halfsize);

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
						!b.hasTag("material") &&
						!b.hasTag("projectile") &&
						bname != "kudzucore" &&
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
						this.server_Hit(b, bpos, bpos - pos, 0.125f, HittersTC::poison, false);
						
						return false;
					}
				}	
			}
		}
	}

	//Check if it has support there
	if (map.isTileBackgroundNonEmpty(backtile)) //Can grow on backgrounds
	{
		return true;
	}

	if ((this.getPosition() - pos).Length() < 15.0f) //Can be unsuported while near the core
	{
		return true;
	}
	
	int Neighbours = 0;
	for (u8 i = 0; i < 8; i++)
    {
		Tile test = map.getTile(pos + directions[i]);
		//print(directions[i].x + " " + directions[i].y);
        if (map.isTileSolid(test) && !isTileKudzu(test.type)) return true; //Can grow while at least 1 non kudzu tile is around it
    }

	return false;
	
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

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.getShape().isStatic();
}