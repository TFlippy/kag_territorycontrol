// A script by TFlippy & Pirate-Rob

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");

	this.set_string("text", "");

	this.addCommandID("write");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("write"))
		{
			CBlob @caller = getBlobByNetworkID(params.read_u16());
			CBlob @carried = getBlobByNetworkID(params.read_u16());

			if (caller !is null && carried !is null)
			{
				this.set_string("text", carried.get_string("text"));
				this.Sync("text", true);
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
	const f32 renderRadius = (blob.getRadius()) * 2.00f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;

	if (true)
	{
		CCamera@ camera = getCamera();
		f32 zoom = camera.targetDistance;

		if (zoom < 1) return;

		// print("hello");

		string text = blob.get_string("text");
		Vec2f pos = getDriver().getScreenPosFromWorldPos(this.getBlob().getPosition() + Vec2f(0, -1));

		Vec2f dimensions;
		if (zoom == 2) GUI::SetFont("menu");
		GUI::GetTextDimensions(text, dimensions);

		// GUI::DrawWindow(pos - dimensions, pos + dimensions);
		GUI::DrawTranslatedTextCentered(text, pos, SColor(255, 0, 0, 0));
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
	}
}
