//default actor hud
// a bar with hearts in the bottom left, bottom right free for actor specific stuff

#include "Survival_Structs.as";

void renderBackBar(Vec2f origin, f32 width, f32 scale)
{
	for (f32 step = 0.0f; step < width/scale - 64; step += 64.0f * scale)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(step * scale, 0), scale);
	}

	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(width - 128 * scale, 0), scale);
}

void renderFrontStone(Vec2f farside, f32 width, f32 scale)
{
	for (f32 step = 0.0f; step < width/scale - 16.0f*scale*2; step += 16.0f*scale*2)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16,32), farside+Vec2f(-step*scale - 32*scale,0), scale);
	}

	if (width > 16)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), farside + Vec2f(-width, 0), scale);
	}

	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), farside + Vec2f(-width - 32 * scale, 0), scale);
	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16, 32), farside, scale);
}

void renderHPBar(CBlob@ blob, Vec2f origin)
{
	u8 segmentWidth = 24; // 32
	GUI::DrawIcon("GUI/jends2.png", 0, Vec2f(8, 16), origin+Vec2f(-8, 0)); // ("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), origin + Vec2f(-segmentWidth, 0));
	u8 HPs = 0;
	for (f32 step = 0.0f; step < Maths::Max(blob.getHealth(), blob.getInitialHealth()); step += 0.5f)
	{
		GUI::DrawIcon("GUI/HPback.png", 0, Vec2f(12, 16), origin + Vec2f(segmentWidth * HPs, 0)); // ("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(16, 32), origin + Vec2f(segmentWidth * HPs, 0));
		f32 thisHP = blob.getHealth() - step;
		if (thisHP > 0)
		{
			string heartFile = step >= blob.getInitialHealth() ? "GUI/HPbar_Bonus.png" : "GUI/HPbar.png";

			// Vec2f heartoffset = (Vec2f(2, 10) * 2);
			Vec2f heartpos = origin + Vec2f(segmentWidth * HPs, 0); // origin + Vec2f(segmentWidth * HPs, 0) + heartoffset;
			if (thisHP <= 0.125f) { GUI::DrawIcon(heartFile, 4, Vec2f(16, 16), heartpos); } // Vec2f(12, 12)
			else if (thisHP <= 0.25f) { GUI::DrawIcon(heartFile, 3, Vec2f(16, 16), heartpos); } // Vec2f(12, 12)
			else if (thisHP <= 0.375f) { GUI::DrawIcon(heartFile, 2, Vec2f(16, 16), heartpos); } // Vec2f(12, 12)
			else if (thisHP > 0.375f) { GUI::DrawIcon(heartFile, 1, Vec2f(16, 16), heartpos); } // else { GUI::DrawIcon(heartFile, 1, Vec2f(12, 12), heartpos); }
			else { GUI::DrawIcon(heartFile, 0, Vec2f(16, 16), heartpos); }
		}
		HPs++;
	}
	GUI::DrawIcon("GUI/jends2.png", 1, Vec2f(8, 16), origin + Vec2f(segmentWidth * HPs, 0)); // ("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16, 32), origin + Vec2f(32 * HPs, 0));
}

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	if (g_videorecording) return;
	CBlob@ blob = this.getBlob();
	if (blob.isMyPlayer())
	{
		RenderUpkeepHUD(blob);
		RenderTeamInventoryHUD(blob);
	
		GUI::DrawIcon("GUI/jslot.png", 1, Vec2f(32, 32), Vec2f(2, 2));
		renderHPBar(blob, Vec2f(52, 10));
	}
}

void RenderUpkeepHUD(CBlob@ this)
{
	const u8 myTeam = this.getTeamNum();

	if (myTeam >= 100) return;

	u16 scWidth = getScreenWidth();

	TeamData@ team_data;
	GetTeamData(myTeam, @team_data);

	if (team_data is null) return;
	if (team_data.upkeep_cap == 0) return;

	f32 upkeep_ratio = f32(team_data.upkeep) / f32(team_data.upkeep_cap);
	f32 upkeep_ratio_clamped = Maths::Max(0, Maths::Min(upkeep_ratio, 1));

	u8 color_green = u8(Maths::Min(510.0f * (1.00f - upkeep_ratio_clamped), 255));
	u8 color_red = u8(Maths::Min(510.0f * upkeep_ratio_clamped, 255));

	GUI::SetFont("menu");
	GUI::DrawText("Faction Upkeep: " + team_data.upkeep + " / " + team_data.upkeep_cap, Vec2f(scWidth - 352, 42), SColor(255, color_red, color_green, 0));
	GUI::SetFont("");

	string msg = "";

	if (upkeep_ratio >= 0.75f) { msg += "Your upkeep is too high, upgrade or\nbuild more Camps!"; }
	else { msg += "Your upkeep is balanced, therefore\nyour team will receive extra bonuses."; }

	GUI::DrawText(msg, Vec2f(scWidth - 352, 62 + Maths::Sin(getGameTime() / 8.0f)), SColor(255, color_red, color_green, 0));

	bool has_bonuses = false;
	bool has_penalties = false;

	if (upkeep_ratio < 1.00f)
	{
		string msg_bonuses = "Bonuses:\n";
		if (upkeep_ratio <= UPKEEP_RATIO_BONUS_COIN_GAIN) { msg_bonuses += "- Higher coin gain\n"; has_bonuses = true; }
		if (upkeep_ratio <= UPKEEP_RATIO_BONUS_MINING) { msg_bonuses += "- Increased mining yield\n"; has_bonuses = true; }
		if (upkeep_ratio <= UPKEEP_RATIO_BONUS_RESPAWN_TIME) { msg_bonuses += "- Reduced respawn time\n"; has_bonuses = true; }

		if (has_bonuses) GUI::DrawText(msg_bonuses, Vec2f(scWidth - 352, 90 + Maths::Sin(getGameTime() / 8.0f)), SColor(255, color_red, color_green, 0));
	}

	if (upkeep_ratio > 1.00f)
	{
		string msg_penalties = "Penalties:\n";
		if (upkeep_ratio >= UPKEEP_RATIO_PENALTY_RECRUITMENT) { msg_penalties += "- Recruitment disabled\n"; has_penalties = true; }
		if (upkeep_ratio >= UPKEEP_RATIO_PENALTY_COIN_DROP) { msg_penalties += "- Higher coin loss on death\n"; has_penalties = true; }
		if (upkeep_ratio >= UPKEEP_RATIO_PENALTY_RESPAWN_TIME) { msg_penalties += "- Increased respawn time\n"; has_penalties = true; }
		if (upkeep_ratio >= UPKEEP_RATIO_PENALTY_STORAGE && team_data.storage_enabled) { msg_penalties += "- No Remote storage\n"; has_penalties = true; }

		if (has_penalties) GUI::DrawText(msg_penalties, Vec2f(scWidth - 352, 90 + Maths::Sin(getGameTime() / 8.0f)), SColor(255, color_red, color_green, 0));
	}
}

// Made by Merser (Mirsario)
const string[] teamItems =
{
	"mat_wood",
	"mat_oil",
	"mat_copperwire",
	"mat_plasteel",
	"mat_matter",
	"mat_fuel",
	"mat_methane",
	"mat_acid",
	"mat_meat",
	"foodcan",
	"grain",
	"pumpkin",
	"mat_mithrilenriched"
};

const string[] teamOres =
{
	"mat_stone",
	"mat_copper",
	"mat_iron",
	"mat_coal",
	"mat_gold",
	"mat_mithril",
	"mat_dirt"
};

const string[] teamIngots =
{
	"mat_concrete",
	"mat_copperingot",
	"mat_ironingot",
	"mat_steelingot",
	"mat_goldingot",
	"mat_mithrilingot",
	"mat_sulphur"
};

const string[] teamAmmo =
{
	"ammo_lowcal",
	"ammo_highcal",
	"ammo_shotgun",
	"ammo_gatling",
	"ammo_bandit"
};

const string[] matInvName =
{
	"Materials.png",
	"Material_Oil.png",
	"Material_CopperWire.png",
	"Material_Plasteel.png",
	"Material_Matter.png",
	"Material_Fuel.png",
	"Material_Methane.png",
	"Material_Acid.png",
	"Material_Meat.png",
	"FoodCan.png",
	"Grain.png",
	"Pumpkin.png",
	"Material_MithrilEnriched.png"
};

const string[] oreInvName =
{
	"Materials.png",
	"Material_Copper.png",
	"Material_Iron.png",
	"Material_Coal.png",
	"Materials.png",
	"Material_Mithril.png",
	"Material_Dirt.png"
};

const string[] ingotInvName =
{
	"Material_Concrete.png",
	"Material_CopperIngot.png",
	"Material_IronIngot.png",
	"Material_SteelIngot.png",
	"Material_GoldIngot.png",
	"Material_MithrilIngot.png",
	"Material_Sulphur.png"
};

const string[] ammoInvName =
{
	"Material_BanditAmmo.png",
	"Material_PistolAmmo.png",
	"Material_RifleAmmo.png",
	"Material_GatlingAmmo.png",
	"Material_ShotgunAmmo.png"
};

void RenderTeamInventoryHUD(CBlob@ this)
{
	Vec2f hudPos = Vec2f(0, 0);
	Vec2f hudPos2 = Vec2f(0, 0); //ammo and bombs

	int playerTeam = this.getTeamNum();
	if (playerTeam < 7)
	{
		TeamData@ team_data;
		GetTeamData(playerTeam, @team_data);

		string[] itemsToShow;
		int[] itemAmounts;
		int[] jArray;
		int[] bArray;

		bool closeEnough = false;
		bool storageEnabled = false;

		if (team_data != null)
		{
			const u16 upkeep = team_data.upkeep;
			const u16 upkeep_cap = team_data.upkeep_cap;
			const f32 upkeep_ratio = f32(upkeep) / f32(upkeep_cap);
			const bool faction_storage_enabled = team_data.storage_enabled;

			storageEnabled = upkeep_ratio < UPKEEP_RATIO_PENALTY_STORAGE && faction_storage_enabled;
		}

		{
			CBlob@[] smartStorageBlobs;
			getBlobsByTag("smart_storage", @smartStorageBlobs);
			
			for (u8 i = 0; i < smartStorageBlobs.length; i++) 
			{
				CBlob@ baseBlob = smartStorageBlobs[i];
				if (baseBlob.getTeamNum() != playerTeam)
				{
					continue;
				}

				if (this.getDistanceTo(baseBlob) < 250.0f)
				{
					closeEnough = true;
				}

				const u16 overall_quantity = baseBlob.get_u16("smart_storage_quantity");
				if (overall_quantity > 0)
				{
					u32 cur_quantity;
					string[] templist = teamItems;
					for (u8 z = 0; z < 4; z++)
					{
						switch (z)
						{
							case 0: templist = teamItems;	break;
							case 1: templist = teamOres;	break;
							case 2: templist = teamIngots;	break;
							case 3: templist = teamAmmo;	break;
						}
						for (u8 j = 0; j < templist.length; j++)
						{
							string blobName = templist[j];
							if (!baseBlob.exists("Storage_"+blobName)) continue;
							cur_quantity = baseBlob.get_u32("Storage_"+blobName);
							if (cur_quantity <= 0) continue;

							bool doContinue = false;
							for (u16 k = 0; k < itemsToShow.length; k++)
							{
								if (itemsToShow[k] == blobName)
								{
									itemAmounts[k] = itemAmounts[k] + cur_quantity;
									doContinue = true;
									break;
								}
							}
							if (doContinue) continue;
							itemAmounts.push_back(cur_quantity);
							itemsToShow.push_back(blobName);
							jArray.push_back(-1);
						}
					}
				}
			}
		}
		

		bool storageAccessible = closeEnough && storageEnabled;

		GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), Vec2f((getScreenWidth() - 54), 8) + hudPos);
		GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), Vec2f((getScreenWidth() - 102), 8) + hudPos);
		GUI::DrawIcon("MenuItems.png", storageAccessible ? 28 : 29, Vec2f(32, 32), Vec2f((getScreenWidth() - 110), 0) + hudPos);
		GUI::SetFont("menu");
		GUI::DrawText("Remote access to team storages - ", Vec2f((getScreenWidth() - 352), 22) + hudPos, storageAccessible ? SColor(255, 0, 255, 0) : SColor(255, 255, 0, 0));

		//draw team emblem
		if (playerTeam < 4) { GUI::DrawIcon("Emblems.png", playerTeam, Vec2f(32, 32), Vec2f((getScreenWidth() - 62), 0) + hudPos); }
		else { GUI::DrawIcon("CTFGui.png", 0, Vec2f(19, 19), Vec2f((getScreenWidth() - 48), 10) + hudPos, 1.0f, playerTeam); }

		int j = 0;
		int b = 0;
		//indian code, gotta repeat it two times
		for (u8 i = 0; i < itemsToShow.length; i++)
		{
			//draw ores
			string itemName = itemsToShow[i];
			bool passed = false;
			const int quantity = itemAmounts[i];
			int oreId = -1;
			for (u8 k = 0; k < teamOres.length; k++)
			{
				if (teamOres[k] == itemName)
				{
					oreId = k;
					passed = true;
					break;
				}
			}
			if (!passed || quantity < 1)
			{
				continue;
			}
			bool hasIngot = false;
			for (u8 l = 0; l < itemsToShow.length; l++)
			{
				if (teamIngots[oreId] == itemsToShow[l])
				{
					hasIngot = true;
					break;
				}
			}
			jArray[i] = j;

			Vec2f itemPos = Vec2f(getScreenWidth() - 150, 54 + j * 46) + hudPos;
			GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), itemPos);
			GUI::DrawIcon("GUI/jslot.png", 2, Vec2f(32, 32), itemPos + Vec2f(48, 0));

			if (!hasIngot)
			{
				GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), itemPos + Vec2f(96, 0));
				GUI::DrawIcon(ingotInvName[oreId], 3,Vec2f(16, 16), itemPos + Vec2f(104, 8));

				GUI::SetFont("menu");
				GUI::DrawText("0", itemPos + Vec2f(126, 26), SColor(255, 255, 0, 0));
			}

			int l = int(("" + quantity).get_length());
			if (quantity > 0)
			{
				if (teamOres[oreId] == "mat_gold") { GUI::DrawIcon("Materials.png", 26, Vec2f(16, 16), itemPos + Vec2f(8, -2)); }
				else if (teamOres[oreId] == "mat_stone") { GUI::DrawIcon("Materials.png", 24, Vec2f(16, 16), itemPos + Vec2f(8, -2)); }
				else { GUI::DrawIcon(oreInvName[oreId], 3, Vec2f(16, 16), itemPos + Vec2f(8, -2)); }

				GUI::SetFont("menu");
				GUI::DrawText("" + quantity, itemPos + Vec2f(38 - (l * 8), 26), SColor(255, 240, 225, 225));
			}
			j++;
		}
		int jMax = j;
		for (u8 i = 0; i < itemsToShow.length; i++)
		{
			//draw ingots
			int j2 = j;
			string itemName = itemsToShow[i];
			bool passed = false;
			int oreId = -1;
			const int quantity = itemAmounts[i];
			for (u8 k = 0; k < teamIngots.length; k++)
			{
				if (teamIngots[k] == itemName)
				{
					oreId = k;
					passed = true;
					break;
				}
			}
			if (!passed || quantity < 1)
			{
				continue;
			}
			bool hasOre = false;
			for (u8 l = 0; l < itemsToShow.length; l++)
			{
				if (teamOres[oreId] == itemsToShow[l])
				{
					j2 = jArray[l];
					hasOre = true;
					break;
				}
			}

			Vec2f itemPos = Vec2f(getScreenWidth() - 54, 54 + j2 * 46) + hudPos;
			GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), itemPos);
			if (!hasOre)
			{
				GUI::DrawIcon("GUI/jslot.png", 2,Vec2f(32, 32), itemPos - Vec2f(48, 0));
				GUI::DrawIcon("GUI/jslot.png", 0,Vec2f(32, 32), itemPos - Vec2f(96, 0));

				if (teamOres[oreId] == "mat_gold") GUI::DrawIcon("Materials.png", 26, Vec2f(16, 16), itemPos + Vec2f(-88, -2));
				else if (teamOres[oreId] == "mat_stone") GUI::DrawIcon("Materials.png", 24, Vec2f(16, 16), itemPos + Vec2f(-88, -2));
				else GUI::DrawIcon(oreInvName[oreId], 3, Vec2f(16, 16), itemPos + Vec2f(-88, -2));

				GUI::SetFont("menu");
				GUI::DrawText("0", itemPos + Vec2f(-66, 26), SColor(255, 255, 0, 0));
			}

			SColor col = SColor(255, 240, 225, 225);
			int l = int(("" + quantity).get_length());
			if (quantity > 0)
			{
				GUI::DrawIcon(ingotInvName[oreId], 3,Vec2f(16, 16), itemPos + Vec2f(4, 2));

				GUI::SetFont("menu");
				GUI::DrawText("" + quantity, itemPos + Vec2f(38 - (l * 8), 26), col);
			}
			if (j2 >= jMax)
			{
				j++;
			}
		}
		for (u8 i = 0; i < itemsToShow.length; i++)
		{
			//draw everything but ores & ingots
			string itemName = itemsToShow[i];
			string itemInvName;
			bool passed = false;
			const int quantity = itemAmounts[i];
			for (u8 k = 0; k < teamItems.length; k++)
			{
				if (teamItems[k] == itemName)
				{
					passed = true;
					itemInvName = matInvName[k];
					break;
				}
			}
			if (!passed || quantity < 1)
			{
				continue;
			}

			Vec2f itemPos = Vec2f(getScreenWidth() - 54, 54 + j * 46) + hudPos;
			GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), itemPos);

			if (itemName == "mat_wood") GUI::DrawIcon("jitem.png", 2, Vec2f(16, 16), itemPos + Vec2f(8, 2), 1.0f);
			else GUI::DrawIcon(itemInvName, 0, Vec2f(16, 16), itemPos + Vec2f(8, 8));

			SColor col = SColor(255, 240, 225, 225);
			int l = int(("" + quantity).get_length());
			if (quantity != 1)
			{
				GUI::SetFont("menu");
				GUI::DrawText("" + quantity, itemPos + Vec2f(38 - (l * 8), 26), col);
			}
			j++;
		}

		// Ammo and Bombs
		for (u8 i = 0; i < itemsToShow.length; i++)
		{
			//draw teamAmmo
			string itemName = itemsToShow[i];
			string itemInvName;
			bool passed = false;
			const int quantity = itemAmounts[i];
			for (u8 k = 0; k < teamAmmo.length; k++)
			{
				if (teamAmmo[k] == itemName)
				{
					passed = true;
					itemInvName = ammoInvName[k];
					break;
				}
			}
			if (!passed || quantity < 1)
			{
				continue;
			}

			Vec2f itemPos = Vec2f(getScreenWidth() / 1.52 - 94 + b * 46, getScreenHeight() - 57) + hudPos2;
			GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), itemPos);

			GUI::DrawIcon(itemInvName, 3, Vec2f(16, 16), itemPos + Vec2f(8, 8));

			SColor col = SColor(255, 240, 225, 225);
			int l = int(("" + quantity).get_length());
			if (quantity != 1)
			{
				GUI::SetFont("menu");
				GUI::DrawText("" + quantity, itemPos + Vec2f(38 - (l * 8), 26), col);
			}
			b--;
		}
	}
}
