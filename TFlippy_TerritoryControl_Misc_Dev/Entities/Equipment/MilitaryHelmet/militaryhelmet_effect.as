#include "PixelOffsets.as"
#include "RunnerTextures.as"

void onInit(CBlob@ this)
{
	if(this.get_string("reload_script") != "militaryhelmet")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this) // the same as onInit, works one time when get equiped
{
    CSpriteLayer@ milhelmet = this.getSprite().addSpriteLayer("milhelmet", "MilitaryHelmet.png", 16, 16);
   
    if (milhelmet !is null)
    {
        milhelmet.addAnimation("default", 0, true);
		int[] frames = {0, 1, 2, 3};
		milhelmet.animation.AddFrames(frames);
		//milhelmet.SetAnimation(anim);
		
		milhelmet.SetVisible(true);
        milhelmet.SetRelativeZ(200);
        if(this.getSprite().isFacingLeft())
            milhelmet.SetFacingLeft(true);
    }
}
 
void onTick(CBlob@ this)
{
    if(this.get_string("reload_script") == "militaryhelmet")
    {
        UpdateScript(this);
        this.set_string("reload_script", "");
    }
 
    CSpriteLayer@ milhelmet = this.getSprite().getSpriteLayer("milhelmet");
   
    if (milhelmet !is null)
    {
        Vec2f headoffset(this.getSprite().getFrameWidth() / 2, -this.getSprite().getFrameHeight() / 2);
        Vec2f head_offset = getHeadOffset(this, -1, 0);
       
        headoffset += this.getSprite().getOffset();
        headoffset += Vec2f(-head_offset.x, head_offset.y);
        headoffset += Vec2f(0, -1);
        milhelmet.SetOffset(headoffset);
		
		milhelmet.SetFrameIndex(Maths::Floor(this.get_f32("mh_health") / 4.00f));
    }
   
    if(this.get_f32("mh_health") >= 20.0f)
    {
        this.getSprite().PlaySound("ricochet_" + XORRandom(3));
        this.set_string("equipment_head", "");
        this.set_f32("mh_health", 0.0f);
		if (milhelmet !is null)
		{
			this.getSprite().RemoveSpriteLayer("milhelmet");
		}
        this.RemoveScript("militaryhelmet_effect.as");
    }
    
	// print("helmet: "+this.get_f32("mh_health"));
}
 
void onDie(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ item = server_CreateBlob("militaryhelmet", this.getTeamNum(), this.getPosition());
		if (item !is null)
		{
			item.set_f32("health", this.get_f32("mh_health"));
			item.getSprite().SetFrameIndex(Maths::Floor(item.get_f32("mh_health") / 4.00f));
		}
	}
	
    this.RemoveScript("militaryhelmet_effect.as");
}