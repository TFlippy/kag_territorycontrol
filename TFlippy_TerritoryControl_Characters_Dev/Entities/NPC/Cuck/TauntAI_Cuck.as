/**
 * Common bot "taunt engine"
 *
 * Attach to blob
 */


#include "EmotesCommon.as"

/**
 * Defines the possible taunt actions
 */
enum TauntActionIndex
{

	no_action = 0,

	hurt_enemy,
	kill_enemy,
	get_hurt,

	chat,
	talk,
	dead
}

/**
 * A struct holding information about a bot's personality
 */
class BotPersonality
{

	/**
	 * name of the personality
	 */
	string name;

	/**
	 * chance of a taunt every event
	 */
	f32 tauntchance;

	/**
	 * the emote "strings" that the bot will use
	 * for certain events
	 */
	u8[] hurt_enemy_emotes;
	u8[] kill_enemy_emotes;
	u8[] get_hurt_emotes;
	u8[] talk_emotes;

	/**
	 * A list of taunts that the bot will use
	 * when it's winning or camping
	 */
	string[] taunts;

	/**
	 * A list of whines that the bot will use
	 * when its dead
	 */
	string[] whines;
	
	
	
	string[] talks;

	/**
	 * The number of ticks taken per character of
	 * taunt - used to emulate type lag
	 */
	u8 typespeed;

	/**
	 * Used to tune how talkative each personality is
	 */
	f32 talkchance;

	BotPersonality() {}

};

void onInit(CBlob@ this)
{
	//this.getCurrentScript().removeIfTag = "dead";

	this.set_u8("taunt action", no_action);
	this.set_u8("taunt delay", 0);

	/*BotPersonality[] personalities = {

	};*/

	//default personality
	BotPersonality b;
	b.name = "default";

	//emotes
	b.hurt_enemy_emotes.push_back(Emotes::thumbsdown);
	b.hurt_enemy_emotes.push_back(Emotes::mad);
	b.hurt_enemy_emotes.push_back(Emotes::finger);
	b.hurt_enemy_emotes.push_back(Emotes::disappoint);
	b.hurt_enemy_emotes.push_back(Emotes::skull);

	b.kill_enemy_emotes.push_back(Emotes::thumbsdown);
	b.kill_enemy_emotes.push_back(Emotes::skull);
	b.kill_enemy_emotes.push_back(Emotes::finger);
	b.kill_enemy_emotes.push_back(Emotes::fire);
	b.kill_enemy_emotes.push_back(Emotes::derp);
	b.kill_enemy_emotes.push_back(Emotes::mad);

	b.get_hurt_emotes.push_back(Emotes::mad);
	b.get_hurt_emotes.push_back(Emotes::disappoint);
	b.get_hurt_emotes.push_back(Emotes::finger);
	
	b.talk_emotes.push_back(Emotes::mad);
	b.talk_emotes.push_back(Emotes::disappoint);
	b.talk_emotes.push_back(Emotes::derp);

	//chats
	{
		string[] temp = { 
						  "i see you",
						  "break a neck",
						  "oof",
						  "i'm coming for you",
						  "i'm looking at you",
						  "i'm here",
						  "hello",
						  "i'll put you in a box"
		                };
		b.taunts = temp;
	}
	{
		string[] temp = { 
						  "i have the moral high ground",
						  "fling yourself",
						  "help yourself",
						  "i have the high ground"
		                };
		b.whines = temp;
	}
	{
		string[] temp = { 
						  "death is the only cure to alcoholism",
						  "exercise is good for your health",
						  "a three legged puppy isn't a happy puppy",
						  "all you need in order to reach the end of the rainbow is a pill of bobomax",
						  "with good beating comes good madness",
						  "depression is eternal love from a rose",
						  "the two things you need in order to have a dream is magic and special education",
						  "those who refuse self-destruction also refuse immortality",
						  "only when you seek the positive effects of vegetables, will you actually see death",
						  "being a lawyer is surprisingly similar to wearing a straightjacket",
						  "you don't need a clear hand in order to destroy democracy",
						  "never say no to save yourself",
						  "if you are believing in confusion you are obviously not happy"
		                };
		b.talks = temp;
	}
	
	//meta
	b.tauntchance = 0.4f;

	b.typespeed = 2;
	b.talkchance = 0.65f;

	this.set("taunt personality", b);  //personalities[(this.getNetworkID() % personalities.length)] );
}

void onTick(CBlob@ this)
{
	if (this.getPlayer() is null)
	{
		UpdateAction(this);
		
		if (this.get_u8("taunt action") == no_action)
		{
			if (this.get_u32("next talk") < getGameTime() && XORRandom(100) < 5)
			{
				if (hasFriends(this))
				{
					PromptAction(this, talk, XORRandom(5));
					this.set_u32("next talk", getGameTime() + 100 + XORRandom(1000));
				}
			}
		}
	}
	else this.getCurrentScript().runFlags |= Script::remove_after_this; //not needed
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob.hasTag("player") && !this.hasTag("dead"))
		PromptAction(this, get_hurt, 5 + XORRandom(5));

	return damage;
}

bool hasFriends(CBlob@ this)
{
	CBlob@[] blobs;
	getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 20.0f, @blobs);
	
	if (blobs.length > 0)
	{
		for (u32 i = 0; i < blobs.length; i++)
		{
			if (blobs[i] !is this)
			{
				return true;
			}
		}
	}
	
	return false;
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob.hasTag("player") && !hitBlob.hasTag("dead"))
		PromptAction(this, hurt_enemy, 5 + XORRandom(5));
}

void PromptAction(CBlob@ this, u8 action, u8 delay)
{
	this.set_u8("taunt action", action);
	this.Sync("taunt action", true);

	this.set_u8("taunt delay", delay);
	this.Sync("taunt delay", true);
}

void UpdateAction(CBlob@ this)
{
	bool isdead = this.hasTag("dead");

	u8 action = this.get_u8("taunt action");
	if (action == no_action)
	{
		if (isdead)
		{
			DoAction(this, dead);
		}

		return;
	}

	u8 delay = this.get_u8("taunt delay");
	if (delay > 0)
	{	
		delay--;
		this.set_u8("taunt delay", delay);
	}
	else
	{
		this.set_u8("taunt action", no_action);
		DoAction(this, action);

		if (this.get_u8("taunt action") == no_action && isdead)
			this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

void DoAction(CBlob@ this, u8 action)
{
	BotPersonality@ b;
	if (!this.get("taunt personality", @b)) return;

	bool taunt = (XORRandom(1000) / 1000.0f) < b.tauntchance;
	bool chatter = (XORRandom(1000) / 1000.0f) < b.talkchance;

	switch (action)
	{
		case hurt_enemy:
			if (taunt) ChatOrEmote(this, chatter, b.hurt_enemy_emotes, b.taunts, b);
			this.set_u32("next talk", getGameTime() + 1000 + XORRandom(1000));
			break;

		case kill_enemy:
			ChatOrEmote(this, chatter, b.kill_enemy_emotes, b.taunts, b);
			this.set_u32("next talk", getGameTime() + 100 + XORRandom(1000));
			break;

		case get_hurt:
			if (taunt) ChatOrEmote(this, chatter, b.get_hurt_emotes, b.whines, b);
			this.set_u32("next talk", getGameTime() + 500 + XORRandom(1000));
			break;

		case dead:
			ChatOrEmote(this, true, b.get_hurt_emotes, b.whines, b);
			break;

		case talk:
			ChatOrEmote(this, chatter, b.talk_emotes, b.talks, b);
			break;
			
		case chat:
			this.Chat(this.get_string("taunt chat"));
			set_emote(this, Emotes::off);
			break;
	}

}

void ChatOrEmote(CBlob@ this, bool chatter, const u8[]& emotes, const string[]& chats, BotPersonality@ b = null)
{
	if (!chatter)
	{
		set_emote(this, emotes[XORRandom(emotes.length)]);
	}
	else
	{
		if (b is null)
		{
			this.Chat(chats[XORRandom(chats.length)]);
			set_emote(this, Emotes::off);
		}
		else
		{
			set_emote(this, Emotes::dots);

			string chat_text = chats[XORRandom(chats.length)];
			this.set_string("taunt chat", chat_text);

			u8 count = (Maths::Sqrt(chat_text.length) + 1) * b.typespeed;

			//print("text: \""+chat_text+"\" count: "+(count));

			PromptAction(this, chat, count);

		}
	}
}



