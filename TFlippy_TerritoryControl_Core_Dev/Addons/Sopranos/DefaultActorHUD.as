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
	int segmentWidth = 24; // 32
	GUI::DrawIcon("GUI/jends2.png", 0, Vec2f(8, 16), origin+Vec2f(-8, 0)); // ("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), origin + Vec2f(-segmentWidth, 0));
	int HPs = 0;
	for (f32 step = 0.0f; step < Maths::Max(blob.getHealth(), blob.getInitialHealth()); step += 0.5f)
	{
		GUI::DrawIcon("GUI/HPback.png", 0, Vec2f(12, 16), origin + Vec2f(segmentWidth * HPs, 0)); // ("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(16, 32), origin + Vec2f(segmentWidth * HPs, 0));
		f32 thisHP = blob.getHealth() - step;
		if (thisHP > 0)
		{
			string heartFile = step >= blob.getInitialHealth() ? "GUI/HPbar_Bonus.png" : "GUI/HPbar.png";

			// Vec2f heartoffset = (Vec2f(2, 10) * 2);
			Vec2f heartpos = origin + Vec2f(segmentWidth * HPs - 1, 0); // origin + Vec2f(segmentWidth * HPs, 0) + heartoffset;
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
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	// Vec2f dim = Vec2f(320,64);
	// Vec2f ul( getScreenWidth()/2.0f - dim.x/2.0f, getScreenHeight() - dim.y + 12 );
	// Vec2f lr( ul.x + dim.x, ul.y + dim.y );
	// GUI::DrawPane(ul, lr);
	// renderBackBar(ul, dim.x, 1.0f);
	// u8 bar_width_in_slots = blob.get_u8("gui_HUD_slots_width");
	// f32 width = bar_width_in_slots * 32.0f;
	// renderFrontStone( ul+Vec2f(dim.x,0), width, 1.0f);
	Vec2f topleft(52, 10);
	renderHPBar( blob, topleft); // ( blob, ul);

	RenderUpkeepHUD(blob);
	RenderTeamInventoryHUD(blob);
	GUI::DrawIcon("GUI/jslot.png", 1, Vec2f(32, 32), Vec2f(2, 2));
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
		if (upkeep_ratio <= UPKEEP_RATIO_BONUS_SPEED) { msg_bonuses += "- Increased movement speed\n"; has_bonuses = true; }
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
		if (upkeep_ratio >= UPKEEP_RATIO_PENALTY_SPEED) { msg_penalties += "- Reduced movement speed\n"; has_penalties = true; }

		if (has_penalties) GUI::DrawText(msg_penalties, Vec2f(scWidth - 352, 90 + Maths::Sin(getGameTime() / 8.0f)), SColor(255, color_red, color_green, 0));
	}
}

// Made by Merser (Mirsario)
const string[] teamItems =
{
	"mat_wood",
	"mat_oil",
	"mat_coal",
	"mat_steelingot",
	"mat_copperwire",
	"mat_plasteel",
	"mat_sulphur",
	"mat_fuel",
	"mat_methane",
	"mat_acid",
	"mat_mithrilenriched"
};

const string[] teamOres =
{
	"mat_stone",
	"mat_copper",
	"mat_iron",
	"mat_gold",
	"mat_mithril"
};

const string[] teamIngots =
{
	"mat_concrete",
	"mat_copperingot",
	"mat_ironingot",
	"mat_goldingot",
	"mat_mithrilingot"
};

const string[] teamBombs =
{
	"mat_incendiarybomb",
	"mat_bunkerbuster",
	"mat_mininuke",
	"mat_dirtybomb",
	"mat_smallbomb",
	"mat_stunbomb",
	"mat_clusterbomb",
	"mat_mithrilbomb",
	"mat_cocokbomb",
	"mat_bigbomb",
	"mat_bombita",
	"firejob",
	"fireboom",
	"cruisemissile",
	"guidedrocket"
};

const string[] teamAmmo =
{
	"mat_pistolammo",
	"mat_rifleammo",
	"mat_gatlingammo",
	"mat_shotgunammo"
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

		CBlob@[] baseBlobs;
		CBlob@[] itemsToShow;
		int[] itemAmounts;
		int[] jArray;
		int[] bArray;

		bool closeEnough = false;
		bool storageEnabled = false;

		if (team_data != null)
		{
			u16 upkeep = team_data.upkeep;
			u16 upkeep_cap = team_data.upkeep_cap;
			f32 upkeep_ratio = f32(upkeep) / f32(upkeep_cap);
			const bool faction_storage_enabled = team_data.storage_enabled;

			storageEnabled = upkeep_ratio < UPKEEP_RATIO_PENALTY_STORAGE && faction_storage_enabled;
		}

		getBlobsByTag("remote_storage", @baseBlobs);
		getBlobsByName("armory", @baseBlobs);

		for (int i = 0; i < baseBlobs.length; i++) 
		{
			CBlob@ baseBlob = baseBlobs[i];
			if (baseBlob.getTeamNum() != playerTeam)
			{
				continue;
			}

			if ((baseBlob.getPosition() - this.getPosition()).Length() < 250.0f)
			{
				closeEnough = true;
			}

			CInventory@ inv = baseBlob.getInventory();
			if (inv is null) return;

			for (int j = 0; j < inv.getItemsCount(); j++)
			{
				CBlob@ item = inv.getItem(j);
				string name = item.getInventoryName();
				bool doContinue = false;
				for (int k = 0; k < itemsToShow.length; k++)
				{
					if (itemsToShow[k].getInventoryName() == name)
					{
						itemAmounts[k] = itemAmounts[k] + item.getQuantity();
						doContinue = true;
						break;
					}
				}
				if (doContinue)
				{
					continue;
				}
				itemsToShow.push_back(item);
				itemAmounts.push_back(item.getQuantity());
				jArray.push_back(-1);
			}
			for (int b = 0; b < inv.getItemsCount(); b++)
			{
				CBlob@ item = inv.getItem(b);
				string name = item.getInventoryName();
				bool doContinue = false;
				for (int g = 0; g < itemsToShow.length; g++)
				{
					if (itemsToShow[g].getInventoryName() == name)
					{
						itemAmounts[g] = itemAmounts[g] + item.getQuantity();
						doContinue = true;
						break;
					}
				}
				if (doContinue)
				{
					continue;
				}
				itemsToShow.push_back(item);
				itemAmounts.push_back(item.getQuantity());
				bArray.push_back(-1);
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
		for (int i = 0; i < itemsToShow.length; i++)
		{
			//draw ores
			CBlob@ item = itemsToShow[i];
			string itemName = item.getName();
			bool passed = false;
			int oreId = -1;
			for (int k = 0; k < teamOres.length; k++)
			{
				if (teamOres[k] == itemName)
				{
					oreId = k;
					passed = true;
					break;
				}
			}
			if (!passed)
			{
				continue;
			}
			bool hasIngot = false;
			for (int l = 0; l < itemsToShow.length; l++)
			{
				if (teamIngots[oreId] == itemsToShow[l].getName())
				{
					hasIngot = true;
					break;
				}
			}
			jArray[i] = j;

			Vec2f itemPos = Vec2f(getScreenWidth() - 150, 54 + j * 46) + hudPos;
			GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), itemPos);
			GUI::DrawIcon("GUI/jslot.png", 2, Vec2f(32, 32), itemPos + Vec2f(48, 0));
			GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, itemPos + Vec2f(8, 8));

			if (!hasIngot)
			{
				GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), itemPos + Vec2f(96, 0));

				if (teamIngots[oreId] == "mat_concrete") { GUI::DrawIcon("Material_Concrete.png", 1,Vec2f(16, 16), itemPos + Vec2f(104, 8)); }
				else if (teamIngots[oreId] == "mat_copperingot") { GUI::DrawIcon("Material_CopperIngot.png", 0,Vec2f(16, 16), itemPos + Vec2f(104, 8)); }
				else if (teamIngots[oreId] == "mat_ironingot") { GUI::DrawIcon("Material_IronIngot.png", 0, Vec2f(16, 16), itemPos + Vec2f(104, 8)); }
				else if (teamIngots[oreId] == "mat_goldingot") { GUI::DrawIcon("Material_GoldIngot.png", 0, Vec2f(16, 16), itemPos + Vec2f(104, 8)); }
				else if (teamIngots[oreId] == "mat_mithrilingot") { GUI::DrawIcon("Material_MithrilIngot.png", 0, Vec2f(16, 16), itemPos + Vec2f(104, 8)); }

				GUI::SetFont("menu");
				GUI::DrawText("0", itemPos + Vec2f(126, 26), SColor(255, 255, 0, 0));
			}

			int quantity = itemAmounts[i];
			f32 ratio = float(quantity) / float(item.maxQuantity);
			SColor col = (SColor(255, 255, 255, 255));
			int l = int(("" + quantity).get_length());
			if (quantity != 1)
			{
				GUI::SetFont("menu");
				GUI::DrawText("" + quantity / 2, itemPos + Vec2f(38 - (l * 8), 26), col);
			}
			j++;
		}
		int jMax = j;
		for (int i = 0; i < itemsToShow.length; i++)
		{
			//draw ingots
			int j2 = j;
			CBlob@ item = itemsToShow[i];
			string itemName = item.getName();
			bool passed = false;
			int oreId = -1;
			for (int k = 0; k < teamIngots.length; k++)
			{
				if (teamIngots[k] == itemName)
				{
					oreId = k;
					passed = true;
					break;
				}
			}
			if (!passed)
			{
				continue;
			}
			bool hasOre = false;
			for (int l = 0; l < itemsToShow.length; l++)
			{
				if (teamOres[oreId] == itemsToShow[l].getName())
				{
					j2 = jArray[l];
					hasOre = true;
					break;
				}
			}

			Vec2f itemPos = Vec2f(getScreenWidth() - 54, 54 + j2 * 46) + hudPos;
			GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), itemPos);
			GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, itemPos + Vec2f(8, 8));

			if (!hasOre)
			{
				GUI::DrawIcon("GUI/jslot.png", 2,Vec2f(32, 32), itemPos - Vec2f(48, 0));
				GUI::DrawIcon("GUI/jslot.png", 0,Vec2f(32, 32), itemPos - Vec2f(96, 0));

				if (teamOres[oreId] == "mat_copper") { GUI::DrawIcon("Material_Copper.png", 0, Vec2f(16, 16), itemPos + Vec2f(-88, 8)); }
				else if (teamOres[oreId] == "mat_iron") { GUI::DrawIcon("Material_Iron.png", 0, Vec2f(16, 16), itemPos + Vec2f(-88, 8)); }
				else if (teamOres[oreId] == "mat_gold") { GUI::DrawIcon("Materials.png", 2, Vec2f(16, 16), itemPos + Vec2f(-88, 8)); }

				GUI::SetFont("menu");
				GUI::DrawText("0", itemPos + Vec2f(-66, 26), SColor(255, 255, 0, 0));
			}

			int quantity = itemAmounts[i];
			f32 ratio = float(quantity) / float(item.maxQuantity);
			SColor col = (ratio > 0.4f ? SColor(255, 255, 255, 255) :
			             (ratio > 0.2f ? SColor(255, 255, 255, 128) :
			             (ratio > 0.1f ? SColor(255, 255, 128, 0)   : SColor(255, 255, 0, 0))));
			int l = int(("" + quantity).get_length());
			if (quantity != 1)
			{
				GUI::SetFont("menu");
				GUI::DrawText("" + quantity / 2, itemPos + Vec2f(38 - (l * 8), 26), col);
			}
			if (j2 >= jMax)
			{
				j++;
			}
		}
		for (int i = 0; i < itemsToShow.length; i++)
		{
			//draw everything but ores & ingots
			CBlob@ item = itemsToShow[i];
			string itemName = item.getName();
			bool passed = false;
			for (int k = 0; k < teamItems.length; k++)
			{
				if (teamItems[k] == itemName)
				{
					passed = true;
					break;
				}
			}
			if (!passed)
			{
				continue;
			}

			Vec2f itemPos = Vec2f(getScreenWidth() - 54, 54 + j * 46) + hudPos;
			GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), itemPos);

			if (itemName == "mat_stone") { GUI::DrawIcon("GUI/jitem.png", 1,Vec2f(16, 16), itemPos + Vec2f(6, 6), 1.0f); }
			else if (itemName == "mat_wood") {GUI::DrawIcon("GUI/jitem.png", 2, Vec2f(16, 16), itemPos + Vec2f(6, 6), 1.0f); }
			else { GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, itemPos + Vec2f(8, 8)); }

			int quantity = itemAmounts[i];
			f32 ratio = float(quantity) / float(item.maxQuantity);
			SColor col = (ratio > 0.4f ? SColor(255, 255, 255, 255) :
			             (ratio > 0.2f ? SColor(255, 255, 255, 128) :
			             (ratio > 0.1f ? SColor(255, 255, 128, 0)   : SColor(255, 255, 0, 0))));
			int l = int(("" + quantity).get_length());
			if (quantity != 1)
			{
				GUI::SetFont("menu");
				GUI::DrawText("" + quantity / 2, itemPos + Vec2f(38 - (l * 8), 26), col);
			}
			j++;
		}

		// Ammo and Bombs
		for (int i = 0; i < itemsToShow.length; i++)
		{
			//draw teamBombs
			CBlob@ bomb = itemsToShow[i];
			string itemName = bomb.getName();
			bool passed = false;
			for (int k = 0; k < teamBombs.length; k++)
			{
				if (teamBombs[k] == itemName)
				{
					passed = true;
					break;
				}
			}
			if (!passed)
			{
				continue;
			}

			Vec2f itemPos = Vec2f(getScreenWidth() / 1.52 - 54 + b * 46, getScreenHeight() - 57) + hudPos2;
			if (itemName == "cruisemissile" || itemName == "guidedrocket" || itemName == "mat_bigbomb" || 
			    itemName == "mat_bombita" || itemName == "fireboom")
			{
				int xPos = (itemName == "fireboom" || itemName == "mat_bombita"  ? -6 : 8);
				GUI::DrawIcon("GUI/jslot.png", 3, Vec2f(24, 42), itemPos + Vec2f(0, -34));
				GUI::DrawIcon(bomb.inventoryIconName, bomb.inventoryIconFrame, bomb.inventoryFrameDimension, itemPos + Vec2f(xPos, -22), 1.0f, this.getTeamNum());
			}
			else
			{
				GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), itemPos);
				GUI::DrawIcon(bomb.inventoryIconName, bomb.inventoryIconFrame, bomb.inventoryFrameDimension, itemPos + Vec2f(8, 8), 1.0f, this.getTeamNum());
			}

			int quantity = itemAmounts[i];
			f32 ratio = float(quantity) / float(bomb.maxQuantity);
			SColor col = SColor(255, 255, 255, 255);
			int l = int(("" + quantity).get_length());
			if (quantity != 1)
			{
				GUI::SetFont("menu");
				GUI::DrawText("" + quantity / 2, itemPos + Vec2f(38 - (l * 8), 26), col);
			}
			b--;
		}
		for (int i = 0; i < itemsToShow.length; i++)
		{
			//draw teamAmmo
			CBlob@ ammo = itemsToShow[i];
			string itemName = ammo.getName();
			bool passed = false;
			for (int k = 0; k < teamAmmo.length; k++)
			{
				if (teamAmmo[k] == itemName)
				{
					passed = true;
					break;
				}
			}
			if (!passed)
			{
				continue;
			}

			Vec2f itemPos = Vec2f(getScreenWidth() / 1.52 - 94 + b * 46, getScreenHeight() - 57) + hudPos2;
			GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), itemPos);

			GUI::DrawIcon(ammo.inventoryIconName, ammo.inventoryIconFrame, ammo.inventoryFrameDimension, itemPos + Vec2f(8, 8));

			int quantity = itemAmounts[i];
			f32 ratio = float(quantity) / float(ammo.maxQuantity);
			SColor col = SColor(255, 255, 255, 255);
			int l = int(("" + quantity).get_length());
			if (quantity != 1)
			{
				GUI::SetFont("menu");
				GUI::DrawText("" + quantity / 2, itemPos + Vec2f(38 - (l * 8), 26), col);
			}
			b--;
		}
	}
}
