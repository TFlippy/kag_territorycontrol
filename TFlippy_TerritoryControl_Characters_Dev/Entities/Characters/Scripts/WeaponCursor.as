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
				GunSettings@ settings;
				gun.get("gun_settings", @settings);
				
				if (settings !is null)
				{
					CHUD@ hud = getHUD();
					// CControls@ controls = getControls();
				
					u32 ammo_count = 0;
					CBlob@ ammo = getAmmoBlob(gun, ammo_count);
					
					s32 ammo_capacity = settings.ammo_count_max;
					
					if (ammo !is null)
					{
						
						// s32 ammo_count = this.getBlobCount("mat_pistolammo");

						
						
						// u32 clip = gun.get_u32("gun_clip");
						// u32 clipSize = gun.get_u32("gun_clipSize");
						
						
						
						
						
						// if (!gun.get_bool("gun_doReload") || gun.get_bool("gun_shotgunReload"))
						// {
							// hud.SetCursorFrame(Maths::Clamp((clip == 0 ? 0.0f : 1.0f) + Maths::Round((f32(clip) / f32(clipSize)) * 7.0f), 0, 8));
						// }
						// else
						// {
							// u32 reloadTime = gun.get_u32("gun_reload_time");
							// u32 startTime =	endTime - reloadTime;
							// u32 relative = gameTime - startTime;
							// hud.SetCursorFrame(Maths::Clamp(1.0f + Maths::Floor((f32(relative) / f32(reloadTime)) * 7.0f), 0, 8));
						// }
						
						
					}
					
					hud.SetCursorImage("WeaponCursor.png", Vec2f(32, 32));
					hud.SetCursorOffset(Vec2f(-32, -32));
					u32 gameTime = getGameTime();
					u32 endTime = gun.get_u32("gun_readyTime");
					
					// Vec2f mousePos = controls.getMouseScreenPos();
					// GUI::DrawTextCentered(ammo.getInventoryName(), mousePos + Vec2f(0, 40), SColor(255, 255, 255, 255));
					
					
					hud.SetCursorFrame(Maths::Clamp((ammo_count == 0 ? 0.0f : 1.0f) + Maths::Round((f32(ammo_count) / f32(ammo_capacity)) * 7.0f), 0, 8));
					// if (!gun.get_bool("gun_doReload") || gun.get_bool("gun_shotgunReload"))
					// {
						// hud.SetCursorFrame(Maths::Clamp((clip == 0 ? 0.0f : 1.0f) + Maths::Round((f32(clip) / f32(clipSize)) * 7.0f), 0, 8));
					// }
					// else
					// {
						// u32 reloadTime = gun.get_u32("gun_reload_time");
						// u32 startTime =	endTime - reloadTime;
						// u32 relative = gameTime - startTime;
						// hud.SetCursorFrame(Maths::Clamp(1.0f + Maths::Floor((f32(relative) / f32(reloadTime)) * 7.0f), 0, 8));
					// }
					
					hud.ShowCursor();
				}
			}
		}
	}
}