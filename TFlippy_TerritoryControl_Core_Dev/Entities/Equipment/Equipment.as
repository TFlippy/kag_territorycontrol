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

			CGridButton@ head = equipments.AddButton(HeadImage, HeadFrame, "", this.getCommandID("equip_head"), Vec2f(1, 1), params);
			if(head !is null)
			{
				if (this.get_string("equipment_head") != "")
					head.SetHoverText("Unequip head.\n");
				else
					head.SetHoverText("Equip head.\n");
			}

			CGridButton@ torso = equipments.AddButton(TorsoImage, TorsoFrame, "", this.getCommandID("equip_torso"), Vec2f(1, 1), params);
			if (torso !is null)
			{
				if (this.get_string("equipment_torso") != "")
					torso.SetHoverText("Unequip torso.\n");
				else
					torso.SetHoverText("Equip torso.\n");
			}

			CGridButton@ boots = equipments.AddButton(BootsImage, BootsFrame, "", this.getCommandID("equip_boots"), Vec2f(1, 1), params);
			if (boots !is null)
			{
				if (this.get_string("equipment_boots") != "")
					boots.SetHoverText("Unequip boots.\n");
				else
					boots.SetHoverText("Equip boots.\n");
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("equip_head"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		CBlob@ caller = getBlobByNetworkID(callerID);
		if (caller is null)
			return;

		bool holdingequipment = false;
		CBlob@ item = caller.getCarriedBlob();
		if(item !is null && getEquipmentType(item) == "head")
			holdingequipment = true;
		
		if(caller.get_string("equipment_head") != "")
		{
			removeHead(caller, caller.get_string("equipment_head"));
			if(holdingequipment)
			{
				addHead(caller, item.getName());
				if (item.getName() == "militaryhelmet")
				{
					caller.set_f32("mh_health", item.get_f32("health"));
				}
				item.server_Die();
			}
		}
		else
		{
			if(holdingequipment)
			{
				addHead(caller, item.getName());
				if (item.getName() == "militaryhelmet")
				{
					caller.set_f32("mh_health", item.get_f32("health"));
				}
				item.server_Die();
			}
		}
		caller.ClearMenus();
	}
	if (cmd == this.getCommandID("equip_boots"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		CBlob@ caller = getBlobByNetworkID(callerID);
		if (caller is null)
			return;

		bool holdingequipment = false;
		CBlob@ item = caller.getCarriedBlob();
		if(item !is null && getEquipmentType(item) == "boots")
			holdingequipment = true;
		
		if(caller.get_string("equipment_boots") != "")
		{
			removeBoots(caller, caller.get_string("equipment_boots"));
			if(holdingequipment)
			{
				addBoots(caller, item.getName());
				if (item.getName() == "combatboots")
				{
					caller.set_f32("cb_health", item.get_f32("health"));
				}
				item.server_Die();
			}
		}
		else
		{
			if(holdingequipment)
			{
				addBoots(caller, item.getName());
				if (item.getName() == "combatboots")
				{
					caller.set_f32("cb_health", item.get_f32("health"));
				}
				item.server_Die();
			}
		}
		caller.ClearMenus();
	}
	if (cmd == this.getCommandID("equip_torso"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		CBlob@ caller = getBlobByNetworkID(callerID);
		if (caller is null)
			return;

		bool holdingequipment = false;
		CBlob@ item = caller.getCarriedBlob();
		if(item !is null && getEquipmentType(item) == "torso")
			holdingequipment = true;
		
		if(caller.get_string("equipment_torso") != "")
		{
			removeTorso(caller, caller.get_string("equipment_torso"));
			if(holdingequipment)
			{
				addTorso(caller, item.getName());
				if (item.getName() == "bulletproofvest")
				{
					caller.set_f32("bpv_health", item.get_f32("health"));
				}
				item.server_Die();
			}
		}
		else
		{
			if(holdingequipment)
			{
				addTorso(caller, item.getName());
				if (item.getName() == "bulletproofvest")
				{
					caller.set_f32("bpv_health", item.get_f32("health"));
				}
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
		if(playerblob.get_u8("override head") != 0)
			playerblob.set_u8("last head", playerblob.get_u8("override head"));
		else	
			playerblob.set_u8("last head", playerblob.getHeadNum());
	}

	if(headname == "scubagear")
		playerblob.set_u8("override head", 88);

	// if(headname == "minershelmet")
		// playerblob.set_u8("override head", 30);

	// if(headname == "militaryhelmet")
		// playerblob.set_u8("override head", 30);

	if(headname == "bucket")
		playerblob.set_u8("override head", 101);
	
	if(headname == "pumpkin")
		playerblob.set_u8("override head", 101);

	playerblob.setHeadNum((playerblob.getHeadNum()+1) % 3);
	playerblob.Tag(headname);
	playerblob.set_string("reload_script", headname);
	playerblob.AddScript(headname+"_effect.as");
	playerblob.set_string("equipment_head", headname);
	playerblob.Tag("update head");
}

void removeHead(CBlob@ playerblob, string headname)		//Here you can remove side effects when removing helmet (light, spritelayer, your tags, etc).
{														//If you didnt added thos, just ignore this part of script.
	if(headname == "minershelmet")
	{
		CSpriteLayer@ mhelmet = playerblob.getSprite().getSpriteLayer("mhelmet");
		if (mhelmet !is null)
		{
			playerblob.getSprite().RemoveSpriteLayer("mhelmet");
			playerblob.SetLight(false);
		}
	}
	
	if(headname == "crown")
	{
		CSpriteLayer@ crown = playerblob.getSprite().getSpriteLayer("crown");
		if (crown !is null)
		{
			playerblob.getSprite().RemoveSpriteLayer("crown");
		}
	}
	
	if(headname == "militaryhelmet")
	{
		CSpriteLayer@ milhelmet = playerblob.getSprite().getSpriteLayer("milhelmet");
		if (milhelmet !is null)
		{
			playerblob.getSprite().RemoveSpriteLayer("milhelmet");
		}
	}
	
	if(headname == "bucket")
	{
		CSpriteLayer@ buckethead = playerblob.getSprite().getSpriteLayer("buckethead");
		if (buckethead !is null)
		{
			playerblob.getSprite().RemoveSpriteLayer("buckethead");
		}
	}
	
	if(headname == "pumpkin")
	{
		CSpriteLayer@ pumpkinhead = playerblob.getSprite().getSpriteLayer("pumpkinhead");
		if (pumpkinhead !is null)
		{
			playerblob.getSprite().RemoveSpriteLayer("pumpkinhead");
		}
	}
	
	playerblob.Untag(headname);
	if(isServer())
	{
		if(headname == "militaryhelmet")			//need to be after creating blob, bcos it sets hp to it
		{
			CBlob@ oldeq = server_CreateBlob(headname, playerblob.getTeamNum(), playerblob.getPosition());
			oldeq.set_f32("health", playerblob.get_f32("mh_health"));
			oldeq.getSprite().SetFrameIndex(Maths::Floor(playerblob.get_f32("mh_health") / 4.00f));
			playerblob.server_PutInInventory(oldeq);
		}
		else
		{
			CBlob@ oldeq = server_CreateBlob(headname, playerblob.getTeamNum(), playerblob.getPosition());
			playerblob.server_PutInInventory(oldeq);
		}
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
	if(torsoname == "jetpack")
	{
		CSpriteLayer@ jetpack = playerblob.getSprite().getSpriteLayer("jetpack");
		if (jetpack !is null)
		{
			playerblob.getSprite().RemoveSpriteLayer("jetpack");
		}
	}

	if(torsoname == "suicidevest")
	{
		CSpriteLayer@ svest = playerblob.getSprite().getSpriteLayer("svest");
		if (svest !is null)
		{
			playerblob.getSprite().RemoveSpriteLayer("svest");
		}
	}
	
	if(torsoname == "backpack")
	{
		CSpriteLayer@ backpack = playerblob.getSprite().getSpriteLayer("backpack");
		if (backpack !is null)
		{
			playerblob.getSprite().RemoveSpriteLayer("backpack");
		}
		CBlob@ backpackblob = getBlobByNetworkID(playerblob.get_u16("backpack_id"));
		if (backpackblob !is null)
			backpackblob.server_Die();
	}
	
	if(torsoname == "keg")
	{
		CSpriteLayer@ barrel = playerblob.getSprite().getSpriteLayer("barrel");
		if (barrel !is null)
		{
			playerblob.getSprite().RemoveSpriteLayer("barrel");
		}
	}
	
	playerblob.Untag(torsoname);
	if(isServer())
	{
		if(torsoname == "bulletproofvest")			//need to be after creating blob, bcos it sets hp to it
		{
			CBlob@ oldeq = server_CreateBlob(torsoname, playerblob.getTeamNum(), playerblob.getPosition());
			oldeq.set_f32("health", playerblob.get_f32("bpv_health"));
			playerblob.server_PutInInventory(oldeq);
		}
		else
		{
			CBlob@ oldeq = server_CreateBlob(torsoname, playerblob.getTeamNum(), playerblob.getPosition());
			playerblob.server_PutInInventory(oldeq);
		}
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
		if(playerblob.get("moveVars", @moveVars))
		{
			moveVars.swimspeed -= 10.0f;
		}
	}
	
	playerblob.Untag(bootsname);
	if(isServer())
	{
		if(bootsname == "combatboots")			//need to be after creating blob, bcos it sets hp to it
		{
			CBlob@ oldeq = server_CreateBlob(bootsname, playerblob.getTeamNum(), playerblob.getPosition());
			oldeq.set_f32("health", playerblob.get_f32("cb_health"));
			playerblob.server_PutInInventory(oldeq);
		}
		else
		{
			CBlob@ oldeq = server_CreateBlob(bootsname, playerblob.getTeamNum(), playerblob.getPosition());
			playerblob.server_PutInInventory(oldeq);
		}
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
			if(this.get_string("equipment_torso") == "bulletproofvest")
			{ }
			else if(this.get_string("equipment_torso") == "suicidevest" && !this.exists("vest_explode"))
				server_CreateBlob(this.get_string("equipment_torso"), this.getTeamNum(), this.getPosition());
			else if(this.get_string("equipment_torso") != "suicidevest")
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
