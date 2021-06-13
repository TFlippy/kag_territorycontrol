//////////////////////////////////////////////////////
//
//  BulletModule.as - Vamist
//

#include "Bullet.as";

class BulletModule
{
	// Called when bullet is made once (NOT ALWAYS GOING TO BE AT STARTING POS)
	void onModuleInit(Bullet@ this) {}

	// Called every tick
	void onTick(Bullet@ bullet) { }

	// Called every tick
	// Return: bool - True to skip vanilla gravity step
	bool onGravityStep(Bullet@ bullet) { return false; }

	// Called every frame IF bullet is on screen
	void onRender(Bullet@ bullet) {}

	// Called when bullet hits a blob
	void onHitBlob(Bullet@ bullet, CBlob@ blob, int blobHash, Vec2f pos, f32 damage) {}

	// Called when bullet hits a tile
	void onHitTile(Bullet@ bullet, Tile tile, Vec2f pos, f32 damage) {}
} 
