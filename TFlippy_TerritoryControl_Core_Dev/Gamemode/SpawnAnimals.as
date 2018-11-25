#define SERVER_ONLY

const int max_pig = 10;
const string pig_name = "piglet";

void onTick(CRules@ this)
{
	if (getGameTime() % 29 != 0) return;
	if (XORRandom(2) == 0) return;

	CMap@ map = getMap();
	if (map is null || map.tilemapwidth < 2) return; //failed to load map?

	CBlob@[] pig;
	getBlobsByName(pig_name, @pig);

	if (pig.length < max_pig)
	{
		if (pig.length > 2 && XORRandom(4) < 1) //breed pig (25% chance)
		{
			uint first = XORRandom(pig.length);
			uint second = XORRandom(pig.length);

			CBlob@ first_pig = pig[first];
			CBlob@ second_pig = pig[second];

			if (first != second && //not the same pig
			        first_pig.getDistanceTo(second_pig) < 32 && //close
			        !first_pig.hasTag("dead") && //both parents alive
			        !second_pig.hasTag("dead"))
			{
				CBlob@ babby_pig = server_CreateBlobNoInit(pig_name);
				if (babby_pig !is null)
				{
					babby_pig.server_setTeamNum(-1);
					babby_pig.setPosition((first_pig.getPosition() + second_pig.getPosition()) * 0.5f);
					babby_pig.Init();
				}
			}
		}
		else //spawn from nowhere
		{
			f32 x = (f32((getGameTime() * 997) % map.tilemapwidth) + 0.5f) * map.tilesize;

			Vec2f top = Vec2f(x, map.tilesize);
			Vec2f bottom = Vec2f(x, map.tilemapheight * map.tilesize);
			Vec2f end;

			if (map.rayCastSolid(top, bottom, end))
			{
				f32 y = end.y;
				Vec2f pos = Vec2f(x, y);
				TileType tile = map.getTile(Vec2f(x, y + 8)).type;
				
				if (map.isTileGroundStuff(tile) && !map.isInWater(pos)) 
				{
					server_CreateBlob(pig_name, -1, pos);
				}
			}
		}
	}
}
