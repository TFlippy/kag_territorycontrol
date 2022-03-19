
class AssemblerItem
{
	string resultname;
	u32 resultcount;
	u8 icon;
	string title;
	CBitStream reqs;

	AssemblerItem(string resultname, u32 resultcount, string title, int icon)
	{
		this.resultname = resultname;
		this.resultcount = resultcount;
		this.title = title;
		this.icon = icon;
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	CButton@ button = caller.CreateGenericButton(15, Vec2f(0,-8), this, AssemblerMenu, "Set Item");
}

void AssemblerMenu(CBlob@ this, CBlob@ caller)
{
	if(caller.isMyPlayer())
	{
		AssemblerItem[] items = getItems(this);
		CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(4, (items.length/4)+1), "Set Assembly");
		if (menu !is null)
		{
			for(uint i = 0; i < items.length; i += 1)
			{
				AssemblerItem item = items[i];

				CBitStream pack;
				pack.write_u8(i);

				int teamnum = this.getTeamNum();
				if (teamnum > 6) teamnum = 7;
				AddIconToken("$assembler_icon" + i + "$", "AssemblerIcons.png", Vec2f(16, 16), item.icon, teamnum);

				string text = "Set to Assemble: " + item.title;
				if(this.get_u8("crafting") == i)
				{
					text = "Already Assembling: " + item.title;
				}

				CGridButton @butt = menu.AddButton("$assembler_icon" + i + "$", text, this.getCommandID("set"), pack);
				butt.hoverText = item.title + "\n" + getButtonRequirementsText(item.reqs, false);
				if(this.get_u8("crafting") == i)
				{
					butt.SetEnabled(false);
				}
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("set"))
	{
		u8 setting = params.read_u8();
		this.set_u8("crafting", setting);
	}
}

void onTick(CBlob@ this)
{
	AssemblerItem item = getItems(this)[this.get_u8("crafting")];
	CInventory@ inv = this.getInventory();

	this.getCurrentScript().tickFrequency = 60 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);

	CBitStream missing;
	if (hasRequirements(inv, item.reqs, missing))
	{
		if (isServer())
		{
			CBlob @mat = server_CreateBlob(item.resultname, this.getTeamNum(), this.getPosition());
			mat.server_SetQuantity(item.resultcount);

			server_TakeRequirements(inv, item.reqs);
		}

		if(isClient())
		{
			this.getSprite().PlaySound("ProduceSound.ogg");
			this.getSprite().PlaySound("BombMake.ogg");
		}
	}
}



void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	bool isMat = false;

	AssemblerItem item = getItems(this)[this.get_u8("crafting")];
	CBitStream bs = item.reqs;
	bs.ResetBitIndex();
	string text, requiredType, name, friendlyName;
	u16 quantity = 0;

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, requiredType, name, friendlyName, quantity);

		if(blob.getName() == name)
		{
			isMat = true;
			break;
		}
	}

	if (isMat && !blob.isAttached() && blob.hasTag("material"))
	{
		if (isServer()) this.server_PutInInventory(blob);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (this.getTeamNum() >= 100 ? true : (forBlob.getTeamNum() == this.getTeamNum())) && forBlob.isOverlapping(this);
}

AssemblerItem[] getItems(CBlob@ this)
{
	AssemblerItem[] items;
	this.get("items", items);
	return items;
}
