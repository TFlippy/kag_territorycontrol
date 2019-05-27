//Orbital dawn
//Gears of war Hammer of Dawn type gun
const u16 ChargeTime = 120; 

void onInit(CBlob@ this)
{
    this.set_u16("ChargeRemaining",300);

    this.set_u16("CurrentCharge",0);
    this.set_bool("WarmingUp",false);
    this.set_bool("Firing",false);
    this.set_Vec2f("ChargeUpPos",Vec2f(0,0));

    this.addCommandID("StartCharge");
    this.set_f32("scope_zoom", 0.15f);
    this.getShape().SetRotationsAllowed(true);
    this.Tag("no shitty rotation reset");//thank
    //CParticle@[] temp;
    //this.set("ParticleList",temp);
    //TODO ADD FLAG FOR ATTACH
}


void onTick(CBlob@ this)
{
    const bool warmingUp = this.get_bool("WarmingUp"); 
    const bool firing = this.get_bool("Firing");

    AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
    if(point is null){return;}

    CBlob@ holder = point.getOccupied();

    if(holder !is null && this !is null)
    {
        UpdateAngle(this,holder,point);
        if(!warmingUp && !firing)
        {
            if(holder.isKeyPressed(key_action1) || holder.isKeyJustPressed(key_action1))
            {
                if(getLocalPlayerBlob() !is null && holder is getLocalPlayerBlob())
                {
                    CBitStream@ bs = CBitStream();
                    CControls@ control = getControls();
                    if(control is null) {return;}

                    bs.write_Vec2f(control.getMouseWorldPos());
                    this.SendCommand(this.getCommandID("StartCharge"),bs);
                    this.set_bool("WarmingUp",true);
                }
              
            }	   
        }

        if(warmingUp && !firing)
        {
            /*u16 currentCharge = this.add_u16("CurrentCharge",1);
            Vec2f aimPos = this.get_Vec2f("ChargeUpPos");

            CSprite@ sprite = this.getSprite();
            if(sprite is null) {return;}

            CSpriteLayer@ leftL = sprite.getSpriteLayer("leftLaser");
            CSpriteLayer@ rightL = sprite.getSpriteLayer("leftRight");
            if (leftL !is null)
            {
                leftL.ResetTransform();
                leftL.TranslateBy(-(this.getPosition() - aimPos));	
                
                leftL.SetVisible(true);
            }
            if(rightL !is null)
            {

            }*/
            
            
        }
    }
    else if(holder is null)
    {
        //Time to end the charge/fire
    }
    
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("StartCharge"))
	{
        Vec2f pos = params.read_Vec2f();
        this.set_bool("WarmingUp",true);
		this.set_Vec2f("ChargeUpPos",pos);
        if(isServer())
        {
            print("blob made");
            server_CreateBlob("orbitaloof",0,pos);
        }
	}
}

void UpdateAngle(CBlob@ this,CBlob@ holder,AttachmentPoint@ point)
{
	Vec2f aimpos=holder.getAimPos();
	Vec2f pos=holder.getPosition();
	
	Vec2f aim_vec =(pos - aimpos);
	aim_vec.Normalize();
	
	f32 mouseAngle=aim_vec.getAngleDegrees();
    if(!holder.isFacingLeft()) mouseAngle += 180;

	this.setAngleDegrees(-mouseAngle);
	
	// print("" + this.getAngleDegrees());
	
	// this.SetFacingLeft(holder.isFacingLeft());
	
	point.offset.x=0 +(aim_vec.x*2*(holder.isFacingLeft() ? 1.0f : -1.0f));
	point.offset.y=-(aim_vec.y);
}