
//This add all the shop icons for each modifier which is possible given the specific target

#include "ShopCommon.as";
#include "Hitters.as";
#include "CustomBlocks.as";
#include "GunCommon.as";

void AllPossibleModifiers(CBlob@ this, CBlob @caller, CBlob@ target)
{

	ShopItem[] items;
	this.set(SHOP_ARRAY, items); //reset the shop array

	bool Unbound = this.get_bool("Unbound Modifiers");

	if (!Unbound) //Can modifiy equipments when unbound cause why the heck not
	if (target.hasScript("head.as") || target.hasScript("torso.as") || target.hasScript("boots.as"))
	{
		return; //Equipment shouldent normally have modifiers since people might think it applies while beeing worn which is not how the code works
	}

	CShape@ shape = target.getShape();

	f32 priceMod = 1; //A general multiplier on costs

	if (target.hasTag("player")) //Modifying anything with a player should be vastly more expensive
	{
		if (!Unbound) //Needs to be Unbound to modify players
		{
			return; 
		}
		priceMod *= 10;
	}
	if (target.hasTag("vehicle")) //Vehicles are more expensive
	{
		priceMod *= 5;
	}

	//GUN MODIFIERS
	GunSettings@ settings;
	if(target.get("gun_settings", @settings)) //Is a gun
	{
		if (!target.hasTag("MaximumdakkaMod") && settings.FIRE_INTERVAL < 10 && settings.TOTAL > 20) //only works on guns which can already fire quite fast
		{
			ShopItem@ s = addShopItem(this, "Maximum dakka", "$smg$", "Gun-Maximumdakka", "Fires way way faster at the cost of accuracy", false);
			AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 2 * priceMod);
			AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 5 * priceMod);
			s.spawnNothing = true;
		}
		if (settings.FIRE_SOUND != "") //only silence guns which still have a sound effect
		{
			ShopItem@ s = addShopItem(this, "Silencer", "$mat_ironingot$", "Gun-Silencer", "Removes any sound due to firing the gun", false);
			AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 20 * priceMod);
			s.spawnNothing = true;
		}
		if (settings.B_DAMAGE > 0.0f)
		{
			ShopItem@ s = addShopItem(this, "Harmless Bullets", "$steak$", "Gun-HarmlessBullets", "Gun Bullets no longer deal any damage", false);
			AddRequirement(s.requirements, "coin", "", "Coins", 50 * priceMod);
			s.spawnNothing = true;
		}

		//MORE BIZZAR GUN EFFECTS
		if (settings.B_SPEED > 10) //only slow guns which need to be slowed
		{
			ShopItem@ s = addShopItem(this, "Heavy Bullets", "$mat_mithrilingot$", "Gun-SlowBullets", "Bullets are extremely slow", false);
			AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 10 * priceMod);
			AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 5 * priceMod);
			s.spawnNothing = true;
		}

	}

	//REPAIR AND REINFORCE
	if (target.maxQuantity <= 1 && !target.hasTag("flesh") && target.getHealth() < target.getInitialHealth()) //obviously cant heal flesh things
	{
		AddIconToken("$repair$", "ModificationIcons.png", Vec2f(16, 16), 0);
		ShopItem@ s = addShopItem(this, "Repair", "$repair$", "Repair", "Repair 10% of health", false);
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

	//GENERAL MODFIERS
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
		AddIconToken("$stone_triangle$", "StoneTriangle.png", Vec2f(8, 8), 0);
		ShopItem@ s = addShopItem(this, "Aerodynamic", "$stone_triangle$", "Reduce Drag", "Reduce the air resistance by rounding off unnessecary corners", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100 * priceMod);
		s.spawnNothing = true;
	}
	if (!target.hasTag("BuoyancyMod") && shape.getConsts().buoyancy < 1)
	{
		ShopItem@ s = addShopItem(this, "Floaties", "$sponge$", "Set Buoyancy", "Add little floaties to allow it to float in water", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100 * priceMod);
		AddRequirement(s.requirements, "blob", "sponge", "Sponge", 3);
		s.spawnNothing = true;
	}
	if (target.hasScript("DecayInWater"))
	{
		ShopItem@ s = addShopItem(this, "Waterproofing", "$mat_oil$", "RScript-DecayInWater.as", "Waterproof the object stopping it from decaying in water", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100 * priceMod);
		AddRequirement(s.requirements, "blob", "sponge", "Sponge", 1);
		AddRequirement(s.requirements, "blob", "mat_oil", "Oil", 20 * priceMod);
		s.spawnNothing = true;
	}
	if (Unbound || !target.hasTag("explosive")) //can only make explosives explode more if its unbound
	if (!target.hasScript("DynamiteExplosionMode") && target.maxQuantity <= 1 && !target.hasTag("flesh") && target.maxQuantity <= 1) //cannot make fleshy things exlpodes cause a drug already does that
	{
		ShopItem@ s = addShopItem(this, "Dynamite Explosion", "$dynamite$", "Script-DynamiteExplosionMod.as", "Explodes when destroyed", false);
		AddRequirement(s.requirements, "blob", "mat_dynamite", "Dynamite", 1); //Always uses exactly 1
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 2 * priceMod);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 50 * priceMod);
		s.spawnNothing = true;
	}

	//UNBOUND ONLY Modifiers
	if (Unbound)
	{
		if (shape.getElasticity() < 0.8f)
		{
			ShopItem@ s = addShopItem(this, "Bouncy", "$sponge$", "Set Elasiticity", "Bounces when colliding with terrain", false);
			AddRequirement(s.requirements, "coin", "", "Coins", 250 * priceMod);
			s.spawnNothing = true;
		}
		if (shape.getFriction() > 0.01f)
		{
			ShopItem@ s = addShopItem(this, "Frictionless", "$sponge$", "Reduce Friction", "Add tiny wheels to reduce friction with the ground", false);
			AddRequirement(s.requirements, "coin", "", "Coins", 250 * priceMod);
			s.spawnNothing = true;
		}
		if (!target.hasScript("FloatyMod.as"))
		{
			ShopItem@ s = addShopItem(this, "Floaty", "$chicken$", "Script-FloatyMod.as", "Add Methane to make it fall slower", false);
			AddRequirement(s.requirements, "blob", "mat_methane", "Methane", Maths::Clamp(target.getMass(), 20, 200) * priceMod);
			AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30 * priceMod);
			s.spawnNothing = true;
		}
		if (!target.hasScript("RegenerationMod.as"))
		{
			ShopItem@ s = addShopItem(this, "Regeneration", "$mat_meat$", "Script-RegenerationMod.as", "Do unspeakable things to make it heal hp very very slowly", false);
			AddRequirement(s.requirements, "coin", "", "Coins", 250 * priceMod);
			AddRequirement(s.requirements, "blob", "mat_meat", "Meat", Maths::Clamp(target.getInitialHealth()*30, 20, 300) * priceMod);
			AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 60 * priceMod);
			s.spawnNothing = true;
		}
		if (!target.hasScript("ReturningMod.as") && !target.hasTag("player") && !target.hasTag("vehicle")) //can't home in onto itself, also no hopping giant vehicles
		{
			//this, name, icon_name, blobname, description,
			ShopItem@ s = addShopItem(this, "Returning", "$mat_smallrocket$", "ReturningMod", "Slowly jumps back towards you", false);
			AddRequirement(s.requirements, "blob", "mat_smallrocket", "Small Rocket", 5 * priceMod);
			AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 20 * priceMod);
			AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 20 * priceMod);
			s.spawnNothing = true;
		}
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
	else if (spl[0] == "Script") //Easier add script recepies
	{
		target.AddScript(spl[1]);
	}
	else if (spl[0] == "RScript") //Easier remove script recepies
	{
		target.RemoveScript(spl[1]);
	}
	else if (spl[0] == "Gun") //Guns section
	{
		GunSettings@ settings;
		if(target.get("gun_settings", @settings))
		{
			if (spl[1] == "Maximumdakka")
			{
				target.Tag("MaximumdakkaMod");
				settings.FIRE_INTERVAL = settings.FIRE_INTERVAL/2; //halves fire interval but also heavily increases recoil, only on guns with already high firerate
				settings.B_SPREAD *= 2;
				settings.G_RECOIL *= 5;
				settings.G_BACK_T = 1;
			}
			else if (spl[1] == "SlowBullets")
			{
				settings.B_SPEED = 10; //Bullets move slower
				settings.B_TTL *= 2; //Because of this bullets need to be able to exist longer
				settings.B_GRAV *= 2; //Gravity adjustment due to bullet gravity code
			}
			else if (spl[1] == "Silencer")
			{
				settings.FIRE_SOUND = "";
				target.set_string("CustomCycle", "");
				//Does not remove reload sound
			}
			else if (spl[1] == "HarmlessBullets")
			{
				settings.B_DAMAGE = 0.0f;
				target.set_u8("CustomPenetration", 0); //Terrain damage is also 0
			}
		}
	}
	else
	{
		if (name == "Reduce Drag")
		{
			target.Tag("AerodynamicMod");
			target.getShape().setDrag(target.getShape().getDrag() * 0.2f); //CURRENTLY DIRECT CHANGES LIKE THIS MAY NOT BE STORED IN SAVE FILES but the tag deffinitly would be
		}
		else if (name == "Set Elasiticity")
		{
			target.getShape().setElasticity(0.8f);
		}
		else if (name == "Reduce Friction")
		{
			target.getShape().setFriction(0.01f);
		}
		else if (name == "Repair")
		{
			target.server_Heal(target.getInitialHealth() * 0.1f);
		}
		else if (name == "Reinforce")
		{
			target.server_SetHealth(target.getHealth() + target.getInitialHealth() * 0.5f);
		}
		else if (name == "ReturningMod")
		{
			target.AddScript("ReturningMod.as");
			target.set_u16("ReturningMod Target", caller.getNetworkID());
		}
		else if (name == "Set Buoyancy")
		{
			target.Tag("BuoyancyMod");
			target.getShape().getConsts().buoyancy = 1.2f;
		}
	}	
}