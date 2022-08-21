// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

Random traderRandom(Time());

const string[] ResearchNames = 
{
	"Advanced Automation",
	"Chemistry",
	"Energetics",
	"Enrichment",
	"Induction"
};

const string[] BlueprintDescription = 
{
	"Enables the construction of the advanced automated assembler to create chicken-level technology.",
	"Enables the construction of the automated drug lab.",
	"Enables the construction of the beam tower.",
	"Enables the construction of the mithril reactor.",
	"Enables the construction of the induction furnace."
};

const string[] ResearchBlob = 
{
	"automation",
	"chemistry",
	"energetics",
	"enrichment",
	"induction"
};

const string[] ResearchReverse = 
{
	"assaultrifle",
	"minidruglab",
	"zapper",
	"mat_mithril",
	"gaussrifle"
};

const int[] ResearchTimes = //In Minutes
{ 
	5,
	10,
	5,
	60,
	10
};

const int[] ResearchCost = //Coins
{ 
	5000,
	7500,
	5000,
	10000,
	10000
};

//Could probably expand this to auto generate shop entries but eh that would take long - Rob

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	// this.Tag("upkeep building");
	// this.set_u8("upkeep cap increase", 0);
	// this.set_u8("upkeep cost", 5);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	this.set_Vec2f("shop offset", Vec2f(10,0));
	this.set_Vec2f("shop menu size", Vec2f(5, 3));
	this.set_string("shop description", "Bookworm's Lair");
	this.set_u8("shop icon", 25);
	
	AddIconToken("$bp_mechanist$", "Blueprints.png", Vec2f(16, 16), 0);
	
	for(int i = 0;i < ResearchReverse.length;i++){
		AddIconToken("$bpicon_"+i+"$", "Blueprints.png", Vec2f(16, 16), i*2);
		{
			ShopItem@ s = addShopItem(this, "Fund Research Grants: "+ResearchNames[i], "$bpicon_"+i+"$", "bp_"+ResearchBlob[i], "Pay actually smart intellectuals to turn your theory into a usable blueprint.\n"+BlueprintDescription[i], true);
			AddRequirement(s.requirements, "coin", "", "Coins", ResearchCost[i]);
			AddRequirement(s.requirements, "blob", "theory_"+ResearchBlob[i], ResearchNames[i]+" Theory", 1);

			s.spawnNothing = true;
		}
	}

	for(int i = 0;i < ResearchReverse.length;i++){
		{
			ShopItem@ s = addShopItem(this, "Sell "+ResearchNames[i]+" Blueprint", "$COIN$", "coin-"+(ResearchCost[i]/5), "Sell an unneeded blueprint, capitalising on the restrictive flow of information.", true);
			AddRequirement(s.requirements, "blob", "bp_"+ResearchBlob[i], ResearchNames[i]+" Blueprint", 1);
			s.spawnNothing = true;
		}
	}
	
	for(int i = 0;i < ResearchReverse.length;i++){
		{
			ShopItem@ s = addShopItem(this, "Sell "+ResearchNames[i]+" Theory", "$COIN$", "coin-"+(ResearchCost[i]/10), "Sell an unneeded theory, capitalising on the restrictive flow of information.", true);
			AddRequirement(s.requirements, "blob", "theory_"+ResearchBlob[i], ResearchNames[i]+" Theory", 1);
			s.spawnNothing = true;
		}
	}
	
	this.set_u32("research_time",0); //In seconds
	this.getCurrentScript().tickFrequency = 30;
	this.set_string("research_blob","");
	this.set_string("research_name","");
	
	this.addCommandID("research");
	this.addCommandID("fund");
}

void onTick(CBlob@ this){
	if(isServer()){
		if(this.get_u32("research_time") > 0){
			this.sub_u32("research_time",1);
			this.Sync("research_time",true);
		}
		if(this.get_u32("research_time") <= 0){
			if(this.get_string("research_blob") != ""){
				server_CreateBlob(this.get_string("research_blob"),-1,this.getPosition());
				this.set_string("research_blob","");
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
	
	if(caller.getCarriedBlob() !is null){
		CBitStream params;
		params.write_u16(caller.getCarriedBlob().getNetworkID());

		if(this.get_u32("research_time") <= 0)caller.CreateGenericButton(23, Vec2f(-5, 0), this, this.getCommandID("research"), "Reverse Engineer", params);
	}
	
	int seconds = this.get_u32("research_time");
	if(seconds > 0){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton(26, Vec2f(0, -7), this, this.getCommandID("fund"), "Fund with 1000 Coins\nHalves research time.", params);
	
		int minutes = seconds/60;
		seconds = seconds % 60;
		string time = ""+minutes+(seconds >= 10 ? ":" : ":0")+seconds;
		CButton@ button = caller.CreateGenericButton(23, Vec2f(-5, 0), this, this.getCommandID("research"), "Researching "+this.get_string("research_name")+": "+time);
		button.SetEnabled(false);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ConstructShort");

		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		if (callerBlob is null) return;

		if (isServer())
		{
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1 || name.findFirst("ammo_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				CBlob@ mat = server_CreateBlob(spl[0]);

				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (blob is null) return;

				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
	
	
	if (cmd == this.getCommandID("research"))
	{
		CBlob@ item = getBlobByNetworkID(params.read_u16());
		if(isServer() && this.get_u32("research_time") <= 0)
		if(item !is null){
			string name = item.getName();
			
			for(int i = 0;i < ResearchReverse.length;i++){
				if(name == ResearchReverse[i]){
					item.server_Die();
					this.set_u32("research_time",ResearchTimes[i]*60); //Convert minutes to seconds
					this.set_string("research_blob","theory_"+ResearchBlob[i]);
					this.set_string("research_name",ResearchNames[i]);
					this.Sync("research_name",true);
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("fund"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(this.get_u32("research_time") > 0)
		if(caller !is null){
			CPlayer@player = caller.getPlayer();
			if(player !is null){
				int coins = player.getCoins();
				if(coins >= 1000){
					this.set_u32("research_time",this.get_u32("research_time")/2.0f);
					if(isServer()){
						player.server_setCoins(coins-1000);
						this.Sync("research_time",true);
					}
				}
			}
		}
	}
}
