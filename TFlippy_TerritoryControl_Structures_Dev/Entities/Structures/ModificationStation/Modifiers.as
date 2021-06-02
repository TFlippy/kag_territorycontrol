
//This add all the shop icons for each modifier which is possible given the specific target

#include "ShopCommon.as";

void AllPossibleModifiers(CBlob@ this, CBlob @caller, CBlob@ target)
{

	ShopItem[] items;
	this.set(SHOP_ARRAY, items);

	if (!target.hasScript("FloatyMod.as"))
	{
		//this, name, icon_name, blobname, description,
		ShopItem@ s = addShopItem(this, "Floaty", "$mat_methane$", "Script-FloatyMod.as", "Add Methane to make it fall slower", false);
		AddRequirement(s.requirements, "blob", "mat_methane", "Methane", 30);

		s.spawnNothing = true;
	}
}

void ModifyWith(CBlob@ this, CBlob @caller, CBlob@ target, string name)
{

	string[] spl = name.split("-");

	if (spl[0] == "Tag")
	{
		target.Tag(spl[1]);
	}
	else if(spl[0] == "Script")
	{
		target.AddScript(spl[1]);
	}
	else
	{
		//Add more bizaar stuff here
	}	

}