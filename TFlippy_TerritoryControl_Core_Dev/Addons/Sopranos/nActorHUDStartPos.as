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

	for (int i = 0; i < itemsToShow.length; i++)
	{
		CBlob@ item = itemsToShow[i];
		string itemname = item.getInventoryName();
		string jitem = "GUI/jitem.png";
		int frame = 0;
		Vec2f jdim = Vec2f(16, 16);
		Vec2f adjust = Vec2f(0, 2);
		const int quantity = itemAmounts[i];

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
					frame = 1;
				}
			}
		}

		//vertical belt
		Vec2f itempos = Vec2f(10, 54 + i * 46) + hudPos;
		GUI::DrawIcon("GUI/jslot.png", frame, Vec2f(32, 32), Vec2f(2, 46 + i * 46) + hudPos);

		int teamnum = this.getTeamNum();
		if (teamnum > 6) teamnum = 7;
		GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, itempos, 1.0f, teamnum); 

		col = SColor(255, 255, 255, 255);
		if (quantity > item.maxQuantity * 3) col = SColor(255, 255, 255, 255);
		else if (quantity > item.maxQuantity * 2) col = SColor(255, 255, 255, 128);
		else if (quantity > item.maxQuantity * 1) col = SColor(255, 255, 128, 0);
		else col = SColor(255, 255, 0, 0);

		if (quantity != 1)
		{
			float xOffset;
			if (quantity < 10) xOffset = 22;
			else if (quantity < 100) xOffset = 14;
			else if (quantity < 1000) xOffset = 6;
			else xOffset = -2;

			GUI::SetFont("menu");
			GUI::DrawText(""+quantity, itempos +Vec2f(xOffset, 18), col);
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
