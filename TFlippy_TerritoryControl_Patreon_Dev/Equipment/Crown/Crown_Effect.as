#include "PixelOffsets.as"
#include "RunnerTextures.as"

void onInit(CBlob@ this)
{
	if(this.get_string("reload_script") != "crown") UpdateScript(this);
}

void UpdateScript(CBlob@ this) // the same as onInit, works one time when get equiped
{
    CSpriteLayer@ crown = this.getSprite().addSpriteLayer("crown", "Crown.png", 16, 16);
   
    if (crown !is null)
    {
		crown.SetVisible(true);
        crown.SetRelativeZ(200);
        if (this.getSprite().isFacingLeft()) 
		{
			crown.SetFacingLeft(true);
		}
    }
}
 
void onTick(CBlob@ this)
{
    if(this.get_string("reload_script") == "crown")
    {
        UpdateScript(this);
        this.set_string("reload_script", "");
    }
 
    CSpriteLayer@ crown = this.getSprite().getSpriteLayer("crown");
    if (crown !is null)
    {
        Vec2f headoffset(this.getSprite().getFrameWidth() / 2, -this.getSprite().getFrameHeight() / 2);
        Vec2f head_offset = getHeadOffset(this, -1, 0);
       
        headoffset += this.getSprite().getOffset();
        headoffset += Vec2f(-head_offset.x, head_offset.y);
        headoffset += Vec2f(0, -1);
        crown.SetOffset(headoffset);
    }
}
 
void onDie(CBlob@ this)
{
    this.RemoveScript("Crown_Effect.as");
}