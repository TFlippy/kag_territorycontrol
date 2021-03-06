// draws a health bar on mouse hover

const f32 offset_y_overheal = 12;

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 0.95f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;
	if (mouseOnBlob)
	{
		//VV right here VV
		Vec2f pos2d = blob.getInterpolatedScreenPos() + Vec2f(0, 20);
		Vec2f dim = Vec2f(24, 8);
		const f32 y = blob.getHeight() * 2.4f;
		const f32 initialHealth = blob.getInitialHealth();
		
		if (initialHealth > 0.0f)
		{
			f32 ratio = blob.getHealth() / initialHealth;
			f32 ratio_clamped = Maths::Min(ratio, 1);
		
			if (ratio_clamped >= 0.0f)
			{
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 2, pos2d.y + y - 2), Vec2f(pos2d.x + dim.x + 2, pos2d.y + y + dim.y + 2));
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 2, pos2d.y + y + 2), Vec2f(pos2d.x - dim.x + ratio_clamped * 2.0f * dim.x - 2, pos2d.y + y + dim.y - 2), SColor(0xffac1512));
			}
			
			if (blob.getHealth() > initialHealth)
			{
				f32 overheal = blob.getHealth() - initialHealth;
				f32 ratio_overheal = overheal / initialHealth;
				
				GUI::DrawRectangle(Vec2f(pos2d.x - (24 * ratio_overheal) - 2, pos2d.y + y - 2 + offset_y_overheal), Vec2f(pos2d.x + (24 * ratio_overheal) + 2, pos2d.y + y + dim.y + 2 + offset_y_overheal));
				GUI::DrawRectangle(Vec2f(pos2d.x - (24 * ratio_overheal) + 2, pos2d.y + y + 2 + offset_y_overheal), Vec2f(pos2d.x + (24 * ratio_overheal) - 2, pos2d.y + y + dim.y - 2 + offset_y_overheal), SColor(0xfffbb818));
				
				// GUI::DrawRectangle(Vec2f(pos2d.x - (overheal * 12) - 4, pos2d.y + y - 2 + offset_y_overheal), Vec2f(pos2d.x + (overheal * 12) + 4, pos2d.y + y + dim.y + 2 + offset_y_overheal));
				// GUI::DrawRectangle(Vec2f(pos2d.x - (overheal * 12), pos2d.y + y + 2 + offset_y_overheal), Vec2f(pos2d.x + (overheal * 12), pos2d.y + y + dim.y - 2 + offset_y_overheal), SColor(0xfffbb818));
			}
		}
	}
}