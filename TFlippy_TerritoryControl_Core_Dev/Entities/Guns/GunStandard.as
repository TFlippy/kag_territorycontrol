//////////////////////////////////////////////////////
//
//  GunStandard.as - Vamist
//
//  Handles shooting bullets, when to reload, ammo
//  count and despawning
//

void shootGun(const u16 gunID, const f32 aimangle, const u16 hoomanID, const Vec2f pos) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(hoomanID);
	params.write_netid(gunID);
	params.write_f32(aimangle);
	params.write_Vec2f(pos);
	params.write_u32(getGameTime());

	rules.SendCommand(rules.getCommandID("fireGun"), params);
}

void shootShotgun(const u16 gunID, const f32 aimangle, const u16 hoomanID, const Vec2f pos) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(hoomanID);
	params.write_netid(gunID);
	params.write_f32(aimangle);
	params.write_Vec2f(pos);
	params.write_u32(getGameTime());

	rules.SendCommand(rules.getCommandID("fireShotgun"), params);
}

void reload(CBlob@ this, CBlob@ holder) 
{
	CBitStream params;

	params.write_Vec2f(this.getPosition());
	params.write_netid(holder.getNetworkID());

	this.SendCommand(this.getCommandID("reload"), params);

	this.set_u8("clickReload",0);
}

s32 countAmmo(CBlob@ this, string ammoBlob)
{
	//count how much ammo is in the holder's inventory
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point !is null)
	{
		CBlob@ holder = point.getOccupied();
		if (holder !is null)
		{
			CInventory@ inv = holder.getInventory();
			if (inv !is null)
			{
				s32 itemCount = inv.getCount(ammoBlob);
				return (itemCount);
			}
		}
	}

	return 0;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	if (cmd == this.getCommandID("reload")) 
	{
		//NOTE:: Reloading ammo is WIP still and has large problems as of the moment
		GunSettings@ settings;
		this.get("gun_settings", @settings);

		u32 clip = this.get_u8("clip");
		u32 total = this.get_u8("total");

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point is null) return;

		CBlob@ holder = point.getOccupied();
		if (holder is null) return;

		CInventory@ inv = holder.getInventory();
		if (inv !is null)
		{
			u32 count = inv.getItemsCount();
			for (u32 i = 0; i < count; i++)
			{
				//CBlob@ item = inv.getItem(i);
				CBlob@ item = inv.getItem(settings.AMMO_BLOB);
				if (item !is null)
				{
					s32 quantity = item.getQuantity();
					if (quantity <= 0) return;

					u32 taken = Maths::Min(quantity, Maths::Clamp(total - clip, 0, total));
					item.server_SetQuantity(quantity - taken);
					this.set_u8("clip", clip + taken);
				}
			}
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	CBlob@ carried = forBlob.getCarriedBlob();
	if (carried !is null) return (carried.hasTag("gun_attachment"));
	else return true;
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	if (!blob.hasTag("gun_attachment")) this.server_PutOutInventory(blob);
	if (blob.getName() == "scope")
	{
		this.set_f32("scope_zoom", 0.1f);
	}
}

void onRemovefromInventory(CBlob@ this, CBlob@ blob)
{
	if (blob.getName() == "scope") this.set_f32("scope_zoom", 0.0f);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	// Start ticking again
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
	this.SetDamageOwnerPlayer(attached.getPlayer());

	attached.Tag("noLMB");
	attached.Tag("noShielding");

	if (isClient()) 
	{
		CSprite@ sprite = this.getSprite();
		sprite.PlaySound("PickupGun.ogg");
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint) 
{
	if (isServer())
	{
		CSprite@ sprite = this.getSprite();
		sprite.ResetTransform();
		sprite.animation.frame = 0;
	}

	detached.Untag("noLMB");
	detached.Untag("noShielding");

	// Set angle when dropped instead of being left or right
	// Unneeded if we physically set the angle rather than just the sprite
	/*Vec2f aimvector = detached.getAimPos() - this.getPosition();
	f32 angle = 0 - aimvector.Angle() + (this.isFacingLeft() == true ? 180.0f : 0);
	this.setAngleDegrees(angle);*/

	// Reset reload and interval
	this.set_bool("beginReload", false);
	this.set_bool("doReload", false);
}
