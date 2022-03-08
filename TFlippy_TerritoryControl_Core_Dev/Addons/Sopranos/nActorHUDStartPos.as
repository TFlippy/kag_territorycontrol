//for use with DefaultActorHUD.as based HUDs

#include "GunCommon.as";

Vec2f getActorHUDStartPosition(CBlob@ blob, const u8 bar_width_in_slots)
{
	f32 width = bar_width_in_slots * 32.0f;
	return Vec2f(getScreenWidth() / 2.0f + 160 - width, getScreenHeight() - 40);
}

void DrawInventoryOnHUD(CBlob@ this, Vec2f tl, Vec2f hudPos = Vec2f(0, 0))
{
	SColor col;
	CInventory@ inv = this.getInventory();
	if (inv is null) return;

	CBlob@[] itemsToShow;
	int[] itemAmounts;

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
	}
	
	int CurrentY = 0;

	for (int i = 0; i < itemsToShow.length; i++)
	{
		CBlob@ item = itemsToShow[i];
		string itemname = item.getInventoryName();
		string jitem = "GUI/jitem.png";
		string jslot = "GUI/jslot.png";
		int frame = 0;
		Vec2f jdim = Vec2f(32, 32);
		Vec2f adjust = Vec2f(0, 2);
		int quantity = itemAmounts[i];
		int max = item.maxQuantity;

		if(item.hasTag("ribbon_icon"))jslot = "ammo_slot.png";

		//Change jslot frame if it matches as ammunition for a held gun
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point !is null)
		{
			CBlob@ gun = point.getOccupied();
			if (gun !is null)
			{
				GunSettings@ settings;
				gun.get("gun_settings", @settings);

				if (settings !is null && settings.AMMO_BLOB == item.getName() || gun.get_string("ammoBlob") == item.getName())
				{
					if(!item.hasTag("ribbon_icon"))jslot = "ammo_item_slot.png";
					frame = 0;
					if(item.getName() == "ammo_bandit")frame = 1;
					else if(item.getName() == "ammo_lowcal")frame = 2;
					else if(item.getName() == "ammo_highcal")frame = 3;
					else if(item.getName() == "ammo_shotgun")frame = 4;
					else if(item.getName() == "ammo_gatling")frame = 5;
					else if(item.getName() == "mat_smallrocket")frame = 4;
					else if(item.getName() == "mat_mininuke")frame = 5;
					
					if(item.getName() == "mat_lancerod" || item.getName() == "mat_steelingot" || item.hasTag("forcefeedable") || item.getName() == "mat_grenade")frame = 1;
					if(item.getName() == "mat_mithril" || item.getName() == "mat_acid")frame = 2;
					if(item.getName() == "mat_smallrocket" || item.getName() == "mat_sawrocket")frame = 3;
					if(item.getName() == "mat_fuel")frame = 4;
					if(item.getName() == "mat_oil")frame = 5;
					if(item.getName() == "mat_mininuke")frame = 6;
					if(item.getName() == "mat_antimatter")frame = 7;
					if(item.getName() == "mat_meat")frame = 8;
					if(item.getName() == "mat_battery")frame = 9;
				}
			}
		}

		if(item.hasTag("weapon")){ ///Weapons let's goooooooooo
			GunSettings@ settings;
			if(item.get("gun_settings", @settings)){
				quantity = item.get_u8("clip");
				max = settings.TOTAL;
			}
			
			jslot = "weapon_slot.png";
			Vec2f itempos = Vec2f(8, 48 + CurrentY) + hudPos;
			Vec2f quantpos = Vec2f(14, 59 + CurrentY) + hudPos;
			
			if(item.inventoryFrameDimension.x > 24){
				frame = 1;
				jdim = Vec2f(64,32);
				quantpos.x += 50;
			}

			GUI::DrawIcon(jslot, frame, jdim, Vec2f(2, 46 + CurrentY) + hudPos);

			int teamnum = this.getTeamNum();
			if (teamnum > 6) teamnum = 7;
			GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, itempos, 1.0f, teamnum); 

			col = SColor(255, 255, 255, 255);
			if (quantity >= max/2.0f) col = SColor(255, 255, 255, 255);
			else if (quantity > max/3.0f) col = SColor(255, 255, 255, 128);
			else if (quantity > max/4.0f) col = SColor(255, 255, 128, 0);
			else col = SColor(255, 255, 0, 0);

			float xOffset;
			if (quantity < 10) xOffset = 22;
			else if (quantity < 100) xOffset = 14;
			else if (quantity < 1000) xOffset = 6;
			else xOffset = -2;

			GUI::SetFont("menu");
			GUI::DrawText(""+quantity, quantpos +Vec2f(xOffset, 18), col);
		
			CurrentY += 50;
		} else
		if(jslot == "ammo_slot.png"){
			Vec2f itempos = Vec2f(8, 48 + CurrentY) + hudPos;
			Vec2f quantpos = Vec2f(18, 59 + CurrentY) + hudPos;
			GUI::DrawIcon(jslot, frame, jdim, Vec2f(2, 46 + CurrentY) + hudPos);

			int teamnum = this.getTeamNum();
			if (teamnum > 6) teamnum = 7;
			GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, itempos, 1.0f, teamnum); 

			col = SColor(255, 255, 255, 255);
			if (quantity >= max*0.75f) col = SColor(255, 128, 255, 128);
			else if (quantity >= max/2.0f) col = SColor(255, 255, 255, 255);
			else if (quantity > max/3.0f) col = SColor(255, 255, 255, 128);
			else if (quantity > max/4.0f) col = SColor(255, 255, 128, 0);
			else col = SColor(255, 255, 0, 0);

			if (quantity != 1)
			{
				float xOffset;
				if (quantity < 10) xOffset = 22;
				else if (quantity < 100) xOffset = 14;
				else if (quantity < 1000) xOffset = 9;
				else xOffset = -2;

				GUI::SetFont("menu");
				GUI::DrawText(""+quantity, quantpos +Vec2f(xOffset, 18), col);
			}
			
			CurrentY += 54;
		} else {
			//vertical belt
			Vec2f itempos = Vec2f(10, 42 + CurrentY) + hudPos;
			Vec2f quantpos = Vec2f(10, 56 + CurrentY) + hudPos;
			GUI::DrawIcon(jslot, frame, jdim, Vec2f(2, 46 + CurrentY) + hudPos);

			int teamnum = this.getTeamNum();
			if (teamnum > 6) teamnum = 7;
			GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, itempos, 1.0f, teamnum); 

			col = SColor(255, 255, 255, 255);
			if (quantity > max * 3) col = SColor(255, 255, 255, 255);
			else if (quantity > max * 2) col = SColor(255, 255, 255, 128);
			else if (quantity > max * 1) col = SColor(255, 255, 128, 0);
			else col = SColor(255, 255, 0, 0);

			if (quantity != 1)
			{
				float xOffset;
				if (quantity < 10) xOffset = 22;
				else if (quantity < 100) xOffset = 14;
				else if (quantity < 1000) xOffset = 6;
				else xOffset = -2;

				GUI::SetFont("menu");
				GUI::DrawText(""+quantity, quantpos +Vec2f(xOffset, 18), col);
			}
			
			CurrentY += 42;
		}
	}
}

void DrawCoinsOnHUD(CBlob@ this, const int coins, Vec2f tl, const int slot)
{
	if (coins > 0)
	{
		GUI::DrawIcon("GUI/jitem.png", 14, Vec2f(16, 16), Vec2f(42, 38));
		GUI::SetFont("menu");
		GUI::DrawText("" + coins, Vec2f(72, 44), color_white);
	}
}
