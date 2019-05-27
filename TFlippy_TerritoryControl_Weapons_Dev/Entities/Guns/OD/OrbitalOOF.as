//Orbital dawn
//Gears of war Hammer of Dawn type gun
const u16 ChargeTime = 120; 

void onInit(CBlob@ this)
{
    this.set_u16("ChargeRemaining",300);

    this.set_u16("CurrentCharge",0);
    this.set_bool("WarmingUp",true);
    this.set_bool("Firing",false);
    this.set_Vec2f("ChargeUpPos",Vec2f(0,0));
    this.getShape().SetGravityScale(0.0f);
    this.server_SetTimeToDie(5);
}

/*
void onInit(CSprite@ this)
{
    CSpriteLayer@ laserLeft = this.addSpriteLayer("leftLaser", "laser.png", 1, 4, 0, 0);
    if (laserLeft !is null)
    {
        laserLeft.SetRelativeZ(1200.0f);	
        laserLeft.SetVisible(true);
        laserLeft.SetColor(SColor(255,244, 161, 66));
    }

    CSpriteLayer@ laserRight = this.addSpriteLayer("rightLaser", "laser.png", 16, 16, 0, 0);
    if (laserRight !is null)
    {
        laserRight.SetRelativeZ(1200.0f);	
        laserRight.SetVisible(true);
    }

}*/


void onTick(CBlob@ this)
{
    CSprite@ sprite = this.getSprite();
    const bool warmingUp = this.get_bool("WarmingUp"); 
    const bool firing = this.get_bool("Firing");
    //NOT INSIDE CSPRITE THIS SINCE WE NEED TO RENDER AT ALL TIMES UNLESS YOU WANT IT TO CUT OUT
    if(warmingUp)
    {
        u16 charge = this.add_u16("CurrentCharge",1);

        if(charge > ChargeTime){return;}
        CSpriteLayer@ leftL = sprite.getSpriteLayer("leftLaser");
        CSpriteLayer@ rightL = sprite.getSpriteLayer("leftRight");
        CMap@ map = getMap();
        if (leftL !is null)
        {
            //leftL.TranslateBy(Vec2f(10,0));	
            u16 chargePos = 125 - charge;
            
            if(isClient())
            {
                Vec2f top = Vec2f(this.getPosition().x - chargePos, 0);
                Vec2f bottom = Vec2f(this.getPosition().x - chargePos, map.tilemapheight * 8);
                Vec2f pos;
                map.debugRaycasts = true;
                map.debugRaycastsMax = 100;
                map.rayCastSolid(top, bottom, pos);

                CCamera@ c = getCamera();

                leftL.ResetTransform();
                leftL.ScaleBy(Vec2f((pos.y*2)-c.getPosition().y,1.0f));
                leftL.SetOffset(Vec2f(chargePos,0));
                //leftL.TranslateBy(Vec2f(1.0f, pos.y/2));
                leftL.RotateBy(90.0f,Vec2f());
                
                leftL.SetVisible(true);   
            }

        }

    }

    
    
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
}