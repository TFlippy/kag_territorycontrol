#include "CustomBlocks.as"

void onInit(CBlob @ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getShape().SetRotationsAllowed(false);

	this.Tag("builder always hit");

	Vec2f[] sprouts = {};
	this.set("sprouts", sprouts);

	//Starts offline
}

void onTick(CBlob@ this)
{
	Vec2f[]@ sprouts;
	if (this.getShape().isStatic() && this.get("sprouts", @sprouts))
	{
		if (sprouts.length < 1)
		{
			sprouts.push_back(Vec2f(this.getPosition().x, this.getPosition().y));
		}
		
		Random@ rand = Random(getGameTime());
		CMap@ map = getMap();

		//Grow at the sprouts
		for (int i = 0; i < sprouts.length; i++)
		{
			Vec2f sprout = sprouts[i];
			int dirrandom = rand.NextRanged(4);
			Vec2f offset;
			switch (dirrandom)
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
			if (canGrowTo(sprout + offset, map))
			{
				map.server_SetTile(sprout + offset, CMap::tile_glass);
				sprouts[i] = Vec2f(sprout + offset);
			}
		}
		
		//print(sprouts[0].x + " " + this.getPosition().x);
		this.set("sprouts", sprouts);
	}
}

bool canGrowTo(Vec2f pos, CMap@ map)
{
	Tile backtile = map.getTile(pos);

	if (!map.hasSupportAtPos(pos)) 
		return false;

	if (map.isTileBedrock(backtile.type) || map.isTileSolid(backtile.type)) 
	{
		return false;
	}
	Vec2f middle = pos + Vec2f(map.tilesize * 0.5f, map.tilesize * 0.5f);

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

				bool cantBuild = true;//(b.isCollidable() || b.getShape().isStatic());

				// cant place on any other blob
				if (cantBuild &&
						!b.hasTag("dead") &&
						!b.hasTag("material") &&
						!b.hasTag("projectile") &&
						bname != "bush")
				{
					f32 angle_decomp = Maths::FMod(Maths::Abs(b.getAngleDegrees()), 180.0f);
					bool rotated = angle_decomp > 45.0f && angle_decomp < 135.0f;
					f32 width = rotated ? b.getHeight() : b.getWidth();
					f32 height = rotated ? b.getWidth() : b.getHeight();
					if ((middle.x > bpos.x - width * 0.5f) && (middle.x < bpos.x + width * 0.5f)
							&& (middle.y > bpos.y - height * 0.5f) && (middle.y < bpos.y + height * 0.5f))
					{
						return false;
					}
				}	
			}
		}
	}

	return true;
	
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}