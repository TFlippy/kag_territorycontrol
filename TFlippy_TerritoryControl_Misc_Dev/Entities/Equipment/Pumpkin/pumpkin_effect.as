#include "PixelOffsets.as"
#include "RunnerTextures.as"

void onInit(CBlob@ this)
{
	if(this.get_string("reload_script") != "pumpkin")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this)
{
	CSpriteLayer@ pumpkinhead = this.getSprite().addSpriteLayer("pumpkinhead", "PumpkinHead.png", 16, 16);
	
	if (pumpkinhead !is null)
	{
		pumpkinhead.SetVisible(true);
		pumpkinhead.SetRelativeZ(2);
		if(this.getSprite().isFacingLeft())
			pumpkinhead.SetFacingLeft(true);
	}
}

void onTick(CBlob@ this)
{
    if(this.get_string("reload_script") == "pumpkin")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}
	
	CSpriteLayer@ pumpkinhead = this.getSprite().getSpriteLayer("pumpkinhead");
	
	if (pumpkinhead !is null)
	{
		Vec2f headoffset(this.getSprite().getFrameWidth() / 2, -this.getSprite().getFrameHeight() / 2);
		Vec2f head_offset = getHeadOffset(this, -1, 0);
		
		headoffset += this.getSprite().getOffset();
		headoffset += Vec2f(-head_offset.x, head_offset.y);
		headoffset += Vec2f(0, -2);
		pumpkinhead.SetOffset(headoffset);
	}
}