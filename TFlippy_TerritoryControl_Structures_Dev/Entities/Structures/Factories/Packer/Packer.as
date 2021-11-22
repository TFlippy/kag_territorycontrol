#include "MakeMat.as";
#include "Requirements.as";

void onInit(CSprite@ this)
{
	this.SetZ(-50);

	// this.SetEmitSound("assembler_loop.ogg");
	// this.SetEmitSoundVolume(1.0f);
	// this.SetEmitSoundSpeed(0.5f);
	// this.SetEmitSoundPaused(false);
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;

	this.Tag("builder always hit");
	this.Tag("ignore extractor");
	
	this.set_u8("packer mode", 0);
	
	this.addCommandID("set packer mode");
}

void onTick(CBlob@ this)
{
	CInventory@ inv = this.getInventory();

	if (inv.getItemsCount() == 0) return;
	
	CBlob@[] blobs;
	
	for (uint i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ blob = inv.getItem(i);
	
		if (blob !is null)
		{
			if (blob.getQuantity() == blob.maxQuantity) blobs.push_back(blob);
		}
	}
	
	if (blobs.length >= (this.get_u8("packer mode") + 1)) PackItems(this, blobs);
}

void PackItems(CBlob@ this, CBlob@[] blobs)
{
	// print("packing");
	
	if (isServer())
	{
		CBlob@ crate = server_CreateBlobNoInit("packercrate");

		if (crate !is null)
		{
			crate.server_setTeamNum(this.getTeamNum());
			crate.setPosition(this.getPosition());
			crate.Tag("team crate");
			crate.Init();
			
			CInventory@ inv = this.getInventory();
			
			for (uint i = 0; i < blobs.length; i++) if (blobs[i] !is null) crate.server_PutInInventory(blobs[i]);
		}
	}	
	
	if (isClient())
	{
		this.getSprite().PlaySound("BombMake.ogg");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if (!blob.isAttached() && (blob.hasTag("material") || blob.hasTag("hopperable")))
	{
		if (isServer()) this.server_PutInInventory(blob);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (caller !is null && caller.isOverlapping(this))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());

		CButton@ button = caller.CreateGenericButton(24, Vec2f(0, -8), this, PackerMenu, "Change packing mode");
	}
}

void PackerMenu(CBlob@ this, CBlob@ caller)
{
	if (caller.isMyPlayer())
	{
		CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(4, 1), "Set packing mode");
		
		if (menu !is null)
		{
			for (uint i = 0; i < 4; i++)
			{
				CBitStream params;
				params.write_u8(i);

				string text = "Set Packer Mode to " + (1 + i) + " stacks.";
				
				AddIconToken("$packer_icon_" + i + "$", "Packer_Icons.png", Vec2f(16, 16), i);
				
				CGridButton @butt = menu.AddButton("$packer_icon_" + i + "$", text, this.getCommandID("set packer mode"), params);
				butt.hoverText = "Packer will pack items into crates if " + (i + 1) + "/4 slots in its inventory are full.";
				if (this.get_u8("packer mode") == i)
				{
					butt.SetEnabled(false);
				}
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("set packer mode"))
	{	
		u8 setting = params.read_u8();
		this.set_u8("packer mode", setting);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob !is null && forBlob.isOverlapping(this);
}