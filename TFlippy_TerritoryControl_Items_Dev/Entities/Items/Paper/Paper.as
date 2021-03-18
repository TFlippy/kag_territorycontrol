void onInit(CBlob@ this)
{
	if (!this.exists("text")) this.set_string("text", "");
	this.setInventoryName(this.get_string("text"));
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 2.00f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;

	if (mouseOnBlob)
	{
		string text = blob.get_string("text");
		Vec2f pos = getDriver().getScreenPosFromWorldPos(this.getBlob().getPosition() + Vec2f(0, 8));

		Vec2f dimensions;
		GUI::SetFont("menu");
		GUI::GetTextDimensions(text, dimensions);

		const Vec2f margin = Vec2f(8, 8);

		GUI::DrawWindow(pos - margin - dimensions / 2, pos + margin + dimensions / 2);
		GUI::DrawTranslatedTextCentered(text, pos, SColor(255, 0, 0, 0));
	}
}