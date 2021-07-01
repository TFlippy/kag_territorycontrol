//////////////////////////////////////////////////////
//
//  GunStandard.as - Vamist & Gingerbeard
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

void shootProj(CBlob@ this, const f32 aimangle) 
{
	CBitStream params;

	params.write_f32(aimangle);
	params.write_u32(getGameTime());

	this.SendCommand(this.getCommandID("fireProj"), params);
}

void Reload(CBlob@ this, CBlob@ holder) 
{
	CBitStream params;

	params.write_Vec2f(this.getPosition());
	params.write_netid(holder.getNetworkID());

	this.SendCommand(this.getCommandID("reload"), params);

	this.set_u8("clickReload", 0);
}

s32 CountAmmo(CBlob@ this, string ammoBlob = "")
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
				GunSettings@ settings;
				this.get("gun_settings", @settings);
				const string ammo = ammoBlob.empty() ? settings !is null ? settings.AMMO_BLOB : ammoBlob : ammoBlob;

				return inv.getCount(ammo);
			}
		}
	}

	return 0;
}

const bool HasAmmo(CBlob@ this)
{
	return CountAmmo(this) > 0;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	GunSettings@ settings;
	this.get("gun_settings", @settings);

	if (cmd == this.getCommandID("reload"))
	{
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

					// Determines what can have infinite ammunition
					const bool isChickenBot = holder.getPlayer() is null && holder.hasTag("chicken");

					if (this.hasTag("CustomShotgunReload"))
					{
						//Shotgun reload

						if (quantity <= 1) item.server_Die();
						else item.server_SetQuantity(Maths::Max(quantity - (isChickenBot ? 0 : 1), 0));
						quantity--;

						this.add_u8("clip", 1);
						if (clip < total || quantity == 1) this.set_bool("beginReload", true); //loop

						break;
					}
					else
					{
						//Normal reload
						s32 taken = Maths::Min(quantity, Maths::Clamp(total - clip, 0, total));

						item.server_SetQuantity(Maths::Max(quantity - (isChickenBot ? 0 : taken), 0));

						this.add_u8("clip", taken);
					}
				}
			}
		}
		if (!this.hasTag("CustomShotgunReload")) this.set_bool("doReload", false);
	}
	else if (cmd == this.getCommandID("fireProj"))
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point is null) return;

		CBlob@ holder = point.getOccupied();
		if (holder is null) return;

		if (this.get_u8("clip") < 1)
		{
			return;
		}

		if (isServer())
		{

			const f32 angle = params.read_f32();
			Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
			Vec2f offset = this.exists("ProjOffset") ? this.get_Vec2f("ProjOffset") : settings.MUZZLE_OFFSET;
			offset.x *= (this.isFacingLeft() ? 1 : -1);

			Vec2f startPos = this.getPosition() + offset.RotateBy(angle);

			CBlob@ blob = server_CreateBlobNoInit(this.get_string("ProjBlob"));
			blob.setVelocity(dir * settings.B_SPEED);
			blob.SetDamageOwnerPlayer(holder.getPlayer());
			blob.server_setTeamNum(holder.getTeamNum());
			blob.setPosition(startPos);
			blob.Init();

			blob.setAngleDegrees(angle + 90 + (this.isFacingLeft() ? 180 : 0));
		}

		this.sub_u8("clip", 1);
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
