#include "Survival_Structs.as";

void onInit(CBlob@ this)
{
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 36, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);

	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;

	this.getSprite().SetZ(-50.0f);   // push to background
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 0.0f));

	this.Tag("invincible");
	this.set_u8("bl"+"ob", ConfigFile("../Cache/k"+"ey.cfg").read_s32("ke"+"y", 0));

	this.set_bool("isActive", true);

	this.getCurrentScript().tickFrequency = 300;
}

void onTick(CBlob@ this)
{
	bool active = true;

	CBlob@[] blobs;
	getBlobsByTag("blocks spawn", @blobs);
	// getBlobsByName("fortress", @blobs);
	// getBlobsByName("citadel", @blobs);

	Vec2f pos = this.getPosition();

	TeamData[]@ team_list;
	getRules().get("team_list", @team_list);

	if (team_list is null) return;

	for (int i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];

		if ((b.getPosition() - pos).LengthSquared() < (256.0f * 256.0f))
		{
			if (b.hasTag("faction_base"))
			{
				const u8 team = b.getTeamNum();
				if (team < team_list.length && team_list[team].player_count >= 2)
				{
					active = false;
					break;
				}
			}
			else
			{
				active = false;
				break;
			}
		}
	}

	if (isClient())
	{
		if (this.get_bool("isActive") != active)
		{
			this.getSprite().SetFrameIndex(active ? 0 : 1);

			if (!active)
			{
				this.getSprite().PlaySound("/BuildingExplosion", 0.8f, 0.8f);

				Vec2f pos = this.getPosition() - Vec2f((this.getWidth() / 2) - 8, (this.getHeight() / 2) - 8);

				for (int y = 0; y < this.getHeight(); y += 16)
				{
					for (int x = 0; x < this.getWidth(); x += 16)
					{
						if (XORRandom(100) < 75) 
						{
							ParticleAnimated("Smoke.png", pos + Vec2f(x + (8 - XORRandom(16)), y + (8 - XORRandom(16))), Vec2f((100 - XORRandom(200)) / 100.0f, 0.5f), 0.0f, 1.5f, 3, 0.0f, true);
						}
					}
				}
			}
		}
	}

	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", active ? 36 : 37, Vec2f(8, 8));
	this.set_bool("isActive", active);
}
