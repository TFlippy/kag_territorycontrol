
//This add all the shop icons for each modifier which is possible given the specific target

#include "ShopCommon.as";

void AllPossibleModifiers(CBlob@ this, CBlob @caller, CBlob@ target)
{

	ShopItem[] items;
	this.set(SHOP_ARRAY, items);

	if (target.hasScript("head.as") || target.hasScript("torso.as") || target.hasScript("boots.as"))
	{
		return; //Equipment shouldent have modifiers since people might think it applies while beeing worn which is not how the code works
	}

	f32 priceMod = 1;

	if (target.hasTag("player")) //Modifying anything with a player should be vastly more expensive (possible even impossible?)
	{
		priceMod *= 10;
	}
	if (target.hasTag("vehicle"))
	{
		priceMod *= 5;
	}

	if (!target.hasScript("FloatyMod.as"))
	{
		//this, name, icon_name, blobname, description,
		ShopItem@ s = addShopItem(this, "Floaty", "$mat_methane$", "Script-FloatyMod.as", "Add Methane to make it fall slower", false);
		AddRequirement(s.requirements, "blob", "mat_methane", "Methane", Maths::Clamp(target.getMass(), 20, 100) * priceMod);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30 * priceMod);

		s.spawnNothing = true;
	}
	if (!target.hasScript("AirodynamicMod.as"))
	{
		ShopItem@ s = addShopItem(this, "Airodynamic", "$mat_wood$", "Script-AirodynamicMod.as", "Chisel away some unnessecary corners to make it move faster", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 300 * priceMod);

		s.spawnNothing = true;
	}
}

void ModifyWith(CBlob@ this, CBlob @caller, CBlob@ target, string name)
{

	string[] spl = name.split("-");

	print("Modified "+target.getInventoryName()+" with "+name);

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