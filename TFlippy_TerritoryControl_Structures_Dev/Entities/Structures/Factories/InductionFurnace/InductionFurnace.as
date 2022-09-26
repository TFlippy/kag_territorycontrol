#include "MakeMat.as";

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-50); //-60 instead of -50 so sprite layers are behind ladders
}

const string[] matNames = { 
	"mat_wood",
	"mat_copper",
	"mat_iron",
	"mat_gold",
	"mat_ironingot"
};

const string[] matNamesResult = { 
	"mat_coal",
	"mat_copperingot",
	"mat_ironingot",
	"mat_goldingot",
	"mat_steelingot"
};

const int[] matRatio = { 
	5,
	5,
	5,
	25,
	3
};

const int[] matResult = { 
	2,
	2,
	2,
	4,
	2
};

const int[] coalRatio = {
	0,
	0,
	0,
	0,
	3
};

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 240;

	this.Tag("builder always hit");
	this.set_u16("bulk_modifier", 2);

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.SetEmitSound("InductionFurnace_Loop.ogg");
		sprite.SetEmitSoundVolume(0.90f);
		sprite.SetEmitSoundSpeed(1.0f);
		sprite.SetEmitSoundPaused(false);
	}
}

void onTick(CBlob@ this)
{
	f32 gyro = this.get_f32("gyromat_acceleration");
	if (gyro > 6) // if gyro > 600% then start bulk production
	{
		gyro /= 2;
		this.set_u16("bulk_modifier", gyro*2);
	}
	else this.set_u16("bulk_modifier", 2);

	this.getCurrentScript().tickFrequency = Maths::Max(240/gyro, 15);

	CInventory@ inv = this.getInventory();
	if (inv !is null)
	{
		for (u8 i = 0; i < 5; i++)
		{
			u8 bulk = Maths::Min(inv.getCount(matNames[i])/matRatio[i], this.get_u16("bulk_modifier") - (i == 3 ? 1 : 0)); // because gold has dif matResult
			if (bulk > 0)
			{
				if (coalRatio[i] > 0) bulk = Maths::Min(inv.getCount("mat_coal")/coalRatio[i], bulk);
				if (this.hasBlob(matNames[i], matRatio[i]*bulk) && (coalRatio[i] == 0 || this.hasBlob("mat_coal", coalRatio[i]*bulk)))
				{
					if (isServer())
					{
						CBlob @mat = server_CreateBlob(matNamesResult[i], -1, this.getPosition());
						mat.server_SetQuantity(matResult[i]*bulk);
						mat.Tag("justmade");
						this.TakeBlob(matNames[i], matRatio[i]*bulk);
						if (coalRatio[i] > 0) this.TakeBlob("mat_coal", coalRatio[i]*bulk);
					}

					if (isClient())
					{
						this.getSprite().PlaySound("ProduceSound.ogg");
						this.getSprite().PlaySound("BombMake.ogg");
					}
				}
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if(blob.hasTag("justmade")){
		blob.Untag("justmade");
		return;
	}

	for(int i = 0;i < 5; i += 1)
	if (!blob.isAttached() && blob.hasTag("material") && blob.getName() == matNames[i])
	{
		if (isServer()) this.server_PutInInventory(blob);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}

	if (!blob.isAttached() && blob.hasTag("material") && blob.getName() == "mat_coal")
	{
		if (isServer()) this.server_PutInInventory(blob);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	// return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
	return forBlob !is null && forBlob.isOverlapping(this);
}