// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_catapult = 80;
const s32 cost_ballista = 150;
const s32 cost_ballista_ammo = 30;
const s32 cost_ballista_ammo_upgrade_gold = 60;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken("$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32, 8), 1);

	AddIconToken("$icon_steamtank$", "Icon_SteamTank.png", Vec2f(48, 28), 0);
	AddIconToken("$icon_bomber$", "Icon_Bomber.png", Vec2f(64, 64), 0);
	AddIconToken("$icon_armoredbomber$", "Icon_ArmoredBomber.png", Vec2f(64, 64), 0);
	AddIconToken("$icon_triplane$", "Icon_Triplane.png", Vec2f(64, 32), 0);
	
	AddIconToken("$icon_steamtank$", "Icon_Vehicles.png", Vec2f(48, 24), 0);
	AddIconToken("$icon_gatlinggun$", "Icon_Vehicles.png", Vec2f(24, 24), 2);
	AddIconToken("$icon_mortar$", "Icon_Vehicles.png", Vec2f(24, 24), 3);
	AddIconToken("$icon_howitzer$", "Icon_Vehicles.png", Vec2f(24, 24), 4);
	AddIconToken("$icon_rocketlauncher$", "Icon_Vehicles.png", Vec2f(24, 24), 5);
	// AddIconToken("$icon_mortar$", "Mortar.png", Vec2f(44, 64), 0);
	
	AddIconToken("$mat_ironplate$", "Material_IronPlate.png", Vec2f(8, 8), 0);
	AddIconToken("$mat_copperwire$", "Material_CopperWire.png", Vec2f(9, 11), 0);
	AddIconToken("$mat_pipe$", "Material_Pipe.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_gyromat$", "Material_Gyromat.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_gear$", "Material_Gear.png", Vec2f(9, 9), 0);
	AddIconToken("$mat_wheel$", "Material_Wheel.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_copperingot$", "Material_CopperIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_ironingot$", "Material_IronIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_steelingot$", "Material_SteelIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_mithrilingot$", "Material_MithrilIngot.png", Vec2f(16, 16), 1);
	
	
	AddIconToken("$bp_steamtank$", "Blueprints.png", Vec2f(16, 16), 1);
	
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 8));
	this.set_Vec2f("shop menu size", Vec2f(12, 8));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	
	AddIconToken("$buoy_icon$", "Buoy.png", Vec2f(32, 48), 0);
	

	
	{
		ShopItem@ s = addShopItem(this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + descriptions[5], false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + descriptions[6], false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Steam Tank", "$icon_steamtank$", "steamtank", "$icon_steamtank$\n\n\n" + "An armored land vehicle. Comes with a powerful cannon and a durable ram.", false, true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 10);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.crate_icon = 7;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	
	// {
		// ShopItem@ s = addShopItem(this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + descriptions[15], false, false);
		// s.crate_icon = 5;
		// s.customButton = true;
		// s.buttonwidth = 2;
		// s.buttonheight = 2;
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 160);
		// AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 80);
		// AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 20);
	// }
	{
		ShopItem@ s = addShopItem(this, "Dinghy", "$dinghy$", "dinghy", "$dinghy$\n\n\n" + descriptions[10]);
		// AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 5);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
		
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	// {
		// ShopItem@ s = addShopItem(this, "Buoy", "$buoy_icon$", "buoy", "Useful for anchoring.");
		// // AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 5);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		// AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
		// AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
		// s.spawnNothing = true;
	// }
	{
		ShopItem@ s = addShopItem(this, "Longboat", "$longboat$", "longboat", "$longboat$\n\n\n" + descriptions[33], false, true);
		// AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 20);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
		s.crate_icon = 1;
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "War Boat", "$warboat$", "warboat", "$warboat$\n\n\n" + descriptions[37], false, true);
		// AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 40);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 500);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.crate_icon = 2;
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}


	{
		ShopItem@ s = addShopItem(this, "Machine Gun", "$icon_gatlinggun$", "gatlinggun", "Useful for making holes.", false, true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
		// AddRequirement(s.requirements, "blob", "mat_gear", "Gear", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.crate_icon = 11;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Mortar", "$icon_mortar$", "mortar", "Mortar combat!", false, true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 6);
		// AddRequirement(s.requirements, "blob", "mat_gear", "Gear", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.crate_icon = 3;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Bomber", "$icon_bomber$", "bomber", "$icon_bomber$\n\n\n\n\n\n\n\n" + "A large aerial vehicle used for safe transport and bombing the peasants below.", false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.crate_icon = 0;
		s.customButton = true;
		s.buttonwidth = 4;
		s.buttonheight = 4;
	}
	
	
	{
		ShopItem@ s = addShopItem(this, "Armored Bomber", "$icon_armoredbomber$", "armoredbomber", "$icon_armoredbomber$\n\n\n\n\n\n\n\n" + "A fortified but slow moving balloon with an iron basket and two attachment slots. Resistant against gunfire.", false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.crate_icon = 0;
		s.customButton = true;
		s.buttonwidth = 4;
		s.buttonheight = 4;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Howitzer", "$icon_howitzer$", "howitzer", "Mortar's bigger brother.", false, true);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.crate_icon = 12;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Rocket Launcher", "$icon_rocketlauncher$", "rocketlauncher", "A rapid-fire rocket launcher especially useful against aerial targets.", false, true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.crate_icon = 12;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Spotter Airplane", "$icon_triplane$", "triplane", "$icon_triplane$\n\n\n\n" + "A fast airplane used for scouting and light bombing.\n\nW/D to accelerate\nLeft Mouse to shoot\nSpace to drop items out of inventory\nC to leave", false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.crate_icon = 0;
		s.customButton = true;
		s.buttonwidth = 4;
		s.buttonheight = 2;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Cargo Container", "$icon_cargocontainer$", "cargocontainer", "$icon_cargocontainer$\n\n\n\n" + "A large shipping container with a huge storage capacity.\n\nCan be moved around by vehicles.\nActs as a remote inventory.", false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 16);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.crate_icon = 0;
		s.customButton = true;
		s.buttonwidth = 4;
		s.buttonheight = 2;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		if(isServer()){
			
			if (name == "dinghy")
			{
				server_CreateBlob("dinghy", this.getTeamNum(), this.getPosition());
			}
		}
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(50); //foreground

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 64, 56, blob.getTeamNum(), blob.getSkinNum());

	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(1);
		planks.SetOffset(Vec2f(0.0f, 0.0f));
		planks.SetRelativeZ(-100);
	}
}