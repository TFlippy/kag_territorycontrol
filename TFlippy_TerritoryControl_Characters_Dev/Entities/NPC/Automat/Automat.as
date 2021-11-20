// Princess brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "VehicleAttachmentCommon.as";

const f32 max_distance = 256.00f;

void onInit( CBrain@ this )
{
	if (isServer())
	{
		InitBrain( this );
		this.server_SetActive(true);
	}
}

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	//causes infinite ammo
	//this.Tag("npc");

	this.addCommandID("automat_give");
	this.inventoryButtonPos = Vec2f(0, 16);

	this.set_f32("pickup_priority", 8.00f); // The lower, the higher priority

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("SLOT");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2);
	}

	this.getCurrentScript().tickFrequency = 30;
	this.getCurrentScript().runFlags |= Script::tick_not_ininventory;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getTeamNum() == this.getTeamNum() && !this.hasAttached();
}

void onTick(CBlob@ this)
{
	CBrain@ brain = this.getBrain();

	if (isServer())
	{
		CBlob@ target = brain.getTarget();

		if (target !is null)
		{
			const f32 distance = (target.getPosition() - this.getPosition()).Length();
			const bool visibleTarget = isVisible(this, target);

			if (visibleTarget && distance < max_distance && !target.hasTag("dead"))
			{
				this.setAimPos(target.getPosition() + Vec2f(0, 4));
				this.setKeyPressed(key_action1, visibleTarget && this.getTickSinceCreated() % 6 == 0);

				this.getCurrentScript().tickFrequency = 1;
			}
			else
			{
				this.setKeyPressed(key_action1, false);

				brain.SetTarget(null);
				if (!this.isAttached()) this.getCurrentScript().tickFrequency = 15;
			}
		}
		else
		{
			this.setKeyPressed(key_action1, false);

			Search(brain, this);
			if (!this.isAttached()) this.getCurrentScript().tickFrequency = 15;
		}
	}
}

CBlob@ Search(CBrain@ this, CBlob@ blob)
{
	const Vec2f pos = blob.getPosition();

	CBlob@[] blobs;
	getMap().getBlobsInRadius(blob.getPosition(), max_distance, @blobs);
	const u8 myTeam = blob.getTeamNum();

	for (int i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];

		if (b.getTeamNum() == myTeam) continue;

		Vec2f bp = b.getPosition() - pos;
		f32 d = bp.Length();

		if (!b.hasTag("dead") && isVisible(blob, b) && 
			(b.hasTag("flesh") || b.hasTag("npc")) && 
			(!b.hasTag("passive") && b.getName() != "fishy"))
		{
			this.SetTarget(b);
			return b;
		}
	}

	return null;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getTeamNum() == this.getTeamNum();
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller is null) return;
	if (caller.getTeamNum() != this.getTeamNum()) return;

	// if (caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	if ((caller.getPosition() - this.getPosition()).Length() < 24.0f)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this,  this.getCommandID("automat_give"), "Attach Item", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("automat_give"))
	{
		if (isServer())
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());

			if (caller !is null)
			{
				CBlob@ carried = caller.getCarriedBlob();

				if (carried !is null && this !is null && carried.getName() == "automat") return;

				if (!this.hasAttached())
				{
					this.server_Pickup(carried);
				}
				else
				{
					this.DropCarried();
				}
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isServer())
	{
		CBrain@ brain = this.getBrain();

		if (brain !is null && hitterBlob !is null)
		{
			if (hitterBlob.getTeamNum() != this.getTeamNum()) brain.SetTarget(hitterBlob);
		}
	}

	return damage;
}
