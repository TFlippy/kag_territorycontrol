#include "CustomBlocks.as";
#include "MapType.as";

const string[] OffiMaps = {
	"TFlippy_TC_Reign",
	"TFlippy_TC_Bobox",
	"TFlippy_TC_Thomas",
	"TFlippy_TC_Derpo",
	"TFlippy_THD_TC_Kagtorio",
	"TFlippy_TC_Nostalgia",
	"TFlippy_Rob_TC_Socks",
	"TFlippy_TC_Fug",
	"Sylw_LawrenceSlum",
	"TFlippy_TC_Skynet",
	"TFlippy_TC_Tenshi_Lakes",
	"TFlippy_TC_Valley",
	"JmD_TC_Poultry_v6",
	"Ginger_TC_Ridgelands_V2",
	"Ginger_TC_Royale_V3",
	"Ginger_Tenshi_TC_Generations_V1",
	"Ginger_TC_Drudgen",
	"Ginger_TC_Bombardment_V2",
	"Ginger_TC_Dehydration",
	"Imbalol_TC_OilRig",
	"Imbalol_TC_UPFCargo",
	"Ginger_TC_Murderholes_V2",
	"Ginger_TC_Lagoon",
	"Vamistorio_TC_IkoPit_v2",
	"Goldy_TC_Sewers_v2"
};



void onInit(CRules@ this)
{
	Reset(this, getMap());

	this.set("maptypes-offi", OffiMaps);

}

void onRestart(CRules@ this)
{
	Reset(this, getMap());
}

void onRulesRestart(CMap@ this, CRules@ rules)
{
	Reset(rules, this);
}

void Reset(CRules@ this, CMap@ map)
{
	if (map !is null)
	{
		map.SetBorderFadeWidth(16);	
		
		map.SetBorderColourTop(SColor(255, 0, 0, 0));
		map.SetBorderColourLeft(SColor(255, 0, 0, 0));
		map.SetBorderColourRight(SColor(255, 0, 0, 0));
		map.SetBorderColourBottom(SColor(255, 0, 0, 0));
		
		if (!this.exists("map_type")) this.set_u8("map_type", MapType::normal);
	}
}
