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
	"Ginger_TC_Murderholes_V2",
	"Ginger_TC_Equinox",
	"Goldy_TC_Netherland_v2", //a bit unstable
	"Goldy_TC_Propesko"
};

const string[] MemeMaps = {
	"TFlippy_TC_Spilands",
	"TFlippy_THD_TC_Foghorn",
	"Ginger_TC_Aether",
	"Ginger_TC_Seaside",
	"Goldy_TC_Basement_v2",
	//"Goldy_TC_DoubleVision", //too laggy to use
	"Goldy_TC_Hollows",
	//"Goldy_TC_ThomsMega_Smoll", //E bug
	"Imbalol_TC_City_v1",
	"Imbalol_TC_LongForgotten",
	"Maybe_Cool_Tc_Map",
	"Naime_TC_Land",
	"Vamistorio_TC_IkoPit_v2"
};

const string[] OldMaps = {
	"TFlippy_TC_Mesa",
	"Ginger_TC_Bridge",
	"Ginger_TC_Lagoon",
	"Ginger_TC_Pirates",
	"Goldy_TC_Sewers_v2",
	"Imbalol_TC_ChickenKingdom_v2",
	"Imbalol_TC_OilRig",
	"Imbalol_TC_UPFCargo",
	"Sylw_LawrenceSlum",
	"Tenshi_TC_DeadEchoSeven_v1",
	"Tenshi_TC_WellOiledMachine_v2"
};

void onInit(CRules@ this)
{
	Reset(this, getMap());

	this.set("maptypes-offi", OffiMaps);
	this.set("maptypes-meme", MemeMaps);
	this.set("maptypes-old", OldMaps);

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
		if (!this.exists("map_type")) this.set_u8("map_type", MapType::normal);
	}
}
