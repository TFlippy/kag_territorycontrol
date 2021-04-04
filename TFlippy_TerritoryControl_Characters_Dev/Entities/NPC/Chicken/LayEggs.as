//todo: make it so that blobs can eat multiple types of food
//script by betelgeuse
#include "FoodQueue.as"

const string food_queue = "food_queue";

void onInit(CBlob@ this)
{
	FoodQueue fq("grain", 30);
	this.set(food_queue, fq);
}

void onTick(CBlob@ this)
{
	FoodQueue@ fq;
	this.get(food_queue, @fq);
	if (fq is null) return;

	fq.onTick(@this);

	if (fq.Ate()) {
		//this.getSprite().PlaySound("Pluck0");
		server_CreateBlob("egg", this.getTeamNum(), this.getPosition() + Vec2f(0.0f, 5.0f));
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	FoodQueue@ fq;
	this.get(food_queue, @fq);
	if (fq is null) return;

	fq.onCollision(@this, @blob);
}