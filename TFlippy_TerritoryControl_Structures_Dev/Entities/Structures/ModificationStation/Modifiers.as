
//This add all the shop icons for each modifier which is possible given the specific target

#include "ShopCommon.as";
#include "Hitters.as";

void AllPossibleModifiers(CBlob@ this, CBlob @caller, CBlob@ target)
{

	ShopItem[] items;
	this.set(SHOP_ARRAY, items);

	if (target.hasScript("head.as") || target.hasScript("torso.as") || target.hasScript("boots.as"))
	{
		return; //Equipment shouldent have modifiers since people might think it applies while beeing worn which is not how the code works
		//this currently also includes stuff like pumpkins and buckets but oh well
	}

	

	f32 priceMod = 1; //A general multiplier on costs

	if (target.hasTag("player")) //Modifying anything with a player should be vastly more expensive (possible even impossible?, for now i left it in cause it is ludacrously expensive and you loose it on death)
	{
		priceMod *= 10;
	}
	if (target.hasTag("vehicle")) //Vehicles are more expensive since they are larger and generally more powerfull
	{
		priceMod *= 5;
	}

	if (!target.hasScript("FloatyMod.as"))
	{
		//this, name, icon_name, blobname, description,
		ShopItem@ s = addShopItem(this, "Floaty", "$mat_methane$", "Script-FloatyMod.as", "Add Methane to make it fall slower", false);
		AddRequirement(s.requirements, "blob", "mat_methane", "Methane", Maths::Clamp(target.getMass(), 20, 200) * priceMod);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30 * priceMod);

		s.spawnNothing = true;
	}
	if (!target.hasTag("AerodynamicMod"))
	{
		ShopItem@ s = addShopItem(this, "Aerodynamic", "$mat_wood$", "Reduce Drag", "Reduce the air resistance by rounding off unnessecary corners", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100 * priceMod);

		s.spawnNothing = true;
	}
}

void ModifyWith(CBlob@ this, CBlob @caller, CBlob@ target, string name)
{

	string[] spl = name.split("-");

	print("Modified "+target.getInventoryName()+" with "+name); //Temporary helper print

	if (target.hasTag("flesh")) //flesh objects take a bit of damage when modified (this adds a bit of flavour)
	{
		this.server_Hit(target, target.getPosition(), Vec2f_zero, 0.5f, Hitters::saw);
	}

	if (spl[0] == "Tag") //Easier add tag recepies
	{
		target.Tag(spl[1]);
	}
	else if(spl[0] == "Script") //Easier add script recepies
	{
		target.AddScript(spl[1]);
	}
	else
	{
		if(name == "Reduce Drag")
		{
			target.Tag("AerodynamicMod");
			target.getShape().setDrag(target.getShape().getDrag() * 0.3f); //CURRENTLY DIRECT CHANGES LIKE THIS MAY NOT BE STORED IN SAVE FILES but the tag deffinitly would be
		}
	}	

}