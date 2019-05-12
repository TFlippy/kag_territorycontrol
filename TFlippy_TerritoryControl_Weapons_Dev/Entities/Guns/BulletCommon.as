
class Bullet
{
	Vec2f startPos;
	Vec2f currentPos;
	Vec2f dir;
	
	SColor color;
	Vec2f size;
	
	f32 angle;
	f32 distance;
	f32 distance_target = 0;
	
	bool done = false;
	
	Bullet(Vec2f in_startPos, Vec2f in_endPos, SColor in_color, Vec2f in_size)
	{
		startPos = in_startPos;
		currentPos = startPos;
		color = in_color;
		size = in_size;
		dir = (in_endPos - in_startPos);
		distance = 0;
		distance_target = dir.getLength();
		angle = dir.getAngleDegrees();
		dir.Normalize();
	}
}

void createBullet(Vec2f startPos, Vec2f endPos, SColor color, Vec2f size)
{
	CRules@ rules = getRules();
	if (rules !is null)
	{
		Bullet[]@ bullets;
		rules.get("bullets", @bullets);
		
		if (bullets !is null)
		{
			bullets.push_back(Bullet(startPos, endPos, color, size));
			rules.set("bullets", @bullets);
		}
	}
}