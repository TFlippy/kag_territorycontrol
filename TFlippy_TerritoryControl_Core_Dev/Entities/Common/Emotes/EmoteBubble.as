// Draw an emoticon

#include "EmotesCommon.as";

string[] sounds = 
{
	"vo_rip",		  					// skull = 0,  //0
	"vo_join",		 					// blueflag,
	"vo_lalala_2",		 				// note,
	"vo_look",		 					// right,
	"vo_yes",		 					// smile,
	"vo_join",		 					// redflag,
	"vo_strong",		  				// flex,
	"vo_look",		  					// down,
	"vo_no",		  					// frown,
	"vo_haha",		  					// troll,
	"vo_jerk",		  					// finger,		//10
	"vo_look",		  					// left,
	"vo_grrr",		  					// mad,
	"vo_archer",		  				// archer,
	"vo_water",		  					// sweat,
	"vo_look",		  					// up,
	"vo_haha",		  					// laugh,
	"vo_knight",		  				// knight,
	"vo_huh",		  					// question,
	"vo_yes",		  					// thumbsup,
	"vo_what",		  					// wat,		//20
	"vo_builder",		  				// builder,
	"vo_bad",		  					// disappoint,
	"vo_no",		  					// thumbsdown,
	"vo_uhh",		  					// derp,
	"vo_ladder",		  				// ladder,
	"vo_help",		  					// attn,
	"",		  							// pickup,
	"vo_uhh",		  					// cry,
	"vo_build",		  					// wall,
	"vo_hi",		  					// heart,		//30
	"vo_fire",		  					// fire,
	"vo_okay",		  					// check,
	"vo_okay",		  					// cool,
	"",		  							// dots,
	"",		  							// cog,
	"vo_what",							// think
	"vo_haha",							// laughcry,
	"vo_lag",							// derp,
	"vo_haha",							// awkward,
	"vo_idiot"							// smug,       //40
	"",									// love,
	"",									// kiss,
	"",									// pickup,
	"vo_what",							// raised,
	"",									// clap,
	"",		  							// 
	"",		  							// emotes_total,
	"",		  							// off	
};

void onInit(CBlob@ blob)
{
	blob.addCommandID("emote");

	CSprite@ sprite = blob.getSprite();
	blob.set_u8("emote", Emotes::off);
	blob.set_u32("emotetime", 0);
	//init emote layer
	CSpriteLayer@ emote = sprite.addSpriteLayer("bubble", "Entities/Common/Emotes/Emoticons.png", 32, 32, 0, 0);
	emote.SetIgnoreParentFacing(true);
	emote.SetFacingLeft(false);

	if (emote !is null)
	{
		emote.SetOffset(Vec2f(0, -sprite.getBlob().getRadius() * 1.5f - 16));
		emote.SetRelativeZ(100.0f);
		{
			Animation@ anim = emote.addAnimation("default", 0, true);

			for (int i = 0; i < Emotes::emotes_total; i++)
			{
				anim.AddFrame(i);
			}
		}
		emote.SetVisible(false);
		emote.SetHUD(true);
	}
	
	blob.set_u32("next_emote_sound", getGameTime());
}

void onTick(CBlob@ blob)
{
	blob.getCurrentScript().tickFrequency = 6;
	// if (blob.exists("emote"))	 will show skull if none existant
	if (!blob.getShape().isStatic())
	{
		CSprite@ sprite = blob.getSprite();
		CSpriteLayer@ emote = sprite.getSpriteLayer("bubble");

		const u8 index = blob.get_u8("emote");
		if (is_emote(blob, index) && !blob.hasTag("dead") && !blob.isInInventory())
		{
			blob.getCurrentScript().tickFrequency = 1;
			if (emote !is null)
			{
				emote.SetVisible(true);
				emote.animation.frame = index;

				emote.ResetTransform();

				CCamera@ camera = getCamera();
				if (camera !is null)
				{
					f32 angle = -camera.getRotation() + blob.getAngleDegrees();
					emote.RotateBy(-angle, Vec2f(0, 20));
				}
			}
		}
		else
		{
			emote.SetVisible(false);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("emote"))
	{
		u8 emote = params.read_u8();
		u32 emotetime = params.read_u32();
		
		if (this.get_f32("babbyed") > 0)
		{
			emote = 39;
		}
		
		this.set_u8("emote", emote);
		this.set_u32("emotetime", emotetime);
		
		if (emote < sounds.length && getGameTime() >= this.get_u32("next_emote_sound") && sounds[emote] != "")
		{
			if (isClient())
			{
				f32 pitch = this.getSexNum() == 0 ? 0.9f : 1.5f;
				if (this.exists("voice pitch")) pitch = this.get_f32("voice pitch");
				
				this.getSprite().PlaySound(sounds[emote], 0.80f, pitch);
			}
			
			this.set_u32("next_emote_sound", getGameTime() + 20);
		}
	}
}

void onClickedBubble(CBlob@ this, int index)
{
	set_emote(this, index);
}
