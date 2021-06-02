#include "GunCommon.as";

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

				GunSettings@ settings;
				gun.get("gun_settings", @settings);

				u32 clip = gun.get_u8("clip");
				u32 total = settings.TOTAL;

				hud.SetCursorImage("WeaponCursor.png", Vec2f(32, 32));
				hud.SetCursorOffset(Vec2f(-32, -32));

				if (gun.get_bool("doReload") && !gun.hasTag("CustomShotgunReload"))
				{
					//Reloading sequence
					u32 endTime = settings.RELOAD_TIME;
					u32 reloadTime = gun.get_u8("actionInterval");
					u32 startTime = endTime - reloadTime;
					hud.SetCursorFrame(Maths::Clamp(1.0f + Maths::Round((f32(startTime) / f32(endTime)) * 7.0f), 0, 8));
				}
				else
				{
					hud.SetCursorFrame(Maths::Clamp((clip > 0 ? 1.0f : 0.0f) + Maths::Round((f32(clip) / f32(total)) * 7.0f), 0, 8));
				}
				hud.ShowCursor();
			}
		}
	}
}
