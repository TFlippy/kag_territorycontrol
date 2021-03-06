// A script by TFlippy & Pirate-Rob

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "BuilderHittable.as";
#include "Hitters.as";

namespace Sign
{
	enum State
	{
		blank = 0,
		written
	}
}

void onInit(CBlob@ this)
{

	//this.set_u8("state", Sign::blank);
	this.getSprite().SetAnimation("written");
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	this.Tag("builder always hit");
	
	this.set_bool("isActive", false);
	if (!this.exists("text")) this.set_string("text", "!write -text-");
	//if (this.exists("text")) this.getSprite().SetAnimation("written");
	
	this.addCommandID("write");
}

void onInit(CSprite@ this)
{

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("write"))
		{
			CBlob @caller = getBlobByNetworkID(params.read_u16());
			CBlob @carried = getBlobByNetworkID(params.read_u16());

			this.set_string("text", carried.get_string("text"));
			this.Sync("text", true);
	
			carried.server_Die();
		}
	}
}

void onRender(CSprite@ this)
{
	
	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 1.50f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;
	
	if (blob is null) return;

	if (getHUD().menuState != 0) return;

	CBlob@ localBlob = getLocalPlayerBlob();
	Vec2f pos2d = blob.getInterpolatedScreenPos();

	if (localBlob is null) return;

	if (
	    ((localBlob.getPosition() - blob.getPosition()).Length() < 0.5f * (localBlob.getRadius() + blob.getRadius())) &&
	    (!getHUD().hasButtons()) || (mouseOnBlob))
	{
		// draw drop time progress bar
		int top = pos2d.y - 2.5f * blob.getHeight() + 000.0f;
		int left = 200.0f;
		int margin = 4;
		Vec2f dim;
		string label = getTranslatedString(blob.get_string("text"));
		label += "\n";
		GUI::SetFont("menu");
		GUI::GetTextDimensions(label , dim);
		dim.x = Maths::Min(dim.x, 200.0f);
		dim.x += margin;
		dim.y += margin;
		dim.y *= 1.0f;
		top += dim.y;
		Vec2f upperleft(pos2d.x - dim.x / 2 - left, top - Maths::Min(int(2 * dim.y), 250));
		Vec2f lowerright(pos2d.x + dim.x / 2 - left, top - dim.y);
		GUI::DrawText(label, Vec2f(upperleft.x + margin, upperleft.y + margin + margin),
		              Vec2f(upperleft.x + margin + dim.x, upperleft.y + margin + dim.y),
		              SColor(255, 0, 0, 0), false, false, true);
	}
}

		// this.set_string("text", carried.get_string("text"));
		// this.Sync("text");
	
		// carried.server_Die();

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller is null) return;
	if (!this.isOverlapping(caller)) return;	
	
	CBlob@ carried = caller.getCarriedBlob();
	if(carried !is null && carried.getName() == "paper")
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(carried.getNetworkID());
	
		CButton@ buttonWrite = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("write"), "Write something on the sign.", params);
	}
}