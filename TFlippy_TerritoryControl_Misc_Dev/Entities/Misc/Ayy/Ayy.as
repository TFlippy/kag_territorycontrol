const f32 yPos = 90.00f;

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetRotationsAllowed(false);
	
	this.setPosition(Vec2f(this.getPosition().x, yPos));

	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSoundVolume(10.0f);
		sprite.SetEmitSound("Ayy_Loop.ogg");
		sprite.SetEmitSoundPaused(false);
		sprite.RewindEmitSound();
		
		// client_AddToChat("A strange object has fallen out of the sky in the " + ((this.getPosition().x < getMap().tilemapwidth * 4) ? "west" : "east") + "!", SColor(255, 255, 0, 0));
		client_AddToChat("A massive object has appeared in the sky!", SColor(255, 255, 0, 0));
	}
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	bool server = isServer();
	bool client = isClient();
	
	Vec2f pos = Vec2f(this.getPosition().x, yPos);

	if (client) ShakeScreen(80, 30, pos);
	
	this.setPosition(pos + Vec2f(0.25f, 0));
	
	// CPlayer@ ply = this.getPlayer();
	// if (ply !is null)
	// {
		// print("" + this.isKeyPressed(key_left));
	
		// const bool left = this.isKeyPressed(key_left);
		// const bool right = this.isKeyPressed(key_right);
		// const bool up = this.isKeyPressed(key_up);
		// const bool down = this.isKeyPressed(key_down);

		// f32 h = (left ? -1 : 0) + (right ? 1 : 0); 
		// f32 v = (up ? -1 : 0) + (down ? 1 : 0); 
		
		// Vec2f vel = Vec2f(h, v);
		
		// this.setPosition(pos + vel);
		
		// // this.AddForce(vel * this.getMass() * 0.50f);
		// // this.SetFacingLeft(pilot.getAimPos().x < this.getPosition().x);
		
		// // print("vel: " + this.getVelocity().Length());
	// }
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}
