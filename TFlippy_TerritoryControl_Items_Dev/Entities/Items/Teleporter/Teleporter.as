// Princess brain

#include "Hitters.as";
#include "Knocked.as";

const f32 radius = 96.0f;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.addCommandID("teleport");

	if (!this.exists("teleporter_pair_netid"))
	{
		if (isClient())
		{
			this.set_u16("teleporter_pair_netid", 0);
		}

		if (isServer())
		{
			CBlob@ tp = server_CreateBlobNoInit("teleporter");
			tp.server_setTeamNum(this.getTeamNum());
			tp.setPosition(this.getPosition());
			tp.set_u16("teleporter_pair_netid", this.getNetworkID());
			tp.Init();

			this.set_u16("teleporter_pair_netid", tp.getNetworkID());
			this.Sync("teleporter_pair_netid", true);
		}
	}

	this.inventoryButtonPos = Vec2f(0.5f, 0);
}

void onInit(CSprite@ this)
{
	// this.SetEmitSound("fieldgenerator_loop.ogg");
	// this.SetEmitSoundVolume(0.0f);
	// this.SetEmitSoundSpeed(0.0f);

	// this.SetEmitSoundPaused(false);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	u32 mithril_count = GetFuel(this);
	f32 radius = Maths::Sqrt(mithril_count / pi);
	u32 size = Maths::Round(radius * 2);

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	params.write_u16(this.get_u16("teleporter_pair_netid"));

	CButton@ button = caller.CreateGenericButton(11, Vec2f(0.50f, 8), this, this.getCommandID("teleport"), "Teleport!\n\nMithril Count: " + mithril_count + "\nDiameter: " + size, params);
	button.enableRadius = 32.0f;
	button.SetEnabled(mithril_count >= 9);
}

const f32 deg2rad = 0.0174533f;
const f32 rad2deg = 57.2958f;
const f32 pi = 3.14159265359f;

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("teleport"))
	{
		bool server = isServer();
		bool client = isClient();

		u16 caller_id = params.read_u16();
		u16 teleporter_id = params.read_u16();

		f32 used_mithril = 0;
		u32 mithril_count = GetFuel(this);
		f32 radius = Maths::Sqrt(mithril_count / pi);
		f32 diameter = radius * 2.00f;
		u32 size = Maths::Ceil(radius);

		{
			CBlob@ caller_blob = getBlobByNetworkID(caller_id);
			if (caller_blob !is null)
			{
				CPlayer@ caller_ply = caller_blob.getPlayer();
				if (caller_ply !is null)
				{
					printf("" + caller_ply.getUsername() + " has used a Teleporter.");
				}
			}
		}

		CBlob@ teleporter = getBlobByNetworkID(teleporter_id);
		bool hasDestination = teleporter !is null;

		// if (server)
		{
			Vec2f pos_a = this.getPosition();
			Vec2f pos_b = hasDestination ? teleporter.getPosition() : Vec2f(0, 0);

			pos_a = Vec2f(Maths::Round(pos_a.x), Maths::Round(pos_a.y));
			pos_b = Vec2f(Maths::Round(pos_b.x), Maths::Round(pos_b.y));

			CMap@ map = getMap();

			CBlob@[] blobs_a;
			if (map.getBlobsInRadius(pos_a, radius * 8, @blobs_a))
			{
				used_mithril += blobs_a.length * 2.50f;
			}

			CBlob@[] blobs_b;
			if (hasDestination)
			{
				if (map.getBlobsInRadius(pos_b, radius * 8, @blobs_b))
				{
					used_mithril += blobs_b.length * 2.50f;
				}
			}

			for (int i = 0; i < blobs_a.length; i++)
			{
				CBlob@ b = blobs_a[i];
				if (b !is null)
				{
					if (hasDestination)
					{
						Vec2f relpos = b.getPosition() - pos_a;
						b.setPosition(pos_b + relpos);

						if (b.hasTag("building") || b.hasTag("door")) AlignToTiles(b);

						// // If the object isn't fully covered by the teleporter area, it'll get cut into 2 parts and die
						// if (server)
						// {
							// print(b.getConfig() + ": Radius = " + radius + "; Distance: " + relpos.Length());

							// if (relpos.Length() > radius)
							// {
								// b.server_Die();
							// }
						// }
					}
					else
					{
						if (server)
						{
							b.server_Die();
						}
					}
				}
			}

			if (hasDestination)
			{
				for (int i = 0; i < blobs_b.length; i++)
				{
					CBlob@ b = blobs_b[i];
					if (b !is null)
					{
						Vec2f relpos = b.getPosition() - pos_b;
						b.setPosition(pos_a + relpos);

						if (b.hasTag("building") || b.hasTag("door")) AlignToTiles(b);
					}
				}
			}

			if (server)
			{
				for (int x = -radius; x <= radius; x++)
				{
					f32 val = x / f32(radius);
					f32 height = Maths::Floor(Maths::FastCos(pi * val * 0.50f) * radius) - 1;

					if (height >= 1)
					{
						for (int y = -height; y <= height; y++)
						{
							Vec2f wpos_a = pos_a + Vec2f(x * 8, y * 8);

							if (hasDestination)
							{
								Vec2f wpos_b = pos_b + Vec2f(x * 8, y * 8);
								Tile tile_a = map.getTile(wpos_a);
								Tile tile_b = map.getTile(wpos_b);

								map.server_SetTile(wpos_a, tile_b);
								map.server_SetTile(wpos_b, tile_a);

								used_mithril += GetTileCost(tile_a.type);
								used_mithril += GetTileCost(tile_b.type);
							}
							else
							{
								map.server_SetTile(wpos_a, CMap::tile_empty);
							}
						}
					}
				}
			}
		}


		// else
		// {
			// if (isServer())
			// {
				// used_mithril = mithril_count;

				// CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
				// boom.setPosition(this.getPosition());
				// boom.set_u8("boom_start", 0);
				// boom.set_u8("boom_end", radius * 2);
				// boom.set_f32("mithril_amount", 25);
				// boom.set_f32("flash_distance", 1024);
				// boom.set_u32("boom_delay", 0);
				// boom.set_u32("flash_delay", 0);
				// boom.Init();
			// }

			// if (isClient())
			// {
				// this.getSprite().PlaySound("MithrilBomb_Explode_old.ogg");
			// }
		// }

		//print("mithril start: " + mithril_count);
		//print("mithril used: " + used_mithril);

		if (client)
		{
			ShakeScreen(64, 90, this.getPosition());
			SetScreenFlash(255, 255, 255, 255);

			this.getSprite().PlaySound("Teleporter_Warp.ogg");
			if (hasDestination)
			{
				teleporter.getSprite().PlaySound("Teleporter_Warp.ogg");
			}
		}

		if (server)
		{
			TakeFuel(this, used_mithril);

			if (hasDestination)
			{

			}
			else
			{
				this.server_Die();
			}
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	CBlob@ carried = forBlob.getCarriedBlob();
	return (carried is null ? true : carried.getName() == "mat_mithril");
}

u32 GetFuel(CBlob@ this)
{
	CInventory@ inv = this.getInventory();
	if (inv != null)
	{
		return inv.getCount("mat_mithril");
	}

	return 0;
}

void TakeFuel(CBlob@ this, s32 amount)
{
	CInventory@ inv = this.getInventory();
	if (inv !is null)
	{
		s32 taken = 0;
		int size = inv.getItemsCount();

		for (int i = 0; i < size; i++)
		{
			CBlob@ item = inv.getItem(i);
			if (item !is null)
			{
				s32 quantity = item.getQuantity();

				if (quantity + 1 > amount - taken)
				{
					item.server_SetQuantity(Maths::Max(0, quantity - amount - taken));
				}
				else
				{
					item.server_Die();
				}

				taken += Maths::Min(quantity, amount - taken);
				if (taken >= amount)
				{
					return;
				}
			}
		}
	}
}

// void TakeFuel(CBlob@ this, u32 amount)
// {
	// if (isServer())
	// {
		// CInventory@ inv = this.getInventory();
		// if (inv != null)
		// {
			// u32 count = inv.getItemsCount();

			// for (u32 i = 0; i < count && quantity > 0; i++)
			// {
				// CBlob@ item = inv.getItem(i);
				// if (item !is null)
				// {
					// u32 quantity = item.getQuantity();
					// // u32 item_maxQuantity = item.maxQuantity;

					// if (quantity < amount)
					// {
						// item.server_Die();
						// amount -= quantity;
					// }
					// else
					// {
						// item.server_setQuantity(;
						// amount -= quantity;
					// }

					// print("" + amount + ", took " + quantity);

					// // item.server_SetQuantity(amount);
				// }
			// }
		// }
	// }
// }

void onTick(CBlob@ this)
{
	// this.inventoryButtonPos = Vec2f(0.5f, 16);
	this.inventoryButtonPos = Vec2f(0.5f, 0);

	// CBlob@[] blobsInRadius;
	// if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
	// {

	// }
}

f32 GetTileCost(u16 tile)
{
	switch (tile)
	{
		case CMap::tile_empty:
			return 0.01f;

		case CMap::tile_ground:
		case CMap::tile_ground_d0:
		case CMap::tile_ground_d1:
		case CMap::tile_ground_back:
		case CMap::tile_gold:
		case CMap::tile_stone:
		case CMap::tile_stone_d0:
		case CMap::tile_stone_d1:
		case CMap::tile_wood:
		case CMap::tile_wood_d0:
		case CMap::tile_wood_d1:
		case CMap::tile_wood_back:
			return 0.30f;
			
		case CMap::tile_grass:
			return 0.20f;
			
		case CMap::tile_castle:
		case CMap::tile_castle_d0:
		case CMap::tile_castle_d1:
		case CMap::tile_castle_moss:
		case CMap::tile_castle_back:
		case CMap::tile_castle_back_moss:
		case CMap::tile_thickstone:
		case CMap::tile_thickstone_d0:
		case CMap::tile_thickstone_d1:
			return 0.50f;

		default:
			return 0.50f;
	}

	return 0.50f;
}

void AlignToTiles(CBlob@ this)
{
	CShape@ shape = this.getShape();
	CMap@ map = this.getMap();
	f32 div_maptile = 1.0f / map.tilesize;

	Vec2f p = this.getPosition();

	Vec2f tp = p * div_maptile;
	Vec2f round_tp = tp;
	round_tp.x = Maths::Round(round_tp.x);
	round_tp.y = Maths::Floor(round_tp.y);

	f32 width = shape.getWidth() * div_maptile;
	f32 height = shape.getHeight() * div_maptile;

	f32 modwidth = Maths::FMod(width , 2.0f);
	f32 modheight = Maths::FMod(height , 2.0f);

	bool oddWidth = modwidth > 0.5f && modwidth < 1.5f;
	bool oddHeight = modheight > 0.5f && modheight < 1.5f;

	f32 move_x = (round_tp.x > tp.x ? -1.0f : 1.0f);
	f32 move_y = (round_tp.y > tp.y ? -1.0f : 1.0f);

	p.x = round_tp.x * map.tilesize + (oddWidth ? map.tilesize * 0.5f : 0.0f) * move_x;
	p.y = round_tp.y * map.tilesize + (oddHeight ? map.tilesize * 0.5f : 0.0f) * move_y;
	this.setPosition(p);
	this.setVelocity(Vec2f());
	shape.SetGravityScale(0.0f);
}
