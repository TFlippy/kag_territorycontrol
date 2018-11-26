#define SERVER_ONLY

void onInit(CRules@ this)
{

}

void onTick(CRules@ this)
{
    if(getGameTime() % 30 == 0)
    {
		CMap@ map = getMap();
		//Might be unneccessart but leaving it just to be safe
		//Map netvars are attached to the map, so when we move to the next one it basically resets for us
		if(!map.exists("lastMeteor") || !map.exists("lastWreckage"))
		{
			map.set_u32("lastMeteor", 0);
			map.set_u32("lastWreckage", 0);
		}
		u32 lastMeteor = map.get_u32("lastMeteor");
		u32 lastWreckage = map.get_u32("lastWreckage");
		u32 time = getGameTime();
		u32 timeSinceMeteor = time - lastMeteor;
		u32 timeSinceWreckage = time - lastWreckage;
	
		// print("last meteor: " + timeSinceMeteor + "; Chance: " + Maths::Max(10000 - timeSinceMeteor, 0));
	
        if (timeSinceMeteor > 6000 && XORRandom(Maths::Max(35000 - timeSinceMeteor, 0)) == 0) // Meteor strike
        {
            print("Random event: Meteor");
            server_CreateBlob("meteor", -1, Vec2f(XORRandom(map.tilemapwidth) * map.tilesize, 0.0f));
			
			lastMeteor = time;
        }
		
		if (timeSinceWreckage > 30000 && XORRandom(Maths::Max(120000 - timeSinceWreckage, 0)) == 0) // Wreckage
        {
            print("Random event: Wreckage");
            server_CreateBlob(XORRandom(100) > 50 ? "ancientship" : "poisonship", -1, Vec2f(XORRandom(map.tilemapwidth) * map.tilesize, 0.0f));
			
			lastWreckage = time;
        }
		map.set_u32("lastMeteor", lastMeteor);
		map.set_u32("lastWreckage", lastWreckage);	
    }

	// f32 rot = (getGameTime() * 0.5f % 360);
	
	// CBlob@ ply = getLocalPlayerBlob();
	
	// f32 arc = 360;
	// f32 modifier = ply.getPosition().x / (getMap().tilemapwidth * 8);
	// f32 angle = (arc * modifier) - (arc / 2);
	
	// ply.getShape().SetRotationsAllowed(true);
	// ply.getShape().SetAngleDegrees(angle);
	
	// getCamera().setRotation(0, 0, angle);
	
	// CBlob@[] blobs;
	// getMap().getBlobs(blobs);
	
	// sv_gravity = 0;
	
	// Vec2f force = Vec2f(1, 0) * 1;
	
	// for (int i = 0; i < blobs.length; i++)
	// {
		// blobs[i].setVelocity(force);
	// }
}