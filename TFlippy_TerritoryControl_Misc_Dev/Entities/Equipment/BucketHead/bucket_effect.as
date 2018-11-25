#include "PixelOffsets.as"
#include "RunnerTextures.as"

void onInit(CBlob@ this)
{
	if(this.get_string("reload_script") != "bucket")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this) // the same as onInit, works one time when get equiped
{
	CSpriteLayer@ buckethead = this.getSprite().addSpriteLayer("buckethead", "BucketHead.png", 16, 16);
	

	if (buckethead !is null)
	{
		buckethead.SetVisible(true);
		buckethead.SetRelativeZ(2);
		if(this.getSprite().isFacingLeft())
			buckethead.SetFacingLeft(true);
	}
}

void onTick(CBlob@ this)
{
    if(this.get_string("reload_script") == "bucket")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}

	CSpriteLayer@ buckethead = this.getSprite().getSpriteLayer("buckethead");
	
	if (buckethead !is null)
	{
		Vec2f headoffset(this.getSprite().getFrameWidth() / 2, -this.getSprite().getFrameHeight() / 2);
		Vec2f head_offset = getHeadOffset(this, -1, 0);
		
		headoffset += this.getSprite().getOffset();
		headoffset += Vec2f(-head_offset.x, head_offset.y);
		headoffset += Vec2f(0, -3);
		buckethead.SetOffset(headoffset);
	}
}