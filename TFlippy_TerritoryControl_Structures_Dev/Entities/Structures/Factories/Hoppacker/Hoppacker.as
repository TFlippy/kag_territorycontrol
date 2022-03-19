#include "MakeMat.as";
#include "Requirements.as";

void onInit(CSprite@ this)
{
	this.SetZ(-50);

	// this.SetEmitSound("assembler_loop.ogg");
	// this.SetEmitSoundVolume(1.0f);
	// this.SetEmitSoundSpeed(0.5f);
	// this.SetEmitSoundPaused(false);
	
	CSpriteLayer@ crate = this.addSpriteLayer("crate","Hoppacker.png", 24, 24);
	if(crate !is null)
	{
		crate.addAnimation("default",0,false);
		crate.animation.AddFrame(3);
		crate.SetRelativeZ(1);
		crate.SetOffset(Vec2f(0,-1));
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint ){
	detached.SetVisible(true);
}

void onTick(CSprite@ this)
{
	bool hasCrate = this.getBlob().getCarriedBlob() !is null;
	if(hasCrate)this.getBlob().getCarriedBlob().SetVisible(false);
	CSpriteLayer@ crate = this.getSpriteLayer("crate");
	if(crate !is null)
	{
		crate.SetVisible(hasCrate);
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	this.setPosition(this.getPosition()-Vec2f(0,2));
}

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;

	this.Tag("builder always hit");
	
	this.set_u8("packer mode", 0);
	
	this.addCommandID("crate");
	
	
	AttachmentPoint@ crateSlot = this.getAttachmentPoint(0);
	if(crateSlot !is null){
		crateSlot.offsetZ = 2;
	}
}

void onTick(CBlob@ this)
{
	/*
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
	*/
	
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
		if(isServer()){
			CBlob @crate = this.getCarriedBlob();
			if(crate is null){
				@crate = createCrate(this);
			}
			if(crate !is null){
				if(!crate.server_PutInInventory(blob)){
					this.DropCarried();
					@crate = createCrate(this);
					crate.server_PutInInventory(blob);
				}
			}
		}
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
	if(!this.isAttached() && !blob.isAttached() && blob.hasTag("crate")){
		if(isServer())this.server_Pickup(blob);
		if(isClient())this.getSprite().PlaySound("bridge_open.ogg");
	}
}

CBlob@ createCrate(CBlob @this){
	CBlob @crate = server_CreateBlobNoInit("packercrate");

	crate.server_setTeamNum(this.getTeamNum());
	crate.setPosition(this.getPosition());
	crate.Tag("team crate");
	crate.Init();
	
	this.server_Pickup(crate);
	
	return crate;
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if(this.getCarriedBlob() !is null){
		caller.CreateGenericButton(24, Vec2f(0, -9), this, this.getCommandID("crate"), "Unload Crate",params);
	} else
	if(caller.getCarriedBlob() !is null)
	if(caller.getCarriedBlob().hasTag("crate")){
		caller.CreateGenericButton(24, Vec2f(0, -9), this, this.getCommandID("crate"), "Load Crate",params);
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
	if (cmd == this.getCommandID("crate"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(isServer())
		if(caller !is null){
			if(this.getCarriedBlob() !is null){
				caller.server_Pickup(this.getCarriedBlob());
			} else
			if(caller.getCarriedBlob() !is null)
			if(caller.getCarriedBlob().hasTag("crate")){
				this.server_Pickup(caller.getCarriedBlob());
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.isKeyPressed(key_down))return false;

	return true;
}