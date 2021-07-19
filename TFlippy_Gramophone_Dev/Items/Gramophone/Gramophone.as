// A script by TFlippy

#include "GramophoneCommon.as";
#include "CargoAttachmentCommon.as";

void onInit(CBlob@ this)
{
	this.set_u8("track_id", 255);
	this.addCommandID("set_disc");
	
	CSprite@ sprite = this.getSprite();
	sprite.SetZ(50);
	
	CSpriteLayer@ sl_disc = sprite.addSpriteLayer("disc", "MusicDisc.png", 8, 8);
	if (sl_disc !is null)
	{
		
		Animation@ anim = sl_disc.addAnimation("default", 0, true);
		
		for (int i = 0; i < records.length; i++)
		{
			anim.AddFrame(i);
		}
		
		sl_disc.SetVisible(false);
		sl_disc.SetOffset(Vec2f(0, 1));
		sl_disc.SetRelativeZ(-10);
	}
	
	// CSprite@ sprite = this.getSprite();
	// for (int i = 0; i < records.length; i++)
	// {
		// Animation@ anim = sprite.addAnimation("disc_" + i, 8, true);
		// anim.AddFrame(1);
		// anim.AddFrame(i);
	// }
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !blob.hasTag("helicopter");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("set_disc"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CBlob@ carried = caller.getCarriedBlob();
		CSprite@ sprite = this.getSprite();
		
		u8 current_track_id = this.get_u8("track_id");
		
		if (current_track_id != 255)
		{
			if (isServer())
			{
				CBlob@ disc = server_CreateBlobNoInit("musicdisc");
				disc.setPosition(this.getPosition() + Vec2f(0, -4));
				disc.set_u8("track_id", this.get_u8("track_id"));
				disc.setVelocity(Vec2f(0, -8));
				disc.server_setTeamNum(this.getTeamNum());
				disc.Init();
			}
		}
		
		if (carried !is null && carried.getName() == "musicdisc")
		{
			u8 track_id = carried.get_u8("track_id");
			if (track_id < records.length)
			{
				this.set_u8("track_id", track_id);
			
				if (isServer()) 
				{
					carried.server_Die();
				}
				
				GramophoneRecord record = records[track_id];
				if (record !is null)
				{
					sprite.RewindEmitSound();
					sprite.SetEmitSound(record.filename);
					sprite.SetEmitSoundPaused(false);
					
					sprite.SetAnimation("playing");
					CSpriteLayer@ sl_disc = sprite.getSpriteLayer("disc");
					if (sl_disc !is null)
					{
						sl_disc.SetFrameIndex(track_id);
						sl_disc.SetVisible(true);
					}
				}
			}
		}
		else
		{
			this.set_u8("track_id", 255);
			sprite.SetEmitSoundPaused(true);
			
			sprite.SetAnimation("default");
			CSpriteLayer@ sl_disc = sprite.getSpriteLayer("disc");
			if (sl_disc !is null)
			{
				sl_disc.SetVisible(false);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ carried = caller.getCarriedBlob();

	u8 track_id = this.get_u8("track_id");
	bool insert = carried !is null && carried.getName() == "musicdisc";
	bool eject = carried is null && track_id != 255;

	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if (insert)
	{
		CButton@ button = caller.CreateGenericButton(17, Vec2f(0, 0), this, this.getCommandID("set_disc"), "Insert", params);
	}
	else if (eject)
	{
		CButton@ button = caller.CreateGenericButton(9, Vec2f(0, 0), this, this.getCommandID("set_disc"), "Eject", params);
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachCargo(this, blob);
	}
}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSoundPaused(true);
}