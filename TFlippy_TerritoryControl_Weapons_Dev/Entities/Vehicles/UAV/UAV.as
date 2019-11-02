
const u32 fuel_timer_max = 30 * 5;
const f32 altitude_goal = 250.00f;

void onInit(CBlob@ this)
{
	this.Tag("aerial");
	this.Tag("heavy weight");
	
	this.set_u16("controller_blob_netid", 0);
	this.set_u16("controller_player_netid", 0);
	
	this.addCommandID("offblast");
	
	this.getShape().SetRotationsAllowed(true);
}

void onTick(CBlob@ this)
{
	CMap@ map = this.getMap();
	Vec2f pos = this.getPosition();
	Vec2f end;
	
	// const bool isBot = this.getPlayer() is null;
	
	// if (map.rayCastSolid(pos, pos + Vec2f(0, 256), end))
	// {
		// f32 dist = (end - pos).getLength();
		// f32 mod = Maths::Clamp(1.00f - (dist / altitude_goal), 0.65f, 1.00f);
		// f32 force = this.getMass() * mod * 0.50f;
		
		// this.AddForce(Vec2f(0, -1) * force);
	// }

	Vec2f aimPos = this.getAimPos();
	
	this.SetFacingLeft((aimPos - pos).x <= 0);
	
	const bool left = this.isKeyPressed(key_left);
	const bool right = this.isKeyPressed(key_right);
	const bool up = this.isKeyPressed(key_up);
	const bool down = this.isKeyPressed(key_down);

	f32 h = (left ? -1 : 0) + (right ? 1 : 0); 
	f32 v = (up ? -1 : 0) + (down ? 1 : 0); 
	
	Vec2f vel = Vec2f(h, v);
	Vec2f gravity = Vec2f(0, -sv_gravity * this.getMass() / 25.00f);
	Vec2f force = (vel * this.getMass() * 0.25f);
	
	// print("" + force.x);
	
	this.AddForce(force + gravity);
	this.setAngleDegrees((this.getVelocity().x * 2.00f) + (this.isFacingLeft() ? -5 : 5));
	// this.setAngleDegrees(0);
	// this.setAngleDegrees(-(this.getAimPos() - this.getPosition()).Angle() + (this.isFacingLeft() ? 180 : 0));
	
	// if (this.isKeyPressed(key_action1) && this.get_u32("nextShoot") <= getGameTime())
	// {
		// Shoot(this);
	// }
}

// void onTick(CBlob@ this)
// {
	// if (this.hasTag("offblast"))
	// {
		// Vec2f dir;
	
		// if (this.get_u32("fuel_timer") > getGameTime())
		// {
			// CPlayer@ controller = this.getPlayer();
			// this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.3f, this.get_f32("max_velocity")));
			
			// CBlob@ blob = getBlobByNetworkID(this.get_u16("controller_blob_netid"));
			// bool isControlled = blob !is null && !blob.hasTag("dead");
			
			// if (!isControlled || controller is null || this.get_f32("velocity") < this.get_f32("max_velocity") * 0.75f)
			// {
				// dir = Vec2f(0, 1);
				// dir.RotateBy(this.getAngleDegrees());
			// }
			// else
			// {
				// dir = (this.getPosition() - this.getAimPos());
				// dir.Normalize();
			// }
						
			// // print(this.getAimPos().x + " " + this.getAimPos().y);
						
			// const f32 ratio = 0.20f;
			
			// Vec2f nDir = (this.get_Vec2f("direction") * (1.00f - ratio)) + (dir * ratio);
			// nDir.Normalize();
			
			// this.SetFacingLeft(false);
			
			// this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.75f, 20.0f));
			// this.set_Vec2f("direction", nDir);
			
			// this.setAngleDegrees(-nDir.getAngleDegrees() + 90 + 180);
			// this.setVelocity(-nDir * this.get_f32("velocity"));
			
			// MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
		// }
		// else
		// {
			// this.setAngleDegrees(-this.getVelocity().Angle() + 90);
			// this.getSprite().SetEmitSoundPaused(true);
		// }		
		
		// if (this.isKeyJustPressed(key_action1))
		// {
			// if (isServer())
			// {
				// ResetPlayer(this);
				// this.server_Die();
				// return;
			// }
		// }
	// }
// }

// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// if (isServer())
	// {
		// if ((blob !is null ? !blob.isCollidable() : !solid)) return;
		// if (this.hasTag("offblast") && this.get_u32("no_explosion_timer") < getGameTime()) 
		// {
			// ResetPlayer(this);
		// }
	// }
// }

void ResetPlayer(CBlob@ this)
{
	if (isServer())
	{
		CPlayer@ ply = getPlayerByNetworkId(this.get_u16("controller_player_netid"));
		CBlob@ blob = getBlobByNetworkID(this.get_u16("controller_blob_netid"));
		if (blob !is null && ply !is null && !blob.hasTag("dead"))
		{
			blob.server_SetPlayer(ply);
		}
		
		this.server_Die();
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point is null) return;

	if (point.getOccupied() is null)
	{
		CPlayer@ ply = caller.getPlayer();
		if (ply !is null)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			params.write_u16(ply.getNetworkID());
			
			caller.CreateGenericButton(11, Vec2f(0.0f, 0.0f), this, this.getCommandID("offblast"), "Off blast!", params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("offblast"))
	{
		const u16 caller_netid = params.read_u16();
		const u16 player_netid = params.read_u16();
		
		CPlayer@ caller = getPlayerByNetworkId(caller_netid);
		CPlayer@ ply = getPlayerByNetworkId(player_netid);
	
		if (this.hasTag("offblast")) return;
		
		this.Tag("projectile");
		this.Tag("offblast");
		
		this.set_u32("no_explosion_timer", getGameTime() + 30);
		this.set_u32("fuel_timer", getGameTime() + fuel_timer_max);
		
		this.set_u16("controller_blob_netid", caller_netid);
		this.set_u16("controller_player_netid", player_netid);
		
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSound("Helichopper_Loop.ogg");
		sprite.SetEmitSoundSpeed(1.50f);
		sprite.SetEmitSoundVolume(0.30f);
		sprite.SetEmitSoundPaused(false);
		sprite.PlaySound("CruiseMissile_Launch.ogg", 2.00f, 1.00f);
		
		this.SetLight(true);
		this.SetLightRadius(128.0f);
		this.SetLightColor(SColor(255, 255, 100, 0));
		
		if (isServer() && ply !is null)
		{
			this.server_SetPlayer(ply);
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
	if (point is null) return true;
		
	CBlob@ controller = point.getOccupied();
	if (controller is null) return true;
	else return false;
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(0, 16).RotateBy(this.getAngleDegrees());
	ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}




			
