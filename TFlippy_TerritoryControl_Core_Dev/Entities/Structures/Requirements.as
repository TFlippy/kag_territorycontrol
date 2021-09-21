#include "ResearchCommon.as"
#include "Survival_Structs.as";
#include "Requirements_Tech.as"

string getButtonRequirementsText(CBitStream& inout bs,bool missing)
{
	string text,requiredType,name,friendlyName;
	u16 quantity=0;
	bs.ResetBitIndex();

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs,requiredType,name,friendlyName,quantity);
		string quantityColor;

		if (missing)
		{
			quantityColor = "$RED$";
		}
		else
		{
			quantityColor = "$GREEN$";
		}

		if (requiredType == "blob")
		{
			if (quantity > 0)
			{
				text += quantityColor;
				text += quantity;
				text += quantityColor;
				text += " ";
			}
			text += "$"; text += name; text += "$";
			text += " ";
			text += quantityColor;
			text += friendlyName;
			text += quantityColor;
			// text += " required.";
			text += "\n";
		}
		else if (requiredType == "coin")
		{
			text += quantity;
			text += " $COIN$ required\n";
		}
		else if (requiredType=="tech")
		{
			text += " \n$"; text += name; text += "$ ";
			text += quantityColor;
			text += friendlyName;
			text += quantityColor;
			// text += "\n\ntechnology required.\n";
		}
		else if (requiredType == "seclev feature")
		{
			text += quantityColor;
			text += "Access to role " + friendlyName + " required. \n";
			text += quantityColor;
		}
		else if (missing)
		{
			if (requiredType == "not tech")
			{
				text += " \n";
				text += quantityColor;
				text += friendlyName;
				text += " technology already acquired.\n";
				text += quantityColor;
			}
			else if (requiredType == "no more")
			{
				text += quantityColor;
				text += "Only "+quantity+" "+friendlyName+" per-team possible. \n";
				text += quantityColor;
			}
			else if (requiredType == "no less")
			{
				text += quantityColor;
				text += "At least "+quantity+" "+friendlyName+" required. \n";
				text += quantityColor;
			}
			else if (requiredType == "no more global")
			{
				text += quantityColor;
				text += "Only " + quantity + " " + friendlyName + " possible. \n";
				text += quantityColor;
			}
			else if (requiredType == "no less global")
			{
				text += quantityColor;
				text += "At least " + quantity + " " + friendlyName + " required. \n";
				text += quantityColor;
			}
		}
	}

	return text;
}

void SetItemDescription(CGridButton@ button, CBlob@ caller, CBitStream &in reqs, const string& in description, CInventory@ anotherInventory=null)
{
	if (button !is null && caller !is null && caller.getInventory() !is null)
	{
		CBitStream missing;

		if (hasRequirements(caller.getInventory(),anotherInventory,reqs,missing))
		{
			button.hoverText = description+"\n\n "+getButtonRequirementsText(reqs,false);
		}
		else
		{
			button.hoverText = description+"\n\n "+getButtonRequirementsText(missing,true);
			button.SetEnabled(false);
		}
	}
}

// read/write

void AddRequirement(CBitStream &inout bs, const string &in req, const string &in blobName, const string &in friendlyName, u16 &in quantity=1)
{
	bs.write_string(req);
	bs.write_string(blobName);
	bs.write_string(friendlyName);
	bs.write_u16(quantity);
}

bool ReadRequirement(CBitStream &inout bs, string &out req, string &out blobName, string &out friendlyName, u16 &out quantity)
{
	if (!bs.saferead_string(req))
	{
		return false;
	}

	if (!bs.saferead_string(blobName))
	{
		return false;
	}

	if (!bs.saferead_string(friendlyName))
	{
		return false;
	}

	if (!bs.saferead_u16(quantity))
	{
		return false;
	}

	return true;
}

//upd this
bool hasRequirements(CInventory@ inv1, CInventory@ inv2, CBitStream &inout bs, CBitStream &inout missingBs)
{
	string req, blobName, friendlyName;
	u16 quantity = 0;
	missingBs.Clear();
	bs.ResetBitIndex();
	bool has = true;

	CBlob@ playerBlob = (inv1 !is null 
		? (inv1.getBlob().getPlayer() !is null ? inv1.getBlob() 
			: (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null)) 
		: (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null));

	CBlob@[] baseBlobs;
	
	bool storageEnabled = false;
	
	if (playerBlob !is null)
	{
		int playerTeam = playerBlob.getTeamNum();

		if (playerTeam < 7)
		{
			TeamData@ team_data;
			GetTeamData(playerTeam, @team_data);

			if (team_data != null)
			{
				u16 upkeep = team_data.upkeep;
				u16 upkeep_cap = team_data.upkeep_cap;
				f32 upkeep_ratio = f32(upkeep) / f32(upkeep_cap);
				const bool faction_storage_enabled = team_data.storage_enabled;
				
				storageEnabled = upkeep_ratio <= UPKEEP_RATIO_PENALTY_STORAGE && faction_storage_enabled;
			}
		}

		if (storageEnabled)
		{
			getBlobsByTag("remote_storage", @baseBlobs);
			for (int i = 0; i < baseBlobs.length; i++)
			{
				if (baseBlobs[i].getTeamNum() != playerTeam)
				{
					baseBlobs.erase(i);
					i--;
				}
			}
			bool canPass = false;
			for (int i = 0; i < baseBlobs.length; i++)
			{
				if ((baseBlobs[i].getPosition() - playerBlob.getPosition()).Length() < 250.0f)
				{
					canPass = true;
					break;
				}
			}
			
			if (!canPass)
			{
				baseBlobs.clear();
			}
		}
	}

	while (!bs.isBufferEnd()) 
	{
		ReadRequirement(bs,req,blobName,friendlyName,quantity);
		if (req == "blob") 
		{
			int sum = (inv1 !is null ? inv1.getBlob().getBlobCount(blobName) : 0);
			
			if (storageEnabled)
			{
				for (int i = 0; i< baseBlobs.length; i++)
				{
					sum += baseBlobs[i].getBlobCount(blobName);
				}
			}
			
			if (sum<quantity) 
			{
				AddRequirement(missingBs,req,blobName,friendlyName,quantity);
				has = false;
			}
		}
		else if (req == "coin") 
		{
			CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;
			CPlayer@ player2 = inv2 !is null ? inv2.getBlob().getPlayer() : null;
			u16 sum = (player1 !is null ? player1.getCoins() : 0)+(player2 !is null ? player2.getCoins() : 0);
			if (sum<quantity) 
			{
				AddRequirement(missingBs,req,blobName,friendlyName,quantity);
				has=false;
			}
		}
		else if ((req == "no more" || req == "no less") && inv1 !is null) 
		{
			int teamNum = inv1.getBlob().getTeamNum();
			int count =	0;
			
			CBlob@[] blobs;
			if (getBlobsByName(blobName, @blobs)) 
			{
				for (uint step = 0; step < blobs.length; ++step) 
				{
					CBlob@ blob = blobs[step];
					if (blob.getTeamNum() == teamNum) 
					{
						count++;
					}
				}
			}
			
			if ((req == "no more" && count >= quantity) || (req == "no less" && count < quantity)) 
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
		else if ((req == "no more global" || req == "no less global") && inv1 !is null) 
		{
			CBlob@[] blobs;
			getBlobsByName(blobName, @blobs);
		
			int count =	blobs.length;
			if ((req == "no more global" && count >= quantity) || (req == "no less global" && count < quantity)) 
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
		else if (req == "tech")
		{
			int teamNum = playerBlob.getTeamNum();

			if (HasFakeTech(getRules(), blobName, teamNum))
			{
				// print(blobName + " is gud");
			}
			else
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
		else if (req == "seclev feature")
		{
			if (playerBlob !is null)
			{
				CPlayer@ player = playerBlob.getPlayer();
				if (player !is null)
				{
					CSecurity@ security = getSecurity();
					
					if (security.checkAccess_Feature(player, blobName))
					{
						//print("has feature " + blobName);
					}
					else
					{
						//print("no access to seclev feature " + blobName);
						
						AddRequirement(missingBs, req, blobName, friendlyName, quantity);
						has = false;
					}
				}
				else
				{
					has = false;
				}
			}
			else
			{
				has = false;
			}
		}
	}

	missingBs.ResetBitIndex();
	bs.ResetBitIndex();
	return has;
}

bool hasRequirements(CInventory@ inv, CBitStream &inout bs, CBitStream &inout missingBs)
{
	return (hasRequirements(inv, null, bs, missingBs));
}

void server_TakeRequirements(CInventory@ inv1, CInventory@ inv2, CBitStream &inout bs)
{
	if (!isServer()) {
		return;
	}

	CBlob@ playerBlob = (inv1 !is null 
		? (inv1.getBlob().getPlayer() !is null ? inv1.getBlob() 
			: (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null)) 
		: (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null));

	CBlob@[] baseBlobs;
	
	bool storageEnabled = false;

	if (playerBlob !is null)
	{
		int playerTeam = playerBlob.getTeamNum();
		
		if (playerTeam < 7)
		{
			TeamData@ team_data;
			GetTeamData(playerTeam, @team_data);

			if (team_data != null)
			{
				u16 upkeep = team_data.upkeep;
				u16 upkeep_cap = team_data.upkeep_cap;
				f32 upkeep_ratio = f32(upkeep) / f32(upkeep_cap);
				const bool faction_storage_enabled = team_data.storage_enabled;
				
				storageEnabled = upkeep_ratio <= UPKEEP_RATIO_PENALTY_STORAGE && faction_storage_enabled;
			}
		}

		if (storageEnabled)
		{
			getBlobsByTag("remote_storage", @baseBlobs);
			for (int i = 0; i < baseBlobs.length; i++)
			{
				if (baseBlobs[i].getTeamNum() != playerTeam)
				{
					baseBlobs.erase(i);
					i--;
				}
			}
		}
	}

	string req,blobName,friendlyName;
	u16 quantity;
	bs.ResetBitIndex();
	while (!bs.isBufferEnd()) 
	{
		ReadRequirement(bs, req, blobName, friendlyName, quantity);
		if (req == "blob") 
		{
			bool hasBluePrint = blobName.findFirst("bp_") >= 0;
			if (!hasBluePrint)
			{
				u16 taken = 0;

				if (inv1 !is null && taken < quantity) 
				{
					CBlob@ invBlob = inv1.getBlob();
					taken += Maths::Min(invBlob.getBlobCount(blobName), quantity - taken);
					invBlob.TakeBlob(blobName, quantity);
				}
				
				if (inv2 !is null && taken < quantity) 
				{
					CBlob@ invBlob = inv2.getBlob();
					u16 hold = taken;
					taken += Maths::Min(invBlob.getBlobCount(blobName), quantity - taken);
	            	invBlob.TakeBlob(blobName, quantity - hold);
				}

				if (storageEnabled)
				{
					for (int i = 0; i < baseBlobs.length; i++)
					{
						if (taken >= quantity)
						{
							break;
						}
						u16 hold = taken;
						taken += Maths::Min(baseBlobs[i].getBlobCount(blobName), quantity - taken);
						baseBlobs[i].TakeBlob(blobName, quantity - hold);
					}
				}
			}
		}
		else if (req == "coin") 
		{ // TODO...
			CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;
			CPlayer@ player2 = inv2 !is null ? inv2.getBlob().getPlayer() : null;
			int taken = 0;
			if (player1 !is null) 
			{
				taken = Maths::Min(player1.getCoins(), quantity);
				player1.server_setCoins(player1.getCoins() - taken);
			}
			if (player2 !is null) 
			{
				taken = quantity - taken;
				taken = Maths::Min(player2.getCoins(), quantity);
				player2.server_setCoins(player2.getCoins() - taken);
			}
		}
	}

	bs.ResetBitIndex();
}

void server_TakeRequirements(CInventory@ inv, CBitStream &inout bs)
{
	server_TakeRequirements(inv, null, bs);
}
