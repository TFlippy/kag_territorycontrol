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

void Reload(CBlob@ this, CBlob@ holder) 
{
	CBitStream params;

	params.write_Vec2f(this.getPosition());
	params.write_netid(holder.getNetworkID());

	this.SendCommand(this.getCommandID("reload"), params);

	this.set_u8("clickReload", 0);
}

s32 CountAmmo(CBlob@ this, string ammoBlob)
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
				return inv.getCount(ammoBlob);
			}
		}
	}

	return 0;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	if (cmd == this.getCommandID("reload")) 
	{
		GunSettings@ settings;
		this.get("gun_settings", @settings);

		u32 total = settings.TOTAL;

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
				CBlob@ item = inv.getItem(i);
				if (item !is null && item.getName() == settings.AMMO_BLOB)
				{
					u32 clip = this.get_u8("clip");
					s32 quantity = item.getQuantity();

					if (clip >= total) break;

					if (this.hasTag("CustomShotgunReload"))
					{
						//Shotgun reload
						if (quantity == 1) item.server_Die();
						else item.server_SetQuantity(Maths::Max(quantity - 1, 0));
						quantity--;

						this.add_u8("clip", 1);
						if (clip < total || quantity == 1) this.set_bool("beginReload", true); //loop

						break;
					}
					else
					{
						//Normal reload
						s32 taken = Maths::Min(quantity, Maths::Clamp(total - clip, 0, total));
						item.server_SetQuantity(Maths::Max(quantity - taken, 0));
						this.add_u8("clip", taken);
					}
				}
			}
		}
		if (!this.hasTag("CustomShotgunReload")) this.set_bool("doReload", false);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	// Start ticking again
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
	this.SetDamageOwnerPlayer(attached.getPlayer());

	attached.Tag("noLMB");
	attached.Tag("noShielding");

	if (isClient() && this.exists("CustomSoundPickup"))
	{
		CSprite@ sprite = this.getSprite();
		sprite.PlaySound(this.get_string("CustomSoundPickup"));
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint) 
{
	if (isClient())
	{
		this.getSprite().ResetTransform();
	}

	detached.Untag("noLMB");
	detached.Untag("noShielding");

	// Set angle when dropped instead of being left or right
	Vec2f aimvector = detached.getAimPos() - this.getPosition();
	f32 angle = 0 - aimvector.Angle() + (this.isFacingLeft() == true ? 180.0f : 0);
	this.setAngleDegrees(angle);

	// Reset reload and interval
	this.set_bool("beginReload", false);
	this.set_bool("doReload", false);
}
