
void onInit(CBlob @ this)
{

	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getShape().SetRotationsAllowed(false);

	this.Tag("builder always hit");

	this.set_u32("charge",0);
	CSprite@ sprite = this.getSprite();
	sprite.SetAnimation("off"); //Starts offline
	sprite.SetZ(-100.0f);
}

void onTick(CBlob@ this)
{
	if (this.get_u32("charge") < 120)
	{
		this.add_u32("charge", 1);
	}
	else
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetAnimation("on");
		sprite.SetZ(-100.0f);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (this.get_u32("charge")>=120)
	{
		this.set_u32("charge", 0);
		move(this, blob);
	}
}

void move(CBlob@ this, CBlob@ blob)
{
	//print("moved");
	f32 angle = this.getAngleDegrees();
	Vec2f dir = Vec2f(1.0f, 0.0f).RotateBy(angle + (this.isFacingLeft() ? 180 : 0));
	if(blob != null)
	{
		blob.AddForce(dir*Maths::Min(100, blob.getMass())*Maths::Max(1,3-blob.getVelocity().Length()));
		CSprite@ sprite = this.getSprite();
		sprite.SetAnimation("off");
		sprite.SetZ(-100.0f);
	}
}