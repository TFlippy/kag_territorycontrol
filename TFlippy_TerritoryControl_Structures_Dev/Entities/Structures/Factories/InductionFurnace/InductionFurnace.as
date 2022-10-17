#include "MakeMat.as";

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-50); //-60 instead of -50 so sprite layers are behind ladders
}

const string[] matNames = { 
	"mat_copper",
	"mat_iron",
	"mat_gold",
	"mat_wood",
    "mat_ironingot"
};

const string[] matNamesResult = { 
	"mat_copperingot",
	"mat_ironingot",
	"mat_goldingot",
	"mat_coal",
    "mat_steelingot"
};

const int[] matRatio = { 
	4,
	4,
	10,
	4,
    2
};

const int[] oilRatio = {
	0,
	0,
	0,
	0,
	2
};

const int[] matResult = { 
	1,
	1,
	1,
	1,
    1
};

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
    
    this.getCurrentScript().tickFrequency = 60;
    
    this.addCommandID("make_sound");
    
    CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.SetEmitSound("InductionFurnace_Loop.ogg");
		sprite.SetEmitSoundVolume(0.90f);
		sprite.SetEmitSoundSpeed(1.0f);
		sprite.SetEmitSoundPaused(true);
	}
}

void onTick(CBlob@ this)
{
    if (isServer())
	{
        f32 ticks = 240.0 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
        int bulk = 5;
        while(ticks <= 30.0){
            bulk *= 2;
            ticks *= 2.0f;
        }
        
        this.getCurrentScript().tickFrequency = ticks;
        
        bool made = false;
        
        for (int i = 0; i < matNames.length; i++)
        {
            int b = bulk;
            int r = 0;
            while(b >= 1){
                b--;
                
                if (this.hasBlob(matNames[i], matRatio[i]) && (oilRatio[i] == 0 || this.hasBlob("mat_oil", oilRatio[i])))
                {
                    this.TakeBlob(matNames[i], matRatio[i]);
                    if (oilRatio[i] > 0) this.TakeBlob("mat_oil", oilRatio[i]);
                    r += 1;
                }
            }
            
            if(r > 0){
                CBlob @mat = server_CreateBlob(matNamesResult[i], -1, this.getPosition());
                mat.server_SetQuantity(matResult[i]*r);
                mat.Tag("justmade");
                made = true;
            }
        }
        
        if(made)this.SendCommand(this.getCommandID("make_sound"));
    }
    
    if(isClient()){
        bool making = false;
        
        for (int i = 0; i < matNames.length; i++)
        {
            if (this.hasBlob(matNames[i], matRatio[i]) && (oilRatio[i] == 0 || this.hasBlob("mat_oil", oilRatio[i])))
            {
                making = true;
                break;
            }
        }
        
        if(making){
            this.getSprite().SetAnimation("active");
            this.getSprite().SetEmitSoundPaused(false);
        } else {
            this.getSprite().SetAnimation("default");
            this.getSprite().SetEmitSoundPaused(true);
        }
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params){
	if (cmd == this.getCommandID("make_sound"))
	{
        if (isClient())
        {
            this.getSprite().PlaySound("ProduceSound.ogg");
            this.getSprite().PlaySound("BombMake.ogg");
        }
    }
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob is null)return;

	if(blob.hasTag("justmade"))
	{
		blob.Untag("justmade");
		return;
	}
	
	if(!blob.isAttached() && blob.hasTag("material"))
	{
        string config = blob.getName();
        if (matNames.find(config) >= 0 || config == "mat_oil")
        {
            if (isServer()) this.server_PutInInventory(blob);
            if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
        }
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob !is null && forBlob.isOverlapping(this);
}