
//This add all the shop icons for each modifier which is possible given the specific target

#include "ShopCommon.as";

void AllPossibleModifiers(CBlob@ this, CBlob @caller, CBlob@ target)
{

	ShopItem[] items;
	this.set(SHOP_ARRAY, items);

	if(target.getName() == "lantern" && !target.hasTag("Sulphur"))
	{
		//this, name, icon_name, blobname, description,
		ShopItem@ s = addShopItem(this, "Sulphur Light", "$mat_sulphur$", "Tag-Sulphur", "Add sulphur to make it glow with brighter white light", false);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 20);

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
	else
	{
		
	}	

}