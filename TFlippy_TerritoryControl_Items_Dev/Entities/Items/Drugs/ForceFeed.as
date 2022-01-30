#include "Knocked.as";
#include "Logging.as";

void onInit(CBlob@ this)
{
	this.addCommandID("forcefeed");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if ((caller.getPosition() - this.getPosition()).Length() > 32) return;
	CBlob@ carried = caller.getCarriedBlob();
	if (caller !is this && carried !is null && carried.hasTag("forcefeedable") && !this.hasTag("dead"))
	{
		CBitStream params;
		params.write_u16(carried.getNetworkID());
		CButton@ button = caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("forcefeed"), "Forcefeed!", params);
		if (button !is null)
		{
			button.SetEnabled(carried.hasTag("forcefeed_always") || canBeForceFed(this));
		}

		button.offset = Vec2f(0,-16);
	}
}

bool canBeForceFed(CBlob@ this)
{
	return (getKnocked(this) > 0) || (this.get_f32("babbyed") > 0) || (this.isKeyPressed(key_down)) || (this.getPlayer() is null);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("forcefeed"))
		{
			CBlob@ item = getBlobByNetworkID(params.read_u16());
			if (item !is null && item.hasTag("forcefeedable") && (item.hasTag("forcefeed_always") || canBeForceFed(this)))
			{
				CBitStream stream;
				stream.write_u16(this.getNetworkID());
				item.SendCommand(item.getCommandID("consume"), stream);
			}
		}
	}
}
