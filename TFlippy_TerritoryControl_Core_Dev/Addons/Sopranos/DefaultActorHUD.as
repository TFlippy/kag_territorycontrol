//default actor hud
// a bar with hearts in the bottom left, bottom right free for actor specific stuff

#include "Survival_Structs.as";
#include "SmartStorageHelpers.as";

void renderBackBar( Vec2f origin, f32 width, f32 scale)
{
    for (f32 step = 0.0f; step < width/scale - 64; step += 64.0f * scale)
    {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64,32), origin+Vec2f(step*scale,0), scale);
    }

    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64,32), origin+Vec2f(width - 128*scale,0), scale);
}

void renderFrontStone( Vec2f farside, f32 width, f32 scale)
{
    for (f32 step = 0.0f; step < width/scale - 16.0f*scale*2; step += 16.0f*scale*2)
    {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16,32), farside+Vec2f(-step*scale - 32*scale,0), scale);
    }

    if (width > 16) {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16,32), farside+Vec2f(-width, 0), scale);
    }

    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16,32), farside+Vec2f(-width - 32*scale, 0), scale);
    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16,32), farside, scale);
}

void renderHPBar( CBlob@ blob, Vec2f origin)
{
    int segmentWidth = 24; // 32
    GUI::DrawIcon("GUI/jends2.png", 0, Vec2f(8,16), origin+Vec2f(-8,0)); // ("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16,32), origin+Vec2f(-segmentWidth,0));
    int HPs = 0;
    for (f32 step = 0.0f; step < Maths::Max(blob.getHealth(), blob.getInitialHealth()); step += 0.5f)
    {
        GUI::DrawIcon("GUI/HPback.png", 0, Vec2f(12,16), origin+Vec2f(segmentWidth*HPs,0)); // ("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(16,32), origin+Vec2f(segmentWidth*HPs,0));
        f32 thisHP = blob.getHealth() - step;
        if (thisHP > 0)
        {
			string heartFile = step >= blob.getInitialHealth() ? "GUI/HPbar_Bonus.png" : "GUI/HPbar.png";
		
            // Vec2f heartoffset = (Vec2f(2,10) * 2);
            Vec2f heartpos = origin+Vec2f(segmentWidth*HPs-1,0); // origin+Vec2f(segmentWidth*HPs,0)+heartoffset;
			if (thisHP <= 0.125f) { GUI::DrawIcon(heartFile, 4, Vec2f(16,16), heartpos); } // Vec2f(12,12)
            else if (thisHP <= 0.25f) { GUI::DrawIcon(heartFile, 3, Vec2f(16,16), heartpos); } // Vec2f(12,12)
            else if (thisHP <= 0.375f) { GUI::DrawIcon(heartFile, 2, Vec2f(16,16), heartpos); } // Vec2f(12,12)
			else if (thisHP > 0.375f) { GUI::DrawIcon(heartFile, 1, Vec2f(16,16), heartpos); } // else { GUI::DrawIcon(heartFile, 1, Vec2f(12,12), heartpos); }
            else { GUI::DrawIcon(heartFile, 0, Vec2f(16,16), heartpos); }
        }
        HPs++;
    }
    GUI::DrawIcon("GUI/jends2.png", 1, Vec2f(8,16), origin+Vec2f(segmentWidth*HPs,0)); // ("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16,32), origin+Vec2f(32*HPs,0));
}

void onInit( CSprite@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender( CSprite@ this )
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
	Vec2f topleft(52,10);
    renderHPBar( blob, topleft); // ( blob, ul);
	
	RenderUpkeepHUD(blob);
	RenderTeamInventoryHUD(blob);
	GUI::DrawIcon("GUI/jslot.png", 1, Vec2f(32,32), Vec2f(2,2));
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
		
	if (upkeep_ratio >= 0.75f) msg += "Your upkeep is too high, build\nmore Quarters, Camps or Fortresses!\n";
	else msg += "Your upkeep is balanced, therefore\nyour team will receive extra bonuses.";
	
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

const string[] teamItems =
{
	"mat_wood",
	"mat_oil",
	"mat_coal",
	"mat_steelingot",
	"mat_copperwire",
	"mat_plasteel",
	"mat_sulphur",
	"mat_meat",
	"mat_fuel",
	"mat_methane",
	"mat_acid",
	"mat_antimatter",
	"mat_mithrilenriched"
};

const string[] teamItemsIN =
{
	"Materials.png",
	"Material_Oil.png",
	"Material_Coal.png",
	"Material_SteelIngot.png",
	"Material_CopperWire.png",
	"Material_Plasteel.png",
	"Material_Sulfur.png",
	"Material_Meat.png",
	"Material_Fuel.png",
	"Material_Methane.png",
	"Material_Acid.png",
	"Material_Antimatter.png",
	"Material_MithrilEnriched.png"
};

const int[] teamItemsIF =
{
	25,
	0,
	3,
	3,
	0,
	0,
	3,
	3,
	0,
	0,
	0,
	0,
	3,
};
//teamOres.length === teamIngots.length
//teamOres[i] -> teamIngots[i]
const string[] teamOres =
{
	"mat_stone",
	"mat_copper",
	"mat_iron",
	"mat_gold",
	"mat_mithril"
};

const string[] teamOresIN =
{
	"Materials.png",
	"Material_Copper.png",
	"Material_Iron.png",
	"Materials.png",
	"Material_Mithril.png"
};

const int[] teamOresIF =
{
	24,
	3,
	3,
	26,
	3
};

const string[] teamIngots =
{
	"mat_concrete",
	"mat_copperingot",
	"mat_ironingot",
	"mat_goldingot",
	"mat_mithrilingot"
};

const string[] teamIngotsIN =
{
	"Material_Concrete.png",
	"Material_CopperIngot.png",
	"Material_IronIngot.png",
	"Material_GoldIngot.png",
	"Material_MithrilIngot.png"
};

const int[] teamIngotsIF =
{
	3,
	3,
	3,
	3,
	3
};

// Merser pls, fix your code formatting, it's unreadable and gives me conniptions
void RenderTeamInventoryHUD(CBlob@ this)
{
	Vec2f hudPos = Vec2f(0, 0);

	int playerTeam = this.getTeamNum();
	if (playerTeam > 6)
	{
		return;
	}


	//compute storageEnabled
	bool storageEnabled = false;
	TeamData@ team_data;
	GetTeamData(playerTeam, @team_data);
	if (team_data != null)
	{
		u16 upkeep = team_data.upkeep;
		u16 upkeep_cap = team_data.upkeep_cap;
		f32 upkeep_ratio = f32(upkeep) / f32(upkeep_cap);
		const bool faction_storage_enabled = team_data.storage_enabled;
		
		storageEnabled = upkeep_ratio < UPKEEP_RATIO_PENALTY_STORAGE && faction_storage_enabled;
	}


	int64 buf = 0; //for dict
	dictionary itemsToShow; // item -> amount
	//init for more effective storage and checks
	for(uint8 i=0;i<teamItems.length;i++) itemsToShow.set(teamItems[i],buf);
	for(uint8 i=0;i<teamOres.length;i++) itemsToShow.set(teamOres[i],buf);
	for(uint8 i=0;i<teamIngots.length;i++) itemsToShow.set(teamIngots[i],buf);
	array<string>@ dkeys = itemsToShow.getKeys(); // to iterate over them later

	CBlob@[] baseBlobs;
	getBlobsByTag("remote_storage", @baseBlobs);

	CBlob@[] smartStorageBlobs;
	getBlobsByTag("smart_storage", @smartStorageBlobs);


	//populate itemsToShow and also set closeEnough
	bool closeEnough = false;
	for (int i = 0; i < baseBlobs.length; i++) 
	{
		CBlob@ baseBlob=baseBlobs[i];
		if (baseBlob.getTeamNum() != playerTeam)
		{
			continue;
		}
		
		if ((baseBlob.getPosition() - this.getPosition()).Length() < 250.0f)
		{
			closeEnough = true;
		}
		
		CInventory@ inv=baseBlob.getInventory();
		if (inv is null) continue;
		
		for(int j=0;j<inv.getItemsCount();j++)
		{
			CBlob@ item=inv.getItem(j);
			string iname=item.getConfig();
			if(itemsToShow.get(iname, buf))
				itemsToShow.set(iname, buf+item.getQuantity());
		}
	}
	for (int i = 0; i < smartStorageBlobs.length; i++)
		for(int k = 0; k < dkeys.length; k++)
			if(itemsToShow.get(dkeys[k], buf))
				itemsToShow.set(dkeys[k], buf+smartStorageCheck(smartStorageBlobs[i],dkeys[k]));


	bool storageAccessible = closeEnough && storageEnabled;
	
	GUI::DrawIcon("GUI/jslot.png",0,					Vec2f(32,32),Vec2f((getScreenWidth()-54),8)+hudPos);
	GUI::DrawIcon("Emblems.png",playerTeam,				Vec2f(32,32),Vec2f((getScreenWidth()-62),0)+hudPos);
	GUI::DrawIcon("GUI/jslot.png",0,					Vec2f(32,32),Vec2f((getScreenWidth()-102),8)+hudPos);
	GUI::DrawIcon("MenuItems.png",storageAccessible ? 28 : 29,Vec2f(32,32),Vec2f((getScreenWidth()-110),0)+hudPos);
	GUI::SetFont("menu");
	GUI::DrawText("Remote access to team storages - ",Vec2f((getScreenWidth()-352),22)+hudPos,storageAccessible ? SColor(255,0,255,0) : SColor(255,255,0,0));
	int drawn=0;	
	for(int i=0;i<teamIngots.length;i++)
	{
		string oname = teamOres[i];
		string iname = teamIngots[i];
		int64 omount;
		int64 imount;
		itemsToShow.get(oname,omount);
		itemsToShow.get(iname,imount);
		if(omount==0&&imount==0) continue;
		Vec2f itemPos=	Vec2f(getScreenWidth()-150,54+drawn*46)+hudPos;
		GUI::DrawIcon("GUI/jslot.png",0,Vec2f(32,32),itemPos);
		GUI::DrawIcon("GUI/jslot.png",2,Vec2f(32,32),itemPos+Vec2f(48,0));
		GUI::DrawIcon("GUI/jslot.png",0,Vec2f(32,32),itemPos+Vec2f(96,0));
		GUI::SetFont("menu");
		GUI::DrawIcon(teamIngotsIN[i],teamIngotsIF[i],Vec2f(16,16),itemPos+Vec2f(96,0)+Vec2f(8,8));
		GUI::DrawText(""+imount,itemPos+Vec2f(38+96-(int((""+imount).get_length())*8),26),SColor(255,255,255,255));
		GUI::DrawIcon(teamOresIN[i],teamOresIF[i],Vec2f(16,16),itemPos+Vec2f(8,8));
		GUI::DrawText(""+omount,itemPos+Vec2f(38-(int((""+omount).get_length())*8),26),SColor(255,255,255,255));
		drawn++;
	}
	for(int i=0;i<teamItems.length;i++)
	{
		string iname = teamItems[i];
		itemsToShow.get(iname,buf);
		if(buf==0) continue;
		Vec2f itemPos=	Vec2f(getScreenWidth()-54,54+drawn*46)+hudPos;
		GUI::DrawIcon("GUI/jslot.png",0,Vec2f(32,32),itemPos);
		GUI::DrawIcon(teamItemsIN[i],teamItemsIF[i],Vec2f(16,16),itemPos+Vec2f(8,8));
		GUI::SetFont("menu");
		GUI::DrawText(""+buf,itemPos+Vec2f(38-(int((""+buf).get_length())*8),26),SColor(255,255,255,255));
		drawn++;
	}
}



