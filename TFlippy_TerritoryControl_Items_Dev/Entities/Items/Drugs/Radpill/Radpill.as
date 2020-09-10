#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.addCommandID("consume");
	this.Tag("hopperable");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("consume"), "Insert!", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("consume"))
	{
		this.getSprite().PlaySound("MigrantScream1.ogg", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
		SetKnocked(this, 60);
		
		if (this.isMyPlayer()) SetScreenFlash(90, 120, 0, 0);
		
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if (!caller.exists("radpilled") || caller.get_u8("radpilled") == 0) caller.AddScript("radpilled.as");
		
			caller.set_u8("radpilled", Maths::Min(caller.get_u8("radpilled") + 1, 250));
			
			if (isServer())
			{
				this.server_Die();
			}
		}
	}
}
