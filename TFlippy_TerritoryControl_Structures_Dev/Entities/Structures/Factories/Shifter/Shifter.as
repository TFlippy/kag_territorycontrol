
void onInit(CBlob @ this)
{

	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getShape().SetRotationsAllowed(false);

	this.Tag("builder always hit");

	//Starts offline
	this.set_u32("rechargedTime", getGameTime() + RECHARGETIME);
	CSprite@ sprite = this.getSprite();
	sprite.SetAnimation("off"); 
	sprite.SetZ(-100.0f);
}

const u32 RECHARGETIME = 120; //how many ticks till the shifter can activate again

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (getGameTime() >= blob.get_u32("rechargedTime"))
	{
		this.SetAnimation("on");
		this.SetZ(-100.0f);
	}
	else
	{
		this.SetAnimation("off");
		this.SetZ(-100.0f);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (getGameTime() >= this.get_u32("rechargedTime"))
	{
		this.set_u32("rechargedTime", getGameTime() + RECHARGETIME);
		move(this, blob);
	}
}

void move(CBlob@ this, CBlob@ blob)
{
	//print("moved by shifter");
	f32 angle = this.getAngleDegrees();
	Vec2f dir = Vec2f(1.0f, 0.0f).RotateBy(angle + (this.isFacingLeft() ? 180 : 0));
	if(blob != null)
	{
		f32 vel = blob.getVelocity().Length()+1;
		blob.AddForce(dir *4* Maths::Min(100, blob.getMass()) / Maths::Sqrt(vel)); 
		//Basicly applies greater velocity if the object is really slow
		CSprite@ sprite = this.getSprite();
		sprite.SetAnimation("off");
		sprite.SetZ(-100.0f);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}