#include "RunnerCommon.as"
#include "Help.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "Requirements.as";
#include "MakeDustParticle.as";

const string[] titles = 
{ 
	"Radical",
	"Anarchist",
	"Extremist",
	"Total",
	"Rebel",
	"Rambler",
	"Rover",
	"Pummeler"
};

const string[] firstnames = 
{ 
	"Kev",
	"Eugh",
	"Lar",
	"Mac",
	"Jon",
	"Stev",
	"Syd",
	"Jet",
	"Nel",
	"Bob",
	"Har",
	"Bar",
	"Jer",
	"Gar"
};

const string[] surnames = 
{ 
	"Gorilla",
	"Killslayer",
	"Rocket",
	"Deathkill",
	"Criminal",
	"Murderer",
	"Snotter",
	"Torpedo",
	"Defiler",
	"Killer",
	"Eliminator",
	"Boi"
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
	"ima spit down yer throat",
	"c'mere here ya shit",
	"oi ya shite",
	"so wanna fight huh?",
	"gonna get ya weenie 'lil shitter",
	"damn right innit yeh?",
	"ill bash ye fookin 'ead in i sware on me mum"
};

const string[] textsDanger = 
{ 
	"ya weenie 'lil shit",
	"i'll get ya asshole",
	"gonna get ya weenie 'lil shitter",
	"so wanna fight huh?",
	"i'm gonna spit down yer throat",
	"c'mere here ya shit",
	"ill bash ye fookin ead in i sware on me mum",
	"ya'll get turned into a tiny box",
	"come at me"
};

const string[] textsWon = 
{
	"gonna tear ya in half shitbag",
	"ay give me ya stuff",
	"aye, we did fuck him up",
	"yar",
	"arrrr",
	"*gurgle*",
	"ayy shit!",
	"damn right innit?",
	"wanna fight ya cunt?",
	"sit on ya arse"
};

void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());
	string name = titles[rand.NextRanged(titles.length)] + " " + firstnames[rand.NextRanged(firstnames.length)] + " the " + surnames[rand.NextRanged(surnames.length)];
	this.set_string("trader name", name);
	
	this.getShape().SetRotationsAllowed(false);
	this.set_f32("gib health", -2.0f);
	this.Tag("flesh");
	this.Tag("migrant");
	this.Tag("human");
	this.getBrain().server_SetActive(true);

	this.set_u32("nextTalk", getGameTime() + XORRandom(60));
	
	this.set_u32("nextAttack", 0);
	this.set_u32("nextJumpStomp", 0);
	
	this.set_f32("minDistance", 8);
	this.set_f32("chaseDistance", 300);
	this.set_f32("maxDistance", 600);
	
	this.set_f32("inaccuracy", 0.01f);
	this.set_u8("reactionTime", 20);
	this.set_u8("attackDelay", 0);
	
	this.addCommandID("traderChat");
	this.set_u32("lastDanger", 0);
	
	if (getNet().isServer())
	{
		this.server_setTeamNum(-1);
	}

	this.getSprite().addSpriteLayer("isOnScreen", "NoTexture.png", 0, 0);
}

void onTick(CBlob@ this)
{
	if (!this.hasTag("dead"))
	{	
		bool client = isClient();
		bool server = isServer();		
	
		if (this.getHealth() <= 0)
		{
			this.Tag("dead");				
			return;
		}

		if(client)
		{
			if (!this.getSprite().getSpriteLayer("isOnScreen").isOnScreen())
			{
				return;
			}
		}
		
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 2.00f;
			moveVars.jumpFactor *= 4.50f;
		}
		
		uint time = getGameTime();
		if (this.getPlayer() is null && time >= this.get_u32("nextTalk"))
		{
			this.set_u32("nextTalk", time + (30 * 5) + XORRandom(30 * 10));
			
			u32 lastDanger = this.get_u32("lastDanger");
			u16 dangerBlobNetID = this.get_u16("danger blob");
			
			bool danger = dangerBlobNetID > 0 && time < (lastDanger + (30 * 30));
			
			string text = "";
			if (danger)
			{
				text = textsDanger[XORRandom(textsDanger.length())];
				this.getSprite().PlaySound(soundsDanger[XORRandom(soundsDanger.length())], 0.75f, 0.75f);
			}
			else
			{
				if (time - this.get_u32("lastDanger") < 30 * 60)
				{
					text = textsWon[XORRandom(textsWon.length())];
				}
				else
				{
					text = textsIdle[XORRandom(textsIdle.length())];
					this.getSprite().PlaySound(soundsTalk[XORRandom(soundsTalk.length())], 0.75f, 1.00f);
				}
			}

			if (getNet().isServer())
			{
				CBitStream stream;
				stream.write_string(text);
				this.SendCommand(this.getCommandID("traderChat"), stream);
			}
		}
		
		if (this.isOnGround())
		{
			if ((time % 10 == 0) && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)))
			{
				Stomp(this, 4, 1.00f);
			}
			else if (!this.wasOnGround() && time > this.get_u32("nextJumpStomp"))
			{
				Stomp(this, 20, 4.00f);
				this.set_u32("nextJumpStomp", getGameTime() + 15);
			}
		}
		
		if (this.isKeyPressed(key_action1) && getGameTime() > this.get_u32("next attack"))
		{
			Vec2f dir = this.getAimPos() - this.getPosition();
			dir.Normalize();
			
			CBlob@ carried = this.getCarriedBlob();
			if (carried is null)
			{
				CBlob@ blob = getMap().getBlobAtPosition(this.getAimPos());
				if (blob !is null && blob !is this && !blob.hasTag("dead") && blob.hasTag("human")) 
				{
					if (client)
					{
						this.getSprite().PlaySound("TraderScream.ogg", 0.8f, this.getSexNum() == 0 ? 1.0f : 2.0f);
					}
				
					if (server)
					{
						this.server_Pickup(blob);
					}
				}
			}
			else if (carried !is null)
			{
				if (carried.getConfig() != "hoobballer")
				{					
					if (client)
					{
						this.getSprite().PlaySound("Pus_Attack_2", 1.00f, 0.80f);
						carried.getSprite().Gib();
					}
					
					if (server)
					{
						CBlob@ baller = server_CreateBlob("hoobballer", carried.getTeamNum(), carried.getPosition());
						this.server_Pickup(baller);
						carried.server_Die();
					}
				}
				else
				{
					if (client)
					{
						this.getSprite().PlaySound("nightstick_hit2", 1.00f, 0.90f);
					}
				
					if (server)
					{
						this.DropCarried();
					}
					
					Vec2f dir = this.getAimPos() - this.getPosition();
					dir.Normalize();
					
					carried.setVelocity(dir * 10.00f);
				}
			}
			
			this.set_u32("next attack", getGameTime() + 30);
		}
	}
}

void Stomp(CBlob@ this, int count, f32 magnitude)
{
	bool client = isClient();
	bool server = isServer();
	CMap@ map = getMap();
	
	Vec2f worldPoint = this.getPosition() + Vec2f(0, 24);
	
	for (int i = 0; i < count; i++)
	{
		Vec2f pos = worldPoint + getRandomVelocity(0, XORRandom(32), 90);	
		
		if (client && XORRandom(100) < 50)
		{
			MakeDustParticle(pos, "dust2.png");
		}
		
		if (server)
		{
			map.server_DestroyTile(pos, 1);
		}
	}
	
	if (client)
	{
		this.getSprite().PlaySound("FallBig" + (XORRandom(5) + 1), 1.00f, 1.00f);
		ShakeScreen(100.0f, 30.00f, this.getPosition());
	}
	
	if (server)
	{
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(worldPoint, 24, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ hitBlob = blobsInRadius[i];
				if (hitBlob !is null && hitBlob !is this && hitBlob !is this.getCarriedBlob())
				{
					this.server_Hit(hitBlob, worldPoint, this.getVelocity(), 5.00f, Hitters::crush, true);
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("traderChat"))
	{
		this.Chat(params.read_string());
	}
}

void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		server_DropCoins(this.getPosition(), XORRandom(1500));
	}
}

void onReload(CSprite@ this)
{
	this.getConsts().filename = "Hoob.png";
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

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	if (this.getHealth() < 0)
	{
		this.getSprite().Gib();
		this.server_Die();
		return;
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case HittersTC::radiation:
			return 0;
			break;
	}

	if (!this.hasTag("dead"))
	{
		if (isClient())
		{
			if (getGameTime() > this.get_u32("next sound") - 130)
			{
				this.getSprite().PlaySound("Cuck_Pain_" + XORRandom(3), 1, 0.8f);
				this.set_u32("next sound", getGameTime() + 150);
			}
		}
		
		if (isServer())
		{
			CBrain@ brain = this.getBrain();
			if (brain !is null && hitterBlob !is null)
			{
				if (hitterBlob.getTeamNum() != this.getTeamNum()) brain.SetTarget(hitterBlob);
			}
		}
	}
		
	return damage;
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if(!this.getSpriteLayer("isOnScreen").isOnScreen())
	{
		return;
	}
	
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