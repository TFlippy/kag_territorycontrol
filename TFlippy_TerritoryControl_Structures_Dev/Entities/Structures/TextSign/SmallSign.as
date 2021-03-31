// A script by TFlippy & Pirate-Rob & Gingerbeard

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");

	this.set_string("text", "!write -text-");

	this.addCommandID("write");
	this.addCommandID("addwrite");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("write") || (cmd == this.getCommandID("addwrite")))
		{
			CBlob @caller = getBlobByNetworkID(params.read_u16());
			CBlob @carried = getBlobByNetworkID(params.read_u16());

			if (caller !is null && carried !is null)
			{
				if (cmd == this.getCommandID("addwrite"))
				{
					this.set_string("text", this.get_string("text") + " " + carried.get_string("text"));
				}
				else
				{
					this.set_string("text", carried.get_string("text"));
				}
				this.Sync("text", true);
				this.getSprite().SetAnimation("written");
				carried.server_Die();
			}
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
	Vec2f pos2d = blob.getScreenPos();

	if (localBlob is null) return;

	if (((localBlob.getPosition() - blob.getPosition()).Length() < 0.5f * (localBlob.getRadius() + blob.getRadius())) &&
	   (!getHUD().hasButtons()) || (mouseOnBlob))
	{
		// draw drop time progress bar
		int top = pos2d.y - 2.5f * blob.getHeight() + 0.0f; //y offset
		int left = 0.0f; //x offset
		if (blob.get_string("text").length >= 29) left = 150.0f; //set to side if string is too long
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

		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, 0), this, this.getCommandID("write"), "Write something on the sign.", params);
		if (this.get_string("text") != "!write -text-" && (this.get_string("text").length <= 200))
		{
			CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, -6), this, this.getCommandID("addwrite"), "Write another sentence.", params);
		}
	}
}
