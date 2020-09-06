#include "VehicleCommon.as"
#include "CargoAttachmentCommon.as"
#include "Hitters.as";
#include "Explosion.as";

const Vec2f arm_offset = Vec2f(-2, -4);

const u8 explosions_max = 25;

void onInit(CBlob@ this)
{


	Vehicle_Setup(this,
	              125, // move speed
	              0.20f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              true  // inventory access
	             );
	VehicleInfo@ v;
	
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}

	v.charge = 100;
		
	this.getShape().SetOffset(Vec2f(0, 8));
	
	Vehicle_SetupGroundSound(this, v, "WoodenWheelsRolling", 1.0f, 1.0f);
	Vehicle_addWheel(this, v, "Wheel.png", 16, 16, 0, Vec2f(-5.0f, 14.0f));
	Vehicle_addWheel(this, v, "Wheel.png", 16, 16, 0, Vec2f(8.0f, 14.0f));
		
	this.getShape().SetRotationsAllowed(true);
	
	this.SetLight(true);
	this.SetLightColor(SColor(255, 255, 0, 0));
	this.SetLightRadius(128.5f);
	
	this.addCommandID("nuke_activate_sv");
	this.addCommandID("nuke_ready_sv");
	this.addCommandID("nuke_activate_cl");
	
	this.set_bool("nuke_primed", false);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isAttached()) return;

	CPlayer@ owner = this.getDamageOwnerPlayer();
	CPlayer@ ply = caller.getPlayer();
	
	if (owner !is null && ply !is null)
	{
		CButton@ btn_ready = caller.CreateGenericButton(11, Vec2f(-4, 3), this, this.getCommandID("nuke_ready_sv"), "Arm the R.O.F.L.!\n(Only by " + owner.getUsername() + ")");
		btn_ready.SetEnabled(ply.getUsername() == owner.getUsername() && !this.get_bool("nuke_ready"));
		
		CButton@ btn_detonate = caller.CreateGenericButton(11, Vec2f(4, 3), this, this.getCommandID("nuke_activate_sv"), "Set off the R.O.F.L.!");
		btn_detonate.SetEnabled(this.get_bool("nuke_ready") && !this.hasTag("nuke_active"));
	}
	else
	{
		CButton@ btn_detonate = caller.CreateGenericButton(11, Vec2f(0, 3), this, this.getCommandID("nuke_activate_sv"), "Set off the R.O.F.L.!");
	}

	// CButton@ btn_ready = caller.CreateGenericButton(11, Vec2f(-8, 3), this, this.getCommandID("nuke_ready_sv"), "Arm the bomb!\n(This may be only performed by the owner. (" + owner.getUsername() + ")");
	// if (!this.hasTag("nuke_active") && !this.isAttached()) caller.CreateGenericButton(11, Vec2f(0, 3), this, this.getCommandID("nuke_activate_sv"), "Activate the 30 second timer!");
}

bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}
void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _unused) {}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("nuke_activate_sv"))
		{
			if (this.isAttached()) return;
			if (!this.get_bool("nuke_ready") || this.hasTag("nuke_active")) return;
		
			CPlayer@ owner = this.getDamageOwnerPlayer();
			
			if (owner is null ? false : !this.get_bool("nuke_ready")) return;
		
			this.set_u32("nuke_boomtime", getGameTime() + 30 * 30);
			this.Tag("nuke_active");
		
			printf("" + owner.getUsername() + "'s Nuke has been activated.");
		
			CBitStream params;
			this.SendCommand(this.getCommandID("nuke_activate_cl"), params);
		}
		
		if (cmd == this.getCommandID("nuke_ready_sv"))
		{
			if (this.isAttached()) return;
		
			this.set_bool("nuke_ready", true);
			this.Sync("nuke_ready", true);
		}
	}

	if (isClient())
	{
		if (cmd == this.getCommandID("nuke_activate_cl"))
		{
			if (!this.get_bool("nuke_ready")) return;
		
			this.set_u32("nuke_boomtime", getGameTime() + 30 * 30);
			this.Tag("nuke_active");
		}
	}
}

void onTick(CBlob@ this)
{
	if (this.hasTag("nuke_active") && !this.hasTag("dead"))
	{
		u32 time = getGameTime();
		
		if (isServer())
		{
			if (time > this.get_u32("nuke_boomtime"))
			{
				CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
				boom.setPosition(this.getPosition());
				boom.set_u8("boom_start", 1);
				boom.set_u8("boom_end", 25);
				boom.Init();
				
				this.server_Die();
				this.Tag("dead");
			}
		}
	
		if (isClient() && !this.hasTag("nuke_alarm"))
		{
			if (time % 85 == 0)
			{
				// Emit sound is used by the Vehicle.as :(
				this.getSprite().PlaySound("Nuke_Loop.ogg", 0.75f, 1.00f);
			}
			
			if (time > (this.get_u32("nuke_boomtime") - 120))
			{
				this.getSprite().PlaySound("Nuke_Alarm.ogg", 1.00f, 1.00f);
				this.Tag("nuke_alarm");
			}
		}
	}
}

void onRender(CSprite@ this)
{	
	CBlob@ blob = this.getBlob();
	CBlob@ playerBlob = getLocalPlayerBlob();

	if (playerBlob is null || !blob.hasTag("nuke_active") || blob.get_u32("nuke_boomtime") < getGameTime() ) { return; }
	
	if (getMap().rayCastSolidNoBlobs(blob.getInterpolatedPosition(), playerBlob.getPosition())) { return; }

	u32 secs = ((blob.get_u32("nuke_boomtime") - 1 - getGameTime()) / getTicksASecond()) + 1;
	string units = ((secs != 1) ? "seconds" : "second");
	string text = "Detonation in " + secs + " " + units + "!";
	
	Vec2f pos = getDriver().getScreenPosFromWorldPos(this.getBlob().getPosition() + Vec2f(0, 22));
	GUI::SetFont("menu");
	GUI::DrawTranslatedTextCentered(text, pos, SColor(255, 255, 0, 0));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && !this.hasTag("nuke_active"))
	{
		TryToAttachCargo(this, blob);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("nuke_active") && byBlob.hasTag("vehicle") && this.getTeamNum() == byBlob.getTeamNum();
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("vehicle") ? this.getTeamNum() != blob.getTeamNum() : true;
}