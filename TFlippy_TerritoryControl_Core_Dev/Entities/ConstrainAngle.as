void onInit(CBlob@ this)
{
	if (!this.exists("constraint_max_angle")) this.set_f32("constraint_max_angle", 60);
}

void onTick(CBlob@ this)
{
	const f32 maxAngle = this.get_f32("constraint_max_angle");
	this.setAngleDegrees(Maths::Clamp(fixAngle(this.getAngleDegrees()), -maxAngle, maxAngle));
}

f32 fixAngle(f32 x)
{
    x = (x + 180) % 360;
    if (x < 0) x += 360;
	
    return x - 180;
}