#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("ignore fall");
	this.Tag("builder always hit");

	this.set_f32("pickup_priority", 0.125f); // The lower, the higher priority
	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2);
	}
	
	if (isServer())
	{		
		CBlob@ blob = server_CreateBlobNoInit("nanobot");
		blob.set_u16("remote_netid", this.getNetworkID());
		blob.server_setTeamNum(this.getTeamNum());
		blob.set_Vec2f("target_position", this.getPosition() + Vec2f(0, -16));
		blob.set_u8("mode", 1);
		blob.setPosition(this.getPosition());
		
		blob.Init();

		this.set_u16("remote_netid", blob.getNetworkID());
	}
}

void onTick(CBlob@ this)
{	
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point !is null)
		{
			CBlob@ holder = point.getOccupied();
			if (holder !is null)
			{
				Vec2f pos = holder.getAimPos();
				
				CBlob@ remote = getBlobByNetworkID(this.get_u16("remote_netid"));
				if (remote !is null && remote.getName() == "nanobot")
				{
					u8 mode = 1;
					if (point.isKeyPressed(key_action1) || holder.isKeyPressed(key_action1)) mode = 0;
					else if (point.isKeyPressed(key_action2) || holder.isKeyPressed(key_action2)) mode = 2;
				
					remote.set_Vec2f("target_position", pos);
					remote.set_u8("mode", mode);
				}
			}
		}
	}
}

void onRender(CSprite@ this)
{
	if (this is null) {return;}

	AttachmentPoint@ ap = this.getBlob().getAttachments().getAttachmentPointByName("PICKUP");
	if (ap is null) {return;}
	
	CBlob@ holder = ap.getOccupied();
	
	if (holder !is null && holder.isMyPlayer())
	{
		CBlob@ remote = getBlobByNetworkID(this.getBlob().get_u16("remote_netid"));
		if (remote !is null && remote.getName() == "nanobot")
		{
			DrawFillCount(this.getBlob(), remote.get_f32("fill"));
		}
	}
}

void DrawFillCount(CBlob@ this, u16 amount)
{
	Vec2f pos2d1 = this.getScreenPos() - Vec2f(0, 10);

	Vec2f pos2d = this.getScreenPos() - Vec2f(0, 60);
	Vec2f dim = Vec2f(20, 8);
	const f32 y = this.getHeight() * 2.4f;
	f32 charge_percent = 1.0f;

	Vec2f ul = Vec2f(pos2d.x - dim.x, pos2d.y + y);
	Vec2f lr = Vec2f(pos2d.x - dim.x + charge_percent * 2.0f * dim.x, pos2d.y + y + dim.y);

	if (this.isFacingLeft())
	{
		ul -= Vec2f(8, 0);
		lr -= Vec2f(8, 0);

		f32 max_dist = ul.x - lr.x;
		ul.x += max_dist + dim.x * 2.0f;
		lr.x += max_dist + dim.x * 2.0f;
	}

	f32 dist = lr.x - ul.x;
	Vec2f upperleft((ul.x + (dist / 2.0f)) + 4.0f, pos2d1.y + this.getHeight() + 30);
	Vec2f lowerright((ul.x + (dist / 2.0f)), upperleft.y + 20);

	//GUI::DrawRectangle(upperleft - Vec2f(0,20), lowerright , SColor(255,0,0,255));

	string reqsText = "" + amount;

	u8 numDigits = reqsText.size();

	upperleft -= Vec2f((float(numDigits) * 4.0f), 0);
	lowerright += Vec2f((float(numDigits) * 4.0f), 0);

	GUI::DrawRectangle(upperleft, lowerright);
	GUI::SetFont("menu");
	GUI::DrawText(reqsText, upperleft + Vec2f(2, 1), color_white);
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	detached.Untag("noLMB");
	// detached.Untag("noShielding");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	attached.Tag("noLMB");
	// attached.Tag("noShielding");
}

