#include "CustomBlocks.as";
#include "MapType.as";

void onInit(CRules@ this)
{
	Reset(this, getMap());
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