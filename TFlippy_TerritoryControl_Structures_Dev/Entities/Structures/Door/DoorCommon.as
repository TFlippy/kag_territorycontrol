//common functionality for door-like objects

#include "Survival_Structs.as";

bool canOpenDoor(CBlob@ this, CBlob@ blob)
{
	bool lockdown_passable = false;

	if (blob.getTeamNum() > 100 && this.getTeamNum() < 7)
	{
		TeamData@ team_data;
		GetTeamData(this.getTeamNum(), @team_data);
		
		lockdown_passable = !team_data.lockdown_enabled;
	}

	if ((blob.getShape().getConsts().collidable) &&
	        (blob.getRadius() > 5.0f) && //large
	        (this.getTeamNum() == 255 || this.getTeamNum() == blob.getTeamNum() || (blob.getTeamNum() >= 100 && blob.getTeamNum() < 200 && lockdown_passable)) &&
	        (blob.hasTag("player") || blob.hasTag("vehicle") || blob.hasTag("can open door"))) //tags that can open doors
	{
		
		
	
		Vec2f direction = Vec2f(0, -1);
		direction.RotateBy(this.getAngleDegrees());

		Vec2f doorpos = this.getPosition();
		Vec2f playerpos = blob.getPosition();

		
		if (blob.isKeyPressed(key_left) && playerpos.x > doorpos.x && Maths::Abs(playerpos.y - doorpos.y) < 11) return true;
		if (blob.isKeyPressed(key_right) && playerpos.x < doorpos.x && Maths::Abs(playerpos.y - doorpos.y) < 11) return true;
		if (blob.isKeyPressed(key_up) && playerpos.y > doorpos.y && Maths::Abs(playerpos.x - doorpos.x) < 11) return true;
		if (blob.isKeyPressed(key_down) && playerpos.y < doorpos.y && Maths::Abs(playerpos.x - doorpos.x) < 11) return true;
	}
	return false;
}