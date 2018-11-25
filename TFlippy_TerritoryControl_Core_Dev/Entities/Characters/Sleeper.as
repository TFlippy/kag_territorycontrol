#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.Tag("sleeper");
	this.set_string("sleeper_name", "");
	this.set_bool("sleeper_sleeping", false);
	this.set_u16("sleeper_coins", 0);

	CSprite@ sprite = this.getSprite();
	
	// sprite.SetEmitSound("MigrantSleep.ogg");
	// sprite.SetEmitSoundPaused(true);
	// sprite.SetEmitSoundVolume(0.5f);
	
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
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
	bool sleeping = this.get_bool("sleeper_sleeping");
	
	if (this.hasTag("dead")) 
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		sleeping = false;
		
		if (getNet().isServer())
		{
			server_DropCoins(this.getPosition(), this.get_u16("sleeper_coins"));
			this.set_u16("sleeper_coins", 0);
		}
	}
	else if(this.getPlayer() !is null && this.getPlayer().hasTag("awootism") && this.hasScript('AwooootismSpread.as') == false) 
	{
		this.AddScript('AwooootismSpread.as');
	}
	else if (sleeping) SetKnocked(this, 35);

	
	CSprite@ sprite = this.getSprite();
	// sprite.SetEmitSoundPaused(!sleeping);
	
	CSpriteLayer@ layer = sprite.getSpriteLayer("zzz");
	if (layer !is null)
	{
		layer.SetVisible(sleeping);
	}
	
	// if (sleeping) print(this.getConfig() + " is sleeping");
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
		this.set_u8("knocked", 0);
		this.Untag("dazzled");
		
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSound("MigrantSleep.ogg");
		sprite.SetEmitSoundPaused(true);
		sprite.SetEmitSoundVolume(0.5f);
		sprite.SetEmitSoundPaused(!sleeping);
		
		print("Sleeper sync: " + sleeping);
	}
}

// void onSetPlayer(CBlob@ this, CPlayer@ player)
// {
	// if (player !is null)
	// {
		// this.Untag("sleeper");
		// SetKnocked(this, 0);
	// }
// }

