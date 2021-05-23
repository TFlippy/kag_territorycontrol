void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob !is null && blob.isMyPlayer())
	{
		CBlob@ gun = blob.getCarriedBlob();
		if (gun !is null)
		{
			if (gun.hasTag("weapon"))
			{
				CHUD@ hud = getHUD();
				// CControls@ controls = getControls();

				u32 clip = gun.get_u8("clip");
				u32 total = gun.get_u8("total");

				hud.SetCursorImage("WeaponCursor.png", Vec2f(32, 32));
				hud.SetCursorOffset(Vec2f(-32, -32));

				hud.SetCursorFrame(Maths::Clamp((clip > 0 ? 1.0f : 0.0f) + Maths::Round((f32(clip) / f32(total)) * 7.0f), 0, 8));
				hud.ShowCursor();
			}
		}
	}
}
