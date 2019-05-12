
class Bullet
{
	Vec2f startPos;
	Vec2f currentPos;
	Vec2f dir;
	
	f32 angle;
	f32 distance;
	f32 distance_target = 0;
	
	bool done = false;
	
	Bullet(Vec2f in_startPos, Vec2f in_endPos)
	{
		startPos = in_startPos;
		currentPos = startPos;
		dir = (in_endPos - in_startPos);
		distance = 0;
		distance_target = dir.getLength();
		angle = dir.getAngleDegrees();
		dir.Normalize();
	}
}

void createBullet(Vec2f startPos, Vec2f endPos)
{
	CRules@ rules = getRules();
	if (rules !is null)
	{
		Bullet[]@ bullets;
		rules.get("bullets", @bullets);
		
		if (bullets !is null)
		{
			bullets.push_back(Bullet(startPos, endPos));
			rules.set("bullets", @bullets);
		}
	}
}