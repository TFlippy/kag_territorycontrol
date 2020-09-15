#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.Tag("sleeper");
	this.set_string("sleeper_name", "");
	this.set_bool("sleeper_sleeping", false);
	this.set_u16("sleeper_coins", 0);

	CSprite@ sprite = this.getSprite();
	
	CSpriteLayer@ zzz = sprite.addSpriteLayer("zzz", "Quarters.png", 8, 8);
	if (zzz !is null)
	{
		{
			zzz.addAnimation("default", 15, true);
			int[] frames = {96, 97, 98, 98, 99};
			zzz.animation.AddFrames(frames);
		}
		zzz.SetOffset(Vec2f(-3, -7));
		zzz.SetRelativeZ(5);
		zzz.SetLighting(false);
		zzz.SetVisible(false);
	}

	this.addCommandID("sleeper_set");
	this.addCommandID("removeAwootism");
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
	bool sleeping = this.get_bool("sleeper_sleeping");
	
	if (this.hasTag("dead")) 
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		sleeping = false;
		
		if (isServer())
		{
			server_DropCoins(this.getPosition(), this.get_u16("sleeper_coins"));
			this.set_u16("sleeper_coins", 0);
		}
	}
	else if (sleeping) SetKnocked(this, 35);

	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ layer = sprite.getSpriteLayer("zzz");
	if (layer !is null)
	{
		layer.SetVisible(sleeping);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("sleeper");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @bt)
{
	if (cmd == this.getCommandID("sleeper_set"))
	{
		bool sleeping = bt.read_bool();
		
		this.set_bool("sleeper_sleeping", sleeping);
		SetKnocked(this, 0);
		this.Untag("dazzled");

		/*if (isServer())
		{
			print("Sleeper sync: " + sleeping);
		}*/

		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSound("MigrantSleep.ogg");
			sprite.SetEmitSoundVolume(0.5f);
			sprite.SetEmitSoundPaused(!sleeping);
		}
	}
}