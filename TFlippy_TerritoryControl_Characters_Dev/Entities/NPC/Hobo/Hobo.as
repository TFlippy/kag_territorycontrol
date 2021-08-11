#include "RunnerCommon.as"
#include "Help.as";
#include "Hitters.as";
#include "Requirements.as";
#include "ShopCommon.as";

const string[] firstnames =
{
	"Kevin",
	"Eughene",
	"Lawrence",
	"Macaulay",
	"Johnny",
	"Steve",
	"Sid",
	"Johnny",
	"Jethro",
	"Nelson",
	"Bobby",
	"Harry",
	"Barry",
	"Jerry",
	"Garry"
};

const string[] surnames =
{
	"Bobington",
	"Culkin",
	"Stud",
	"Garbel",
	"Bud",
	"Nelson",
	"Snot",
	"Aqualung",
	"Ugh",
	"Dump"
};

const string[] soundsTalk =
{
	"MigrantHmm.ogg",
	"drunk_fx2.ogg",
	"drunk_fx3.ogg",
	"drunk_fx4.ogg"
};

const string[] soundsDanger =
{
	"trader_scream_0.ogg",
	"trader_scream_1.ogg",
	"trader_scream_2.ogg"
};

const string[] textsIdle =
{
	"give me ya money 'itch",
	"c'mere here ya shit",
	"oi ya shit",
	"ay give me ya stuff",
	"did ya brin' the wine",
	"let's 'eat up 'arry tomorra",
	"aye, we'll fuck him up",
	"hav ya seen garry lately?",
	"gnarly",
	"yar",
	"arrrr",
	"*gurgle*",
	"ayy shit!",
	"psftush",
	"ohoho",
	"ya bloody idiot",
	"damn right innit?",
	"wanna fight ya cunt?",
	"sit on ya arse",
	"ill bash ye fookin 'ead in i sware on me mum"
};

const string[] textsDanger =
{
	"ya weenie 'lil shit",
	"i'll get ya asshole",
	"kill yarself",
	"get out of here ya weenie 'lil shit",
	"so wanna fight huh?",
	"give me ya money 'itch",
	"c'mere here ya shit",
	"oi ya shit",
	"aye, we'll fuck him up",
	"yar",
	"arrrr",
	"ayy shit!",
	"ya bloody idiot",
	"damn right innit?",
	"wanna fight ya cunt?",
	"sit on ya arse",
	"ill bash ye fookin ead in i sware on me mum",
	"ow shid"
};

const string[] textsWon =
{
	"put me 'ack ya shitbag",
	"go to hell",
	"scrub",
	"na give me ya money",
	"oi ya shit",
	"ay give me ya stuff",
	"aye, we did fuck him up",
	"yar",
	"arrrr",
	"*gurgle*",
	"ayy shit!",
	"ya bloody idiot",
	"damn right innit?",
	"wanna fight ya cunt?",
	"sit on ya arse"
};

void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());
	string name = firstnames[rand.NextRanged(firstnames.length)] + " " + surnames[rand.NextRanged(surnames.length)];
	this.set_string("trader name", name);

	this.getShape().SetRotationsAllowed(false);
	this.set_f32("gib health", -2.0f);
	this.set_f32("crak_effect", 1.00f);
	this.set_f32("drunk_effect", 4.00f);
	this.Tag("flesh");
	this.Tag("migrant");
	this.Tag("human");
	this.getBrain().server_SetActive(true);

	this.set_u32("nextTalk", getGameTime() + XORRandom(60));
	this.set_u32("nextFood", 0);

	this.addCommandID("traderChat");

	addTokens(this); //colored shop icons

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6, 4));
	this.set_string("shop description", name + " the Hobo");
	this.setInventoryName(name + " the Hobo");
	this.set_u8("shop icon", 25);

	this.set_u32("lastDanger", 0);

	if (rand.NextRanged(100) < 50)
	{
		ShopItem@ s = addShopItem(this, "honking shite", "$klaxon$", "klaxon", "throw it away");
		AddRequirement(s.requirements, "coin", "", "Coins", 50 + rand.NextRanged(500));
		s.spawnNothing = true;
	}

	/*if (rand.NextRanged(100) < 50)
	{
		ShopItem@ s = addShopItem(this, "big cuffs", "$shackles$", "shackles", "tie that fool up");
		AddRequirement(s.requirements, "coin", "", "Coins", 100 + rand.NextRanged(500));
		s.spawnNothing = true;
	}*/

	if (rand.NextRanged(100) < 50)
	{
		ShopItem@ s = addShopItem(this, "sticky stick", "$nightstick$", "nightstick", "a stick for beating up");
		AddRequirement(s.requirements, "coin", "", "Coins", 50 + rand.NextRanged(150));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 50)
	{
		ShopItem@ s = addShopItem(this, "poppin shit", "$icon_firework$", "firework", "popping flying shit");
		AddRequirement(s.requirements, "coin", "", "Coins", 75 + rand.NextRanged(200));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 50)
	{
		ShopItem@ s = addShopItem(this, "firejob", "$icon_firejob$", "firejob", "fucking tie it to your neck and launch it ya cunt");
		AddRequirement(s.requirements, "coin", "", "Coins", 2500 + rand.NextRanged(4500));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 25)
	{
		ShopItem@ s = addShopItem(this, "fireboom", "$icon_fireboom$", "fireboom", "ok so now listen carefully my dear this is illegal as fUCK");
		AddRequirement(s.requirements, "coin", "", "Coins", 5000 + rand.NextRanged(20000));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 30)
	{
		ShopItem@ s = addShopItem(this, "bitch", "$icon_trader$", "trader", "huh");
		AddRequirement(s.requirements, "coin", "", "Coins", 500 + rand.NextRanged(2000));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 5)
	{
		ShopItem@ s = addShopItem(this, "guy", "$icon_hobo$", "hobo", "fuck off");
		AddRequirement(s.requirements, "coin", "", "Coins", 200 + rand.NextRanged(2000));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 30)
	{
		ShopItem@ s = addShopItem(this, "fart can", "$icon_methane$", "mat_methane-25", "smells like shit");
		AddRequirement(s.requirements, "coin", "", "Coins", 400 + rand.NextRanged(500));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 20)
	{
		ShopItem@ s = addShopItem(this, "nuke", "$icon_mininuke$", "mat_dirt-10", "get fucked");
		AddRequirement(s.requirements, "coin", "", "Coins", 1000 + rand.NextRanged(10000));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 20)
	{
		ShopItem@ s = addShopItem(this, "refined fart can", "$icon_fuel$", "mat_fuel-25", "smells worse than shit");
		AddRequirement(s.requirements, "coin", "", "Coins", 800 + rand.NextRanged(1000));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 20)
	{
		ShopItem@ s = addShopItem(this, "gae", "$icon_princess$", "princess", "found him hanging around the tannhauser gate");
		AddRequirement(s.requirements, "coin", "", "Coins", 69 + rand.NextRanged(10000));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 20)
	{
		{
			ShopItem@ s = addShopItem(this, "rocket prop whatever launcher", "$icon_rpc$", "rpc", "cut the shit");
			AddRequirement(s.requirements, "coin", "", "Coins", 250 + rand.NextRanged(2500));
			s.spawnNothing = true;
		}

		{
			ShopItem@ s = addShopItem(this, "rocket prop whatever rocket", "$icon_sawrocket$", "mat_sawrocket-1", "rocket for launcher");
			AddRequirement(s.requirements, "coin", "", "Coins", 50 + rand.NextRanged(550));
			s.spawnNothing = true;
		}
	}

	if (rand.NextRanged(100) < 25)
	{
		ShopItem@ s = addShopItem(this, "cat", "$icon_kitten$", "badger", "yea");
		AddRequirement(s.requirements, "coin", "", "Coins", 250 + rand.NextRanged(500));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 3)
	{
		ShopItem@ s = addShopItem(this, "some retarded shite", "$icon_oof$", "oof", "it's a rake or some shit now get the fuck out before i gouge your eyes out");
		AddRequirement(s.requirements, "coin", "", "Coins", 1 + rand.NextRanged(1000));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 40)
	{
		ShopItem@ s = addShopItem(this, "crackhead's chemistry kit", "$icon_minidruglab$", "minidruglab", "unstable pile of shit");
		AddRequirement(s.requirements, "coin", "", "Coins", 500 + rand.NextRanged(750));
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}

	if (rand.NextRanged(100) < 40)
	{
		ShopItem@ s = addShopItem(this, "boots that smell of piss", "$icon_rendeboots$", "rendeboots", "old pair of shoes i won from a chicken");
		AddRequirement(s.requirements, "coin", "", "Coins", 150 + rand.NextRanged(500));
		s.spawnNothing = true;
	}

	if (rand.NextRanged(100) < 50)
	{
		if (rand.NextRanged(100) < 10)
		{
			ShopItem@ s = addShopItem(this, "yellow mellow", "$icon_foof$", "foof", "pissssss");
			AddRequirement(s.requirements, "coin", "", "Coins", 1750 + rand.NextRanged(1000));
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 25)
		{
			ShopItem@ s = addShopItem(this, "fun", "$icon_domino$", "domino", "hoyl shit");
			AddRequirement(s.requirements, "coin", "", "Coins", 750 + rand.NextRanged(250));
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 25)
		{
			ShopItem@ s = addShopItem(this, "hard pill", "$fiks$", "fiks", "hard rocc");
			AddRequirement(s.requirements, "coin", "", "Coins", 500 + rand.NextRanged(250));
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 30)
		{
			ShopItem@ s = addShopItem(this, "speedo", "$icon_stim$", "stim", "speedy stuff you'll be fast like hedgehog");
			AddRequirement(s.requirements, "coin", "", "Coins", 1250 + rand.NextRanged(500));
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 40)
		{
			ShopItem@ s = addShopItem(this, "shite", "$icon_bobongo$", "bobongo", "stfu");
			AddRequirement(s.requirements, "coin", "", "Coins", 350 + rand.NextRanged(150));
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 40)
		{
			ShopItem@ s = addShopItem(this, "crack", "$icon_crak$", "crak", "gets shit done quick");
			AddRequirement(s.requirements, "coin", "", "Coins", 750 + rand.NextRanged(500));
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 25)
		{
			ShopItem@ s = addShopItem(this, "red stuff", "$icon_propesko$", "propesko", "had to do it to em");
			AddRequirement(s.requirements, "coin", "", "Coins", 1550 + rand.NextRanged(750));
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 25)
		{
			ShopItem@ s = addShopItem(this, "smokey", "$icon_fumes$", "fumes", "fly like an idiot");
			AddRequirement(s.requirements, "coin", "", "Coins", 1850 + rand.NextRanged(1250));
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 25)
		{
			ShopItem@ s = addShopItem(this, "venom", "$rippio$", "rippio", "rat poison");
			AddRequirement(s.requirements, "coin", "", "Coins", 1650 + rand.NextRanged(850));
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 30)
		{
			ShopItem@ s = addShopItem(this, "blue paper", "$bp_chemistry$", "bp_chemistry", "wipe ya ass");
			AddRequirement(s.requirements, "coin", "", "Coins", 3000 + rand.NextRanged(2500));
			s.spawnNothing = true;
		}
	}
	else if (rand.NextRanged(100) < 40)
	{

		if (rand.NextRanged(100) < 70)
		{
			u32 cost = getRandomCost(@rand, 300, 500);
			ShopItem@ s = addShopItem(this, "sell boof", "$COIN$", "coin-" + cost, "ill take this giggly shit off yer hands fer " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "boof", "Boof", 1);
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 50)
		{
			u32 cost = getRandomCost(@rand, 500, 700);
			ShopItem@ s = addShopItem(this, "sell crak", "$COIN$", "coin-" + cost, "ill take this cracker shit off yer hands fer " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "crak", "Crak", 1);
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 50)
		{
			u32 cost = getRandomCost(@rand, 1000, 1500);
			ShopItem@ s = addShopItem(this, "sell rippio", "$COIN$", "coin-" + cost, "ill take this fucker shit off yer hands fer " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "rippio", "Rippio", 1);
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 50)
		{
			u32 cost = getRandomCost(@rand, 500, 800);
			ShopItem@ s = addShopItem(this, "sell stim", "$COIN$", "coin-" + cost, "ill take this hedgehog shit off yer hands fer " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "stim", "Stim", 1);
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 50)
		{
			u32 cost = getRandomCost(@rand, 500, 750);
			ShopItem@ s = addShopItem(this, "sell paxilon", "$COIN$", "coin-" + cost, "ill take this sleepy shit off yer hands fer " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "paxilon", "Paxilon", 1);
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 50)
		{
			u32 cost = getRandomCost(@rand, 850, 1350);
			ShopItem@ s = addShopItem(this, "sell propesko", "$COIN$", "coin-" + cost, "ill take this red shit off yer hands fer " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "propesko", "Propesko", 1);
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 50)
		{
			u32 cost = getRandomCost(@rand, 1500, 1750);
			ShopItem@ s = addShopItem(this, "sell fumes", "$COIN$", "coin-" + cost, "Ill take this smelly shit off yer hands fer " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "fumes", "Fumes", 1);
			s.spawnNothing = true;
		}

		if (rand.NextRanged(100) < 50)
		{
			u32 cost = getRandomCost(@rand, 750, 1250);
			ShopItem@ s = addShopItem(this, "sell schisk", "$COIN$", "coin-" + cost, "ill take this schizo shit off yer hands fer " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "schisk", "Schisk", 1);
			s.spawnNothing = true;
		}
	}

	if (isServer())
	{
		this.server_setTeamNum(-1);
	}

	this.getCurrentScript().runFlags |= Script::tick_onscreen;
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 320.0f;

	this.set_f32("voice pitch", 0.75f);
	this.getSprite().PlaySound("drunk_fx4");
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	// reset shop colors
	addTokens(this);
}

void addTokens(CBlob@ this)
{
	int teamnum = this.getTeamNum();
	if (teamnum > 6) teamnum = 7;

	AddIconToken("$icon_fireboom$", "FireBoom.png", Vec2f(32, 32), 0, teamnum);
	AddIconToken("$icon_firejob$", "Firejob.png", Vec2f(16, 24), 0, teamnum);
	AddIconToken("$icon_firework$", "Firework.png", Vec2f(16, 24), 0, teamnum);
	AddIconToken("$icon_trader$", "TraderCoot.png", Vec2f(16, 16), 0, teamnum);
	AddIconToken("$icon_sawrocket$", "Material_SawRocket.png", Vec2f(8, 24), 0, teamnum);
}

int getRandomCost(Random@ random, int min, int max, int rounding = 10)
{
	return Maths::Round(f32(min + random.NextRanged(max - min)) / rounding) * rounding;
}

void onTick(CBlob@ this)
{
	if (!this.hasTag("dead"))
	{
		if (this.getHealth() <= 0)
		{
			this.Tag("dead");
			return;
		}

		uint time = getGameTime();
		if (time >= this.get_u32("nextTalk"))
		{
			this.set_u32("nextTalk", time + (30 * 10) + XORRandom(30 * 20));

			u32 lastDanger = this.get_u32("lastDanger");
			u16 dangerBlobNetID = this.get_u16("danger blob");

			bool danger = dangerBlobNetID > 0 && time < (lastDanger + (30 * 30));

			string text = "";
			if (danger)
			{
				text = textsDanger[XORRandom(textsDanger.size())];
				this.getSprite().PlaySound(soundsDanger[XORRandom(soundsDanger.size())], 0.75f, 0.75f);
			}
			else
			{
				if (time - this.get_u32("lastDanger") < 30 * 60)
				{
					text = textsWon[XORRandom(textsWon.size())];
				}
				else
				{
					text = textsIdle[XORRandom(textsIdle.size())];
					this.getSprite().PlaySound(soundsTalk[XORRandom(soundsTalk.size())], 0.75f, 1.00f);
				}
			}

			if (isServer())
			{
				CBitStream stream;
				stream.write_string(text);
				this.SendCommand(this.getCommandID("traderChat"), stream);
			}
		}

		CBlob@[] blobs;
		getMap().getBlobsInRadius(this.getPosition(), 96, @blobs);

		int index = -1;
		f32 s_dist = 900000.00f;
		u8 myTeam = this.getTeamNum();

		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			u8 team = b.getTeamNum();

			f32 dist = (b.getPosition() - this.getPosition()).LengthSquared();

			if (team != myTeam && dist < s_dist && b.hasTag("flesh") && !b.hasTag("dead"))
			{
				s_dist = dist;
				index = i;
			}
		}

		if (index != -1)
		{
			CBlob@ target = blobs[index];

			if (target !is null)
			{
				if (this.get_u32("nextThrow") < time)
				{
					if (XORRandom(100) < 2)
					{
						this.set_u32("nextTalk", 0);

						Vec2f dir = target.getPosition() - this.getPosition();
						this.SetFacingLeft(dir.x < 0);

						bool isAttached = this.isAttached();

						if (isClient())
						{
							if (isAttached) this.getSprite().PlaySound(soundsDanger[XORRandom(soundsDanger.size())], 0.75f, 0.75f);
						}

						if (isServer())
						{
							f32 dist = dir.Length();
							dir.Normalize();

							CBlob@ rock = server_CreateBlob("hobo_junk", this.getTeamNum(), this.getPosition());
							if (rock !is null)
							{
								rock.setVelocity((dir * 6.00f) + Vec2f(0, -3));
								this.set_u32("nextThrow", time + (isAttached ? 20 : (30 + XORRandom(90))));
							}
						}
					}
				}
			}
		}
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	this.set_bool("shop available", false);

	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 20, Vec2f(16, 16));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("traderChat"))
	{
		this.Chat(params.read_string());
	}
	else if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ChaChing.ogg", 1.00f, 0.75f);

		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item)) return;

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
			else if (name.findFirst("mat_") != -1)
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
				if (name == "oof" && isServer()) this.server_SetHealth(0.5f);

				if (blob is null || callerBlob is null) return;

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
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		server_DropCoins(this.getPosition(), XORRandom(1500));
	}
}

void onReload(CSprite@ this)
{
	this.getConsts().filename = "Hobo.png";
}

void onGib(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	if(!isClient()){return;}
	CParticle@ Gib1 = makeGibParticle("Entities/Special/WAR/Trading/TraderGibs.png", pos, vel + getRandomVelocity(90, hp, 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall");
	CParticle@ Gib2 = makeGibParticle("Entities/Special/WAR/Trading/TraderGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2, 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall");
	CParticle@ Gib3 = makeGibParticle("Entities/Special/WAR/Trading/TraderGibs.png", pos, vel + getRandomVelocity(90, hp, 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "/BodyGibFall");
}


bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead") || this.getPlayer() is null;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.set_u32("lastDanger", getGameTime());
	this.set_u16("danger blob", hitterBlob.getNetworkID());
	this.set_u32("nextTalk", this.get_u32("nextTalk") - (30 * damage * 13));

	if (customData == Hitters::suicide) damage = 0;

	return damage;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.set_u32("nextThrow", 0);
	this.set_u32("lastDanger", 0);
	if (attached !is null) this.set_u16("danger blob", attached.getNetworkID());
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead"))
	{
		if (!this.isAnimation("dead")) this.PlaySound("trader_death.ogg", 1.00f, 0.75f);

		this.SetAnimation("dead");

		if (blob.isOnGround())
		{
			this.SetFrameIndex(0);
		}
		else
		{
			this.SetFrameIndex(1);
		}

		return;
	}

	Vec2f pos = blob.getPosition();
	Vec2f aimpos = blob.getAimPos();
	bool ended = this.isAnimationEnded();

	bool danger = getGameTime() < (blob.get_u32("lastDanger") + (30 * 30));

	if ((blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right)) || (blob.isOnLadder() && (blob.isKeyPressed(key_up) || blob.isKeyPressed(key_down))))
	{
		if (danger)
		{
			this.SetAnimation("dangerwalk");
		}
		else
		{
			this.SetAnimation("walk");
		}
	}
	else if (ended)
	{
		this.SetAnimation("default");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null) return;
	if (this.hasTag("dead")) return;

	if (blob.getName() == "mat_mithrilenriched" && blob.getQuantity() > 5)
	{
		if (isServer() && !this.hasTag("transformed"))
		{
			CBlob@ blob = server_CreateBlob("hoob", this.getTeamNum(), this.getPosition());
			if (this.getPlayer() !is null) blob.server_SetPlayer(this.getPlayer());

			this.Tag("transformed");
			this.server_Die();
		}
		else
		{
			ParticleZombieLightning(this.getPosition());
		}
	}
}
