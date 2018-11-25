// #include "CustomBlocks.as";
// //#include "LoaderUtilities.as";

// #define CLIENT_ONLY

// MatterBlocks@[] mattertiles;

// class MatterBlocks
// {
	// Vec2f position;
	
	// MatterBlocks() {};
	// MatterBlocks(Vec2f _position)
	// {
		// position = _position;
	// };
// };

// void onInit(CRules@ this)
// {
	// CMap@ map = getMap();
	// if(map !is null)
	// {
		// for(int i = 0; i < map.tilemapwidth*map.tilemapheight; i++)
		// {
			// if(map.getTile(i).type == CMap::tile_matter)
			// {
				// mattertiles.push_back(MatterBlocks(map.getTileWorldPosition(i)));
			// }
		// }
	// }
// }

// void onCommand(CRules@ this, u8 cmd, CBitStream @params)
// {
	// if (cmd == this.getCommandID("add_tile"))
	// {
		// //print("added");
		// Vec2f pos = params.read_Vec2f();
		// mattertiles.push_back(MatterBlocks(pos));
	// }
	// else if (cmd == this.getCommandID("remove_tile"))
	// {
		// //print("removed");
		// Vec2f pos = params.read_Vec2f();
		// for (uint i = 0; i < mattertiles.length; i++)
		// {
			// if (pos == mattertiles[i].position)
			// {
				// mattertiles.erase(i);
			// }
		// }
	// }
// }

// void onTick(CRules@ this)
// {
	// if(v_fastrender) return;

	// CMap@ map = getMap();
	// if(map !is null)
	// {
		// Driver@ driver = getDriver();
		// for(int i = 0; i < mattertiles.length; i++)
		// {
			// int num = 0;
			// for(int t = 0; t < 8; t++)
			// {
				// if(map.isTileSolid(mattertiles[i].position + eightdirections[t]))
					// num++;
			// }
			// if(num != 8)
			// {
				// Vec2f pos = driver.getScreenPosFromWorldPos(mattertiles[i].position);
				// int frame = (((pos.x/4)+(pos.y/4)) % 5)+1;
				// CParticle@ spark = ParticleAnimated("MatterSparks"+frame+".png", mattertiles[i].position+Vec2f(4, 4), Vec2f(0, 0), 0.0f, 1.0f, 2, 0.0f, false);
				// if (spark !is null)
				// {
					// spark.Z = 1000;
				// }
			// }
		// }
	// }
// }

// const Vec2f[] eightdirections = {	Vec2f(0, -8),
								// Vec2f(8, -8),
								// Vec2f(8, 0),
								// Vec2f(8, 8),
								// Vec2f(0, 8),
								// Vec2f(-8, 8),
								// Vec2f(-8, 0),
								// Vec2f(-8, -8)};












