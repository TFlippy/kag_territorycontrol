#include "RunnerCommon.as"

// Made by GoldenGuy 

void onInit(CBlob@ this)
{
	this.Tag("equipment support");

	this.addCommandID("equip_head");
	this.addCommandID("equip_torso");
	this.addCommandID("equip_boots");
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu@ gridmenu)
{
	const string name = this.getName();

	Vec2f MENU_POS;

	if (name == "builder" || name == "peasant") MENU_POS = gridmenu.getUpperLeftPosition() + Vec2f(-84, -204);
	else if (name == "archer") MENU_POS = gridmenu.getUpperLeftPosition() + Vec2f(-84, -56);
	else MENU_POS = gridmenu.getUpperLeftPosition() + Vec2f(-36, -56);

	CGridMenu@ equipments = CreateGridMenu(MENU_POS, this, Vec2f(1, 3), "equipment");

	string HeadImage = "Equipment.png";
	string TorsoImage = "Equipment.png";
	string BootsImage = "Equipment.png";

	int HeadFrame = 0;
	int TorsoFrame = 1;
	int BootsFrame = 2;

	if(this.get_string("equipment_head") != "")
	{
		HeadImage = this.get_string("equipment_head")+"_icon.png";
		HeadFrame = 0;
	}
	if(this.get_string("equipment_torso") != "")
	{
		TorsoImage = this.get_string("equipment_torso")+"_icon.png";
		TorsoFrame = 0;
	}
	if(this.get_string("equipment_boots") != "")
	{
		BootsImage = this.get_string("equipment_boots")+"_icon.png";
		BootsFrame = 0;
	}

	if(equipments !is null)
	{
		equipments.SetCaptionEnabled(false);
		equipments.deleteAfterClick = false;

		if (this !is null)
		{
			CBitStream params;
			params.write_u16(this.getNetworkID());

			int teamnum = this.getTeamNum();
			if (teamnum > 6) teamnum = 7;
			AddIconToken("$headimage$", HeadImage, Vec2f(24, 24), HeadFrame, teamnum);
			AddIconToken("$torsoimage$", TorsoImage, Vec2f(24, 24), TorsoFrame, teamnum);
			AddIconToken("$bootsimage$", BootsImage, Vec2f(24, 24), BootsFrame, teamnum);

			CGridButton@ head = equipments.AddButton("$headimage$", "", this.getCommandID("equip_head"), Vec2f(1, 1), params);
			if(head !is null)
			{
				if (this.get_string("equipment_head") != "") head.SetHoverText("Unequip head.\n");
				else head.SetHoverText("Equip head.\n");
			}

			CGridButton@ torso = equipments.AddButton("$torsoimage$", "", this.getCommandID("equip_torso"), Vec2f(1, 1), params);
			if (torso !is null)
			{
				if (this.get_string("equipment_torso") != "") torso.SetHoverText("Unequip torso.\n");
				else torso.SetHoverText("Equip torso.\n");
			}

			CGridButton@ boots = equipments.AddButton("$bootsimage$", "", this.getCommandID("equip_boots"), Vec2f(1, 1), params);
			if (boots !is null)
			{
				if (this.get_string("equipment_boots") != "") boots.SetHoverText("Unequip boots.\n");
				else boots.SetHoverText("Equip boots.\n");
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("equip_head") || cmd == this.getCommandID("equip_torso") || cmd == this.getCommandID("equip_boots"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID)) return;
		CBlob@ caller = getBlobByNetworkID(callerID);
		if (caller is null) return;
		if (caller.get_string("equipment_torso") != "" && cmd == this.getCommandID("equip_torso")) removeTorso(caller, caller.get_string("equipment_torso"));
		else if (caller.get_string("equipment_boots") != "" && cmd == this.getCommandID("equip_boots")) removeBoots(caller, caller.get_string("equipment_boots"));
		else if (caller.get_string("equipment_head") != "" && cmd == this.getCommandID("equip_head")) removeHead(caller, caller.get_string("equipment_head"));

		CBlob@ item = caller.getCarriedBlob();
		if(item !is null)
		{
			if (getEquipmentType(item) == "head")
			{
				addHead(caller, item.getName());
				if (item.getName() == "militaryhelmet") caller.set_f32("mh_health", item.get_f32("health"));
				else if (item.getName() == "bucket") caller.set_f32("bucket_health", item.get_f32("health"));
				item.server_Die();
			}
			else if (getEquipmentType(item) == "torso")
			{
				addTorso(caller, item.getName());
				if (item.getName() == "bulletproofvest") caller.set_f32("bpv_health", item.get_f32("health"));
				else if (item.getName() == "keg") caller.set_f32("keg_health", item.get_f32("health"));
				item.server_Die();
			}
			else if (getEquipmentType(item) == "boots")
			{
				addBoots(caller, item.getName());
				if (item.getName() == "combatboots") caller.set_f32("cb_health", item.get_f32("health"));
				item.server_Die();
			}
		}

		caller.ClearMenus();
	}
}

string getEquipmentType(CBlob@ equipment)
{
	if(equipment.hasTag("head")) return "head";
	else if(equipment.hasTag("torso")) return "torso";
	else if(equipment.hasTag("boots")) return "boots";

	return "nugat";		//haha yes.
}

void addHead(CBlob@ playerblob, string headname)	//Here you need to add head overriding. If you dont need to override head just ignore this part of script.
{
	if(playerblob.get_string("equipment_head") == "")
	{
		if(playerblob.get_u8("override head") != 0) playerblob.set_u8("last head", playerblob.get_u8("override head"));
		else playerblob.set_u8("last head", playerblob.getHeadNum());
	}
	// if(headname == "minershelmet")
		// playerblob.set_u8("override head", 30);

	// if(headname == "militaryhelmet")
		// playerblob.set_u8("override head", 30);
	if(headname == "scubagear") playerblob.set_u8("override head", 88);
	else if(headname == "bucket") playerblob.set_u8("override head", 107);
	else if(headname == "pumpkin") playerblob.set_u8("override head", 108);

	playerblob.setHeadNum((playerblob.getHeadNum()+1) % 3);
	playerblob.Tag(headname);
	playerblob.set_string("reload_script", headname);
	if(headname != "pumpkin") playerblob.AddScript(headname+"_effect.as");
	playerblob.set_string("equipment_head", headname);
	playerblob.Tag("update head");
}

void removeHead(CBlob@ playerblob, string headname)
{
	if (playerblob.getSprite().getSpriteLayer(headname) !is null) playerblob.getSprite().RemoveSpriteLayer(headname);
	if (headname == "minershelmet") playerblob.SetLight(false);	//example of removing custom tags like Light

	playerblob.Untag(headname);
	if(isServer())
	{
		CBlob@ oldeq = server_CreateBlob(headname, playerblob.getTeamNum(), playerblob.getPosition());
		if(headname == "militaryhelmet")	//need to be after creating blob, bcos it sets hp to it
		{
			oldeq.set_f32("health", playerblob.get_f32("mh_health"));
			oldeq.getSprite().SetFrameIndex(Maths::Floor(playerblob.get_f32("mh_health") / 4.00f));
		}
		else if(headname == "bucket")
		{
			oldeq.set_f32("health", playerblob.get_f32("bucket_health"));
			// oldeq.getSprite().SetFrameIndex(Maths::Floor(playerblob.get_f32("bucket_health") / 4.00f)); // I don't have anyone to make sprite for me :kag_depression:
		}
		playerblob.server_PutInInventory(oldeq);
	}
	playerblob.set_u8("override head", playerblob.get_u8("last head"));
	playerblob.setHeadNum((playerblob.getHeadNum()+1) % 3);
	playerblob.set_string("equipment_head", "");
	playerblob.RemoveScript(headname+"_effect.as");
	playerblob.Tag("update head");
}

void addTorso(CBlob@ playerblob, string torsoname)			//The same stuff as in head here.
{
	playerblob.Tag(torsoname);
	playerblob.set_string("reload_script", torsoname);
	playerblob.AddScript(torsoname+"_effect.as");
	playerblob.set_string("equipment_torso", torsoname);
}

void removeTorso(CBlob@ playerblob, string torsoname)		//Same stuff with removing again.
{
	if(torsoname == "parachutepack")
	{
		CSpriteLayer@ pack = playerblob.getSprite().getSpriteLayer("pack");
		if (pack !is null) playerblob.getSprite().RemoveSpriteLayer("pack");
		CSpriteLayer@ parachute = playerblob.getSprite().getSpriteLayer("parachute");
		if (parachute !is null)
		{
			if (parachute.isVisible()) ParticlesFromSprite(parachute);
			if (playerblob.hasTag("parachute")) playerblob.getSprite().PlaySound("join");
			playerblob.getSprite().RemoveSpriteLayer("parachute");
		}
		playerblob.Untag("parachute");
	}
	else if (playerblob.getSprite().getSpriteLayer(torsoname) !is null) playerblob.getSprite().RemoveSpriteLayer(torsoname);

	if(torsoname == "backpack")
	{
		CBlob@ backpackblob = getBlobByNetworkID(playerblob.get_u16("backpack_id"));
		if (backpackblob !is null) backpackblob.server_Die();
	}

	playerblob.Untag(torsoname);
	if(isServer())
	{
		CBlob@ oldeq = server_CreateBlob(torsoname, playerblob.getTeamNum(), playerblob.getPosition());
		if(torsoname == "bulletproofvest") oldeq.set_f32("health", playerblob.get_f32("bpv_health"));	//need to be after creating blob, bcos it sets hp to it
		if(torsoname == "keg") oldeq.set_f32("health", playerblob.get_f32("keg_health"));
		playerblob.server_PutInInventory(oldeq);
	}
	
	playerblob.set_string("equipment_torso", "");
	playerblob.RemoveScript(torsoname+"_effect.as");
}

void addBoots(CBlob@ playerblob, string bootsname)		//You still reading this?
{
	playerblob.Tag(bootsname);
	playerblob.set_string("reload_script", bootsname);
	playerblob.AddScript(bootsname+"_effect.as");
	playerblob.set_string("equipment_boots", bootsname);
}

void removeBoots(CBlob@ playerblob, string bootsname)		//I think you should already get how this works.
{
	if(bootsname == "flippers")
	{
		RunnerMoveVars@ moveVars;
		if(playerblob.get("moveVars", @moveVars)) moveVars.swimspeed -= 10.0f;
	}

	playerblob.Untag(bootsname);
	if(isServer())
	{
		CBlob@ oldeq = server_CreateBlob(bootsname, playerblob.getTeamNum(), playerblob.getPosition());
		if(bootsname == "combatboots") oldeq.set_f32("health", playerblob.get_f32("cb_health"));	//need to be after creating blob, bcos it sets hp to it
		playerblob.server_PutInInventory(oldeq);		
	}
	playerblob.set_string("equipment_boots", "");
	playerblob.RemoveScript(bootsname+"_effect.as");
}

void onDie(CBlob@ this)
{
    if (isServer())
	{
		if (this.get_string("equipment_head") != "")
		{
			if(this.get_string("equipment_head") == "militaryhelmet")
			{ }
			else server_CreateBlob(this.get_string("equipment_head"), this.getTeamNum(), this.getPosition());
		}
		if (this.get_string("equipment_torso") != "")
		{
			if(this.get_string("equipment_torso") == "bulletproofvest" || this.get_string("equipment_torso") == "keg")
			{ }
			else if(!this.exists("vest_explode"))
				server_CreateBlob(this.get_string("equipment_torso"), this.getTeamNum(), this.getPosition());
		}
		if (this.get_string("equipment_boots") != "")
		{
			if(this.get_string("equipment_boots") == "combatboots")
			{ }
			else server_CreateBlob(this.get_string("equipment_boots"), this.getTeamNum(), this.getPosition());
		}
	}
}
