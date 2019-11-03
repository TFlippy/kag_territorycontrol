// const f32 yPos = 90.00f;

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

const f32 speed = 2.00f;
// const f32 speed = 0.10f;

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().transports = true;
	
	this.Tag("train");
	
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 150, 25, 0));
	
	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSoundVolume(10.0f);
		sprite.SetEmitSound("Train_Loop.ogg");
		sprite.SetEmitSoundPaused(false);
		sprite.RewindEmitSound();
	}
	
	if (isServer())
	{
		
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !blob.hasTag("train");
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	// bool server = isServer();
	// bool client = isClient();

	// if (client) ShakeScreen(80, 50, this.getPosition());
	this.setVelocity(Vec2f(4, 0));
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}