
//This add all the shop icons for each modifier which is possible given the specific target

#include "ShopCommon.as";
#include "Hitters.as";
#include "CustomBlocks.as";

void AllPossibleModifiers(CBlob@ this, CBlob @caller, CBlob@ target)
{

	ShopItem[] items;
	this.set(SHOP_ARRAY, items); //reset the shop array

	bool Unbound = this.get_bool("Unbound Modifiers");

	if (!Unbound) //Can modifiy equipments when unbound cause why the heck not
	if (target.hasScript("head.as") || target.hasScript("torso.as") || target.hasScript("boots.as"))
	{
		return; //Equipment shouldent have modifiers since people might think it applies while beeing worn which is not how the code works
		//this currently also includes stuff like pumpkins and buckets but oh well
	}

	CShape@ shape = target.getShape();

	f32 priceMod = 1; //A general multiplier on costs

	if (target.hasTag("player")) //Modifying anything with a player should be vastly more expensive (possible even impossible?, for now i left it in cause it is ludacrously expensive and you loose it on death)
	{
		priceMod *= 10;
		if (!Unbound) //Needs to be Unbound to modify players
		{
			return; 
		}
	}
	if (target.hasTag("vehicle")) //Vehicles are more expensive
	{
		priceMod *= 5;
	}

	if (target.maxQuantity <= 1 && !target.hasTag("flesh") && target.getHealth() < target.getInitialHealth()) //obviously cant heal flesh things
	{
		ShopItem@ s = addShopItem(this, "Repair", "$mat_ironingot$", "Repair", "Repair 10% of its health", false);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 1 * priceMod); //price is set at 1 iron ingot regardless of the entity (should be fine though)
		s.spawnNothing = true;
	}
	if (Unbound || (!target.hasTag("flesh"))) //Only reinforce to 1.5x hp at most, can't reinforce flesh unless unbound
	if (target.getHealth() == target.getInitialHealth()) //can't reinforce damaged things or already reinforced things
	{
		ShopItem@ s = addShopItem(this, "Reinforce", "$mat_ironingot$", "Reinforce", "Increase health by 50%", false);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 10 * priceMod);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50 * priceMod);
		s.spawnNothing = true;
	}
	if (Unbound)
	if (!target.hasScript("FloatyMod.as"))
	{
		//this, name, icon_name, blobname, description,
		ShopItem@ s = addShopItem(this, "Floaty", "$mat_methane$", "Script-FloatyMod.as", "Add Methane to make it fall slower", false);
		AddRequirement(s.requirements, "blob", "mat_methane", "Methane", Maths::Clamp(target.getMass(), 20, 200) * priceMod);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30 * priceMod);
		s.spawnNothing = true;
	}
	if (!target.hasScript("TimedDeathMod.as"))
	{
		ShopItem@ s = addShopItem(this, "Timed Death", "$mat_copperwire$", "Script-TimedDeathMod.as", "Dies after exactly 30 seconds", false);
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 1 * priceMod);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 1 * priceMod);
		s.spawnNothing = true;
	}
	if (!target.hasScript("FragileMod.as"))
	{
		AddIconToken("$glass_block$", "World.png", Vec2f(8, 8), CMap::tile_glass);
		ShopItem@ s = addShopItem(this, "Fragile", "$glass_block$", "Script-FragileMod.as", "Dies when colliding at too high speeds", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 30 * priceMod);
		s.spawnNothing = true;
	}
	if (!target.hasTag("AerodynamicMod") && shape.getDrag() > 0)
	{
		ShopItem@ s = addShopItem(this, "Aerodynamic", "$chicken$", "Reduce Drag", "Reduce the air resistance by rounding off unnessecary corners", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100 * priceMod);
		s.spawnNothing = true;
	}
	if (Unbound)
	if (!target.hasTag("BouncyMod") && shape.getElasticity() < 0.8f)
	{
		ShopItem@ s = addShopItem(this, "Bouncy", "$sponge$", "Set Elasiticity", "Bounces when colliding with terrain", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 250 * priceMod);
		s.spawnNothing = true;
	}
	if (Unbound || !target.hasTag("explosive"))
	if (!target.hasScript("DynamiteExplosionMode") && target.maxQuantity <= 1 && !target.hasTag("flesh") && target.maxQuantity <= 1) //cannot make fleshy things exlpodes cause a drug already does that
	{
		ShopItem@ s = addShopItem(this, "Dynamite Explosion", "$dynamite$", "Script-DynamiteExplosionMod.as", "Explodes when destroyed", false);
		AddRequirement(s.requirements, "blob", "mat_dynamite", "Dynamite", 1); //Always uses exactly 1
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 2 * priceMod);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 50 * priceMod);
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
			target.getShape().setDrag(target.getShape().getDrag() * 0.2f); //CURRENTLY DIRECT CHANGES LIKE THIS MAY NOT BE STORED IN SAVE FILES but the tag deffinitly would be
		}
		else if(name == "Set Elasiticity")
		{
			target.Tag("BouncyMod");
			target.getShape().setElasticity(0.8f);
		}
		else if(name == "Repair")
		{
			target.server_Heal(target.getInitialHealth() * 0.1f);
		}
		else if(name == "Reinforce")
		{
			target.server_SetHealth(target.getHealth() + target.getInitialHealth() * 0.5f);
		}
	}	

}