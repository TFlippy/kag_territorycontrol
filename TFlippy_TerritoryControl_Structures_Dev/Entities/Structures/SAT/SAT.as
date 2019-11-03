// Princess brain

#include "Hitters.as";
#include "HittersTC.as";
#include "Knocked.as";
#include "VehicleAttachmentCommon.as"

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.set_f32("pickup_priority", 16.00f);
	this.getShape().SetRotationsAllowed(false);
	
	this.getCurrentScript().tickFrequency = 30;
	// this.getCurrentScript().runFlags |= Script::tick_not_ininventory;
	
	this.getSprite().SetZ(20);
	this.set_u16("target", 0);
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ head = this.addSpriteLayer("head", "SAT_Head.png", 128, 16);
	if (head !is null)
	{
		head.SetOffset(Vec2f(0, -8));
		head.SetRelativeZ(1);
		head.SetVisible(true);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;
}

void onTick(CBlob@ this)
{
	CBlob@[] blobs;
	getBlobsByTag("faction_base", @blobs);
	
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();

	int index = -1;
	f32 s_dist = 9000000.00f;
	u8 myTeam = this.getTeamNum();

	for (int i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];
		u8 team = b.getTeamNum();
		
		Vec2f delta = b.getPosition() - this.getPosition();
		f32 dist = delta.LengthSquared();
		
		if (team != myTeam && (dist < 2000*2000) && (Maths::Abs(delta.x) > 200) && dist < s_dist)
		{
			s_dist = dist;
			index = i;
		}
	}

	if (index != -1)
	{
		CBlob@ target = blobs[index];
		if (target !is null)
		{
			if (target.getNetworkID() != this.get_u16("target"))
			{
				this.getSprite().PlaySound("LWS_Found.ogg", 1.00f, 1.00f);
				this.set_u32("nextAttack", getGameTime() + 60 + XORRandom(120));
			}
			
			this.set_u16("target", target.getNetworkID());
		}
	}
	
	CBlob@ t = getBlobByNetworkID(this.get_u16("target"));
	if (t !is null)
	{
		Vec2f tpos = (t.getPosition() - this.getPosition()) + Vec2f(XORRandom(128) - 64, 0);
		// print("" + tpos.x);
		
		tpos.y *= -1;
	
		f32 x = tpos.x / 8.00f;
		f32 y = tpos.y / 8.00f;
		f32 v = 40.00f;
		f32 g = sv_gravity;
		f32 sqrt = Maths::Sqrt((v*v*v*v) - (g*(g*(x*x) + 2.00f*y*(v*v))));
		f32 ang = Maths::ATan(((v*v) + sqrt)/(g*x)); // * 57.2958f;
		f32 angDeg = Maths::Abs(ang * 57.2958f);
		
		Vec2f aimDir = Vec2f(-f32(Maths::Cos(ang)), f32(Maths::Sin(ang)));
		if (x < 0) aimDir.RotateBy(180);

		CSpriteLayer@ head = this.getSprite().getSpriteLayer("head");
		if (head !is null && Maths::Round(angDeg) != 90)
		{
			head.ResetTransform();
			head.RotateBy(-aimDir.Angle() + 180, Vec2f());
		}
		
		if (Maths::Round(angDeg) != 90 && this.get_u32("nextAttack") < getGameTime())
		{
			if (isServer())
			{
				CBlob@ blob = server_CreateBlob("chickencannonshell", this.getTeamNum(), this.getPosition());
				blob.setVelocity(-aimDir * v * 0.65f);
				blob.set_u32("primed_time", getGameTime() + 5);
			}
			
			if (isClient())
			{
				Vec2f screenPos = getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos());
				Vec2f soundDir = screenPos - this.getPosition();
				f32 distance = soundDir.getLength();
				soundDir.Normalize();
			
				float volume = 1.50f - (distance / 2000.0f);
				
				if (volume > 0.1f)
				{
					Vec2f screenPos = getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos());
					Sound::Play("SAT_Fire.ogg", screenPos + soundDir, volume, Maths::Max(0.3f, 1.0f - (distance / 2000.0f)));
				}
			}
			
			ShakeScreen(200.0f, 50.0f, this.getPosition());
			this.set_u32("nextAttack", getGameTime() + 300);
		}
	}
}

bool isVisible(CBlob@ blob, CBlob@ target)
{
	Vec2f col;
	return !getMap().rayCastSolidNoBlobs(blob.getPosition(), target.getPosition(), col);
}